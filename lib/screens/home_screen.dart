import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/core/utils/formatters.dart';
import 'package:first_project/model/category.dart';
import 'package:first_project/model/meal.dart';
import 'package:first_project/provider/auth_provider.dart';
import 'package:first_project/provider/cart_provider.dart';
import 'package:first_project/provider/category_provider.dart';
import 'package:first_project/provider/meal_provider.dart';
import 'package:first_project/screens/cart_screen.dart';
import 'package:first_project/screens/meal_details_screen.dart';
import 'package:first_project/screens/meals_screen.dart';
import 'package:first_project/screens/search_screen.dart';
import 'package:first_project/widgets/app_image.dart';
import 'package:first_project/widgets/cart_badge.dart';
import 'package:first_project/widgets/meal_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final mealProvider = context.watch<MealProvider>();

    final greeting = _greeting(auth.currentUser?.name);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(greeting,
                                  style: AppTextStyles.bodySmall),
                              const SizedBox(height: 2),
                              Text(
                                "What's for today?",
                                style: AppTextStyles.heading,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          ),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CartBadge(
                                count: context.watch<CartProvider>().totalCount,
                                child: const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search bar shortcut
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SearchScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded,
                                color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: 10),
                            Text('Search meals, cuisines...',
                                style: AppTextStyles.body.copyWith(
                                    color: AppColors.textDisabled)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),

          // ── Popular Categories ──────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SectionHeader(
                    title: 'Popular Categories',
                    onSeeAll: () {},
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: categoryProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: categoryProvider.categories.length,
                          itemBuilder: (ctx, i) => _HomeCategoryChip(
                            category: categoryProvider.categories[i],
                          ),
                        ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── Popular Meals ───────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SectionHeader(
                title: 'Popular Meals',
                onSeeAll: () {},
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: mealProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: mealProvider.popularMeals.length,
                      itemBuilder: (ctx, i) => _HorizontalMealCard(
                        meal: mealProvider.popularMeals[i],
                      ),
                    ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ── All Meals ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SectionHeader(title: 'All Meals', onSeeAll: null),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          if (mealProvider.isLoading)
            const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => MealItem(
                  meal: mealProvider.allMeals[i],
                  animationDelay: Duration(milliseconds: i * 60),
                ),
                childCount: mealProvider.allMeals.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  String _greeting(String? name) {
    final hour = DateTime.now().hour;
    final salutation = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    return name != null ? '$salutation, $name 👋' : '$salutation! 👋';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});
  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.title),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Text('See all', style: AppTextStyles.buttonSmall),
          ),
      ],
    );
  }
}

class _HomeCategoryChip extends StatelessWidget {
  const _HomeCategoryChip({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MealsScreen(
            categoryId: category.id,
            title: category.title,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: category.color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(category.icon, color: category.color, size: 26),
            const SizedBox(height: 6),
            Text(category.title,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Color.lerp(category.color, Colors.black, 0.5),
                )),
          ],
        ),
      ),
    );
  }
}

class _HorizontalMealCard extends StatelessWidget {
  const _HorizontalMealCard({required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (ctx, animation, secondary) => FadeTransition(
            opacity: animation,
            child: MealDetailsScreen(meal: meal),
          ),
          transitionDuration: const Duration(milliseconds: 350),
        ),
      ),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'meal_image_${meal.id}',
                child: AppImage(
                  imageUrl: meal.imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholderIconSize: 32,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.star, size: 13),
                        const SizedBox(width: 2),
                        Text(meal.rating.toStringAsFixed(1),
                            style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600)),
                        const Spacer(),
                        Text(
                          AppFormatters.price(meal.price),
                          style: AppTextStyles.priceSmall.copyWith(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
