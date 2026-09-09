import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/recipe_provider.dart';
import '../Provider/theme_provider.dart';
import '../Utils/constants.dart';
import '../Widget/banner.dart';
import '../Widget/food_items_display.dart';
import 'view_all_screen.dart';

class MyAppHomeScreen extends StatelessWidget {
  const MyAppHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final themeProvider = Provider.of<AppThemeProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: recipeProvider.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What are you\ncooking today?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          themeProvider.notificationsEnabled
                              ? Icons.notifications_none
                              : Icons.notifications_off_outlined,
                          color: themeProvider.notificationsEnabled
                              ? (isDark ? Colors.white : Colors.black87)
                              : Colors.redAccent,
                        ),
                        onPressed: () {
                          themeProvider.toggleNotifications(!themeProvider.notificationsEnabled);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => recipeProvider.setSearchQuery(val),
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search any recipes',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: recipeProvider.searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => recipeProvider.setSearchQuery(''),
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: PromoBanner(),
              ),
              const SizedBox(height: 25),
              Center(
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: recipeProvider.categories.length,
                  itemBuilder: (context, index) {
                    final category = recipeProvider.categories[index];
                    final isSelected = recipeProvider.selectedCategory.toLowerCase() == category.toLowerCase();

                    return GestureDetector(
                      onTap: () => recipeProvider.selectCategory(category),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark ? Colors.grey[800] : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.grey[300] : Colors.grey[700]),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick & Easy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ViewAllScreen(
                              categoryName: recipeProvider.selectedCategory,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 210,
                child: recipeProvider.filteredRecipes.isEmpty
                    ? const Center(
                  child: Text('No recipes found!', style: TextStyle(color: Colors.grey)),
                )
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  itemCount: recipeProvider.filteredRecipes.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 165,
                      margin: const EdgeInsets.only(right: 15),
                      child: FoodItemsDisplay(
                        recipe: recipeProvider.filteredRecipes[index],
                        showRating: false,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}