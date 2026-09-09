import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/recipe_model.dart';
import '../Provider/recipe_provider.dart';
import '../Widget/food_items_display.dart';

class ViewAllScreen extends StatelessWidget {
  final String categoryName;

  const ViewAllScreen({
    super.key,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$categoryName Recipes',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Consumer<RecipeProvider>(
          builder: (context, provider, child) {
            // ক্যাটাগরি অনুযায়ী ফিল্টার করা রিয়েল-টাইম রেসিপি লিস্ট
            final List<RecipeModel> displayRecipes = categoryName.toLowerCase() == 'all'
                ? provider.recipes
                : provider.recipes.where((r) {
              // অথবা আপনার Provider-এর ক্যাটাগরি ফিল্টার লজিক ব্যবহার করতে পারেন
              return provider.filteredRecipes.contains(r);
            }).toList();

            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (displayRecipes.isEmpty) {
              return const Center(
                child: Text('No recipes found', style: TextStyle(color: Colors.grey)),
              );
            }

            return GridView.builder(
              itemCount: displayRecipes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return FoodItemsDisplay(
                  recipe: displayRecipes[index],
                  showRating: true,
                );
              },
            );
          },
        ),
      ),
    );
  }
}