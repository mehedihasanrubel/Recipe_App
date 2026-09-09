import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/recipe_model.dart';
import '../Provider/recipe_provider.dart';
import '../Views/recipe_detail_screen.dart';

class FoodItemsDisplay extends StatelessWidget {
  final RecipeModel recipe;
  final bool showRating;

  const FoodItemsDisplay({
    super.key,
    required this.recipe,
    this.showRating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipe: recipe)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  recipe.imageUrl,
                  height: 125,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 125,
                    color: Colors.grey[300],
                    child: const Icon(Icons.fastfood, color: Colors.grey),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => recipeProvider.toggleFavorite(recipe),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black87 : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: recipe.isFavorite ? Colors.red : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            recipe.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.flash_on, size: 12, color: Colors.grey),
              Text('${recipe.calories} Cal ', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const Text('• ', style: TextStyle(fontSize: 10, color: Colors.grey)),
              const Icon(Icons.access_time, size: 12, color: Colors.grey),
              Text(' ${recipe.time}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          if (showRating) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.star, size: 12, color: Colors.amber),
                Text(
                  ' ${recipe.rating} ',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(recipe.reviews, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}