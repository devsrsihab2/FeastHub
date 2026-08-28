import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/model/meal.dart';
import 'package:first_project/provider/cart_provider.dart';
import 'package:first_project/provider/meal_provider.dart';
import 'package:first_project/screens/cart_screen.dart';
import 'package:first_project/widgets/cart_badge.dart';
import 'package:first_project/widgets/meal_item.dart';
import 'package:first_project/widgets/not_found.dart';
import 'package:first_project/widgets/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key, required this.categoryId, required this.title});

  final String categoryId;
  final String title;

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  List<Meal>? _meals;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final meals = await context
        .read<MealProvider>()
        .getMealsByCategory(widget.categoryId);
    if (mounted) {
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title, style: AppTextStyles.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            icon: CartBadge(
              count: context.watch<CartProvider>().totalCount,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const MealListShimmer()
          : _meals == null || _meals!.isEmpty
              ? NotFoundWideget(
                  title: 'No meals in ${widget.title}',
                  message: 'This category is empty right now.',
                  onBrowse: () => Navigator.of(context).pop(),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _meals!.length,
                  itemBuilder: (ctx, i) => MealItem(
                    meal: _meals![i],
                    animationDelay: Duration(milliseconds: i * 70),
                  ),
                ),
    );
  }
}
