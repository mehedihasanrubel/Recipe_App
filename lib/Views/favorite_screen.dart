import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/recipe_provider.dart';
import '../Widget/food_items_display.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final favList = recipeProvider.favoriteRecipes;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorite Recipes',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: favList.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No favorite recipes added yet!', style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.builder(
          itemCount: favList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            return FoodItemsDisplay(recipe: favList[index], showRating: true);
          },
        ),
      ),
    );
  }
}