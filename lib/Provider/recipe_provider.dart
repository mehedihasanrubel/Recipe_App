import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/recipe_model.dart';

class RecipeProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<RecipeModel> _recipes = [];
  List<String> _categories = ['All'];

  Map<String, List<String>> _categoryRecipeMap = {};

  String _selectedCategory = 'All';
  bool _isLoading = true;
  String _searchQuery = '';

  final Map<String, List<RecipeModel>> _mealPlan = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  List<RecipeModel> get recipes => _recipes;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  Map<String, List<RecipeModel>> get mealPlan => _mealPlan;

  RecipeProvider() {
    initData();
  }

  void initData() async {
    fetchCategories();
    fetchRecipesAndFavorites();
  }

  void fetchCategories() {
    _firestore.collection('app-category').snapshots().listen((snapshot) {
      List<String> fetchedCategories = [];
      Map<String, List<String>> tempMap = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data();
        if (data.containsKey('name')) {
          String catName = data['name'].toString();
          fetchedCategories.add(catName);

          List<String> recipeIds = [];
          if (data['recipes'] is List) {
            List<dynamic> rawRecipes = data['recipes'];
            for (var item in rawRecipes) {
              if (item is Map) {
                if (item.containsKey('id')) {
                  recipeIds.add(item['id'].toString());
                }
              } else if (item is String) {
                recipeIds.add(item);
              }
            }
          }
          tempMap[catName.toLowerCase()] = recipeIds;
        }
      }

      fetchedCategories.removeWhere((c) => c.toLowerCase() == 'all');
      fetchedCategories.insert(0, 'All');

      _categories = fetchedCategories;
      _categoryRecipeMap = tempMap;
      notifyListeners();
    });
  }

  void fetchRecipesAndFavorites() {
    _firestore.collection('favorites').snapshots().listen((favSnapshot) {
      Set<String> favIds = favSnapshot.docs.map((doc) => doc.id).toSet();

      _firestore.collection('recipes').snapshots().listen((recipeSnapshot) {
        _recipes = recipeSnapshot.docs.map((doc) {
          bool isFav = favIds.contains(doc.id);
          return RecipeModel.fromFirestore(doc, isFav: isFav);
        }).toList();

        _isLoading = false;
        fetchMealPlan();
        notifyListeners();
      });
    });
  }

  void fetchMealPlan() {
    _firestore.collection('meal_plan').snapshots().listen((snapshot) {
      _mealPlan.forEach((key, value) => value.clear());

      for (var doc in snapshot.docs) {
        String day = doc.id;
        Map<String, dynamic> data = doc.data();

        if (data.containsKey('recipes') && data['recipes'] is List) {
          List<dynamic> rawRecipes = data['recipes'];

          List<String> recipeIds = [];
          for (var item in rawRecipes) {
            if (item is Map && item.containsKey('id')) {
              recipeIds.add(item['id'].toString());
            } else if (item is String) {
              recipeIds.add(item);
            }
          }

          List<RecipeModel> matchedRecipes = _recipes
              .where((r) => recipeIds.contains(r.id))
              .toList();

          if (_mealPlan.containsKey(day)) {
            _mealPlan[day] = matchedRecipes;
          }
        }
      }
      notifyListeners();
    });
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  // --- পরিবর্তিত টগল ফেভারিট ফাংশন ---
  Future<void> toggleFavorite(RecipeModel recipe) async {
    final index = _recipes.indexWhere((r) => r.id == recipe.id);
    final previousStatus = recipe.isFavorite;

    // ১. সাথে সাথে Local State আপডেট করুন (UI Instant Red করার জন্য)
    if (index != -1) {
      _recipes[index].isFavorite = !previousStatus;
      notifyListeners();
    }

    final favRef = _firestore.collection('favorites').doc(recipe.id);

    try {
      if (previousStatus) {
        // আগে ফেভারিট ছিল, এখন রিমুভ করা হবে
        await favRef.delete();
      } else {
        // আগে ফেভারিট ছিল না, এখন অ্যাড করা হবে
        await favRef.set({
          'title': recipe.title,
          'isFavorite': true,
        });
      }
    } catch (e) {
      // ফায়ারবেসে কোনো সমস্যা হলে আগের অবস্থায় ফেরত নেওয়া (Rollback)
      if (index != -1) {
        _recipes[index].isFavorite = previousStatus;
        notifyListeners();
      }
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<RecipeModel> get filteredRecipes {
    List<RecipeModel> list = _recipes.where((recipe) {
      bool matchesCategory = true;

      if (_selectedCategory.toLowerCase() != 'all') {
        List<String>? validIds = _categoryRecipeMap[_selectedCategory.toLowerCase()];
        matchesCategory = validIds != null && validIds.contains(recipe.id);
      }

      bool matchesSearch = recipe.title.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list;
  }

  List<RecipeModel> get favoriteRecipes {
    List<RecipeModel> list = _recipes.where((r) => r.isFavorite).toList();
    list.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return list;
  }

  Future<void> addToMealPlan(String day, RecipeModel recipe) async {
    final docRef = _firestore.collection('meal_plan').doc(day);

    await docRef.set({
      'recipes': FieldValue.arrayUnion([
        {
          'id': recipe.id,
          'title': recipe.title,
        }
      ])
    }, SetOptions(merge: true));
  }

  Future<void> removeFromMealPlan(String day, RecipeModel recipe) async {
    final docRef = _firestore.collection('meal_plan').doc(day);

    await docRef.update({
      'recipes': FieldValue.arrayRemove([
        {
          'id': recipe.id,
          'title': recipe.title,
        }
      ])
    });
  }
}