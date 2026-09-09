import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../Models/recipe_model.dart';
import '../Provider/recipe_provider.dart';
import '../Provider/theme_provider.dart';
import '../Provider/quantity_provider.dart';
import '../Utils/constants.dart';
import '../Widget/quantity_increment_decrement.dart';

class RecipeDetailScreen extends StatelessWidget {
  final RecipeModel recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final themeProvider = Provider.of<AppThemeProvider>(context);

    // Provider থেকে রিয়েল-টাইম আপডেট হওয়া রেসিপি অবজেক্টটি খুঁজে বের করা
    final liveRecipe = recipeProvider.recipes.firstWhere(
          (r) => r.id == recipe.id,
      orElse: () => recipe,
    );

    return ChangeNotifierProvider(
      create: (_) {
        final provider = QuantityProvider();
        provider.initQuantity(recipe.servings);
        return provider;
      },
      child: Consumer<QuantityProvider>(
        builder: (context, quantityProvider, child) {
          int servings = quantityProvider.currentNumber;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('recipes').doc(recipe.id).snapshots(),
            builder: (context, snapshot) {
              RecipeModel currentRecipe = liveRecipe;
              if (snapshot.hasData && snapshot.data!.exists) {
                // Provider-এর রিয়েল-টাইম isFavorite ভ্যালু পাস করা হচ্ছে
                currentRecipe = RecipeModel.fromFirestore(snapshot.data!, isFav: liveRecipe.isFavorite);
              }

              return Scaffold(
                body: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: MediaQuery.of(context).size.height * 0.45,
                      child: Image.network(
                        currentRecipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.chevron_left, color: isDark ? Colors.white : Colors.black87, size: 28),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => themeProvider.toggleNotifications(!themeProvider.notificationsEnabled),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                themeProvider.notificationsEnabled ? Icons.notifications_none : Icons.notifications_off_outlined,
                                color: themeProvider.notificationsEnabled ? (isDark ? Colors.white : Colors.black87) : Colors.redAccent,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                      top: MediaQuery.of(context).size.height * 0.38,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentRecipe.title,
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.flash_on_outlined, size: 14, color: Colors.grey),
                                        Text(' ${currentRecipe.calories} ', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                        const SizedBox(width: 8),
                                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                        Text(' ${currentRecipe.time}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 14, color: Colors.amber),
                                        Text(
                                          ' ${currentRecipe.rating} ',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        Text(currentRecipe.reviews, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ingredients',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            const Text('How many servings?', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                          ],
                                        ),
                                        const QuantityIncrementDecrement(),
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: currentRecipe.ingredients.length,
                                      itemBuilder: (context, index) {
                                        final item = currentRecipe.ingredients[index];
                                        final double currentAmount = item.baseAmount * servings;

                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 45,
                                                height: 45,
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: isDark ? Colors.grey[800] : Colors.grey.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Image.network(
                                                  item.image,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error, stackTrace) =>
                                                  const Icon(Icons.fastfood, color: Colors.grey, size: 20),
                                                ),
                                              ),
                                              const SizedBox(width: 15),
                                              Expanded(
                                                child: Text(
                                                  item.name,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark ? Colors.white : Colors.black87,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                '${currentAmount % 1 == 0 ? currentAmount.toInt() : currentAmount.toStringAsFixed(1)}${item.unit}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Happy Cooking! 🍳'), duration: Duration(seconds: 2)),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                              ),
                              child: const Text('Start Cooking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                currentRecipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: currentRecipe.isFavorite ? Colors.red : Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                recipeProvider.toggleFavorite(currentRecipe);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}