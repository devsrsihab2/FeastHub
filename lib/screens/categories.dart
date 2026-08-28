import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/model/category.dart';
import 'package:first_project/provider/category_provider.dart';
import 'package:first_project/screens/meals_screen.dart';
import 'package:first_project/widgets/category_grid_item.dart';
import 'package:first_project/widgets/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  void _selectCategory(BuildContext context, Category category) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, secondary) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: MealsScreen(
            categoryId: category.id,
            title: category.title,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();

    if (categoryProvider.isLoading) {
      return const SafeArea(
        bottom: false,
        child: CategoryShimmerGrid(),
      );
    }

    final categories = categoryProvider.categories;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Browse Categories', style: AppTextStyles.heading),
                  const SizedBox(height: 4),
                  Text(
                    '${categories.length} cuisines to explore',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final cat = categories[i];
                  return CategoryCard(
                    category: cat,
                    animationDelay: Duration(milliseconds: i * 45),
                    onTap: () => _selectCategory(context, cat),
                  );
                },
                childCount: categories.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.15,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
