import 'package:cloud_firestore/cloud_firestore.dart';

class IngredientModel {
  final String name;
  final double baseAmount;
  final String unit;
  final String image;

  IngredientModel({
    required this.name,
    required this.baseAmount,
    required this.unit,
    required this.image,
  });

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    double parsedAmount = 0.0;
    if (map['baseAmount'] != null) {
      if (map['baseAmount'] is num) {
        parsedAmount = (map['baseAmount'] as num).toDouble();
      } else if (map['baseAmount'] is String) {
        parsedAmount = double.tryParse(map['baseAmount'].toString()) ?? 0.0;
      }
    }

    return IngredientModel(
      name: map['name']?.toString() ?? '',
      baseAmount: parsedAmount,
      unit: map['unit']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
    );
  }
}

class RecipeModel {
  final String id;
  final String title;
  final String calories;
  final String time;
  final String rating;
  final String reviews;
  final String imageUrl;
  final int servings;
  bool isFavorite;
  final List<IngredientModel> ingredients;

  RecipeModel({
    required this.id,
    required this.title,
    required this.calories,
    required this.time,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.servings,
    this.isFavorite = false,
    required this.ingredients,
  });

  factory RecipeModel.fromFirestore(DocumentSnapshot doc, {bool isFav = false}) {
    Map<String, dynamic> data = (doc.data() as Map<String, dynamic>?) ?? {};

    var ingredientsList = data['ingredients'];
    List<IngredientModel> parsedIngredients = [];

    if (ingredientsList is List) {
      parsedIngredients = ingredientsList.map((i) {
        if (i is Map<String, dynamic>) {
          return IngredientModel.fromMap(i);
        } else if (i is Map) {
          return IngredientModel.fromMap(Map<String, dynamic>.from(i));
        }
        return IngredientModel(name: '', baseAmount: 0.0, unit: '', image: '');
      }).toList();
    }

    int parsedServings = 1;
    if (data['servings'] != null) {
      if (data['servings'] is int) {
        parsedServings = data['servings'];
      } else {
        parsedServings = int.tryParse(data['servings'].toString()) ?? 1;
      }
    }

    return RecipeModel(
      id: doc.id,
      title: data['title']?.toString() ?? '',
      calories: data['calories']?.toString() ?? '',
      time: data['time']?.toString() ?? '',
      rating: data['rating']?.toString() ?? '0.0',
      reviews: data['reviews']?.toString() ?? '(0)',
      imageUrl: data['imageUrl']?.toString() ?? '',
      servings: parsedServings,
      isFavorite: isFav,
      ingredients: parsedIngredients,
    );
  }
}