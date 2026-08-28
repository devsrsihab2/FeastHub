import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/provider/cart_provider.dart';
import 'package:first_project/provider/favorites_provider.dart';
import 'package:first_project/screens/cart_screen.dart';
import 'package:first_project/widgets/cart_badge.dart';
import 'package:first_project/widgets/meal_item.dart';
import 'package:first_project/widgets/not_found.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoritesProvider>();
    final cartCount = context.watch<CartProvider>().totalCount;
    final meals = favProvider.favoriteMeals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Favorites', style: AppTextStyles.heading),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            icon: CartBadge(
              count: cartCount,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: favProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : meals.isEmpty
              ? NotFoundWideget(
                  title: 'No favorites yet',
                  message: 'Explore delicious meals and tap the heart icon\nto save your favorites here!',
                  icon: Icons.favorite_border_rounded,
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: meals.length,
                  itemBuilder: (ctx, i) => MealItem(
                    meal: meals[i],
                    animationDelay: Duration(milliseconds: i * 50),
                  ),
                ),
    );
  }
}
