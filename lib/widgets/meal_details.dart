import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/core/utils/formatters.dart';
import 'package:first_project/model/meal.dart';
import 'package:first_project/provider/auth_provider.dart';
import 'package:first_project/provider/cart_provider.dart';
import 'package:first_project/provider/category_provider.dart';
import 'package:first_project/provider/favorites_provider.dart';
import 'package:first_project/widgets/app_image.dart';
import 'package:first_project/widgets/circle_icon_button.dart';
import 'package:first_project/widgets/diet_tag.dart';
import 'package:first_project/widgets/quantity_selector.dart';
import 'package:first_project/widgets/segment_button.dart';
import 'package:first_project/widgets/stat_item.dart';
import 'package:first_project/widgets/vertical_divider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MealDetails extends StatefulWidget {
  const MealDetails({super.key, required this.meal});

  final Meal meal;

  @override
  State<MealDetails> createState() => _MealDetailsState();
}

class _MealDetailsState extends State<MealDetails>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _sheetFade;
  late Animation<Offset> _sheetSlide;
  late Animation<Offset> _bottomBarSlide;

  int _tabIndex = 0;
  int _quantity = 1;
  bool _addingToCart = false;

  Meal get meal => widget.meal;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _sheetFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
    );

    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
    ));

    _bottomBarSlide = Tween<Offset>(
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    final favProvider = context.watch<FavoritesProvider>();
    final authProvider = context.read<AuthProvider>();
    final cartProvider = context.watch<CartProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final isFav = favProvider.isFavorite(meal.id);
    final inCart = cartProvider.containsMeal(meal.id);
    final categoryNames = categoryProvider.getCategoryNames(meal.categories);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero Image Header ──────────────────────────────
              SliverAppBar(
                expandedHeight: size.height * 0.40,
                pinned: true,
                stretch: true,
                backgroundColor: colorScheme.surface,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleIconButton(
                      icon: isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: isFav ? AppColors.error : null,
                      onTap: () async {
                        final userId = authProvider.effectiveUserId;
                        final favProv = context.read<FavoritesProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        final wasAdded =
                            await favProv.toggleFavorite(userId, meal);
                        messenger.clearSnackBars();
                        messenger.showSnackBar(SnackBar(
                          content: Text(wasAdded
                              ? '❤️ Added to favorites'
                              : '💔 Removed from favorites'),
                          duration: const Duration(seconds: 2),
                        ));
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'meal_image_${meal.id}',
                    child: AppImage(
                      imageUrl: meal.imageUrl,
                      fit: BoxFit.cover,
                      placeholderIconSize: 64,
                    ),
                  ),
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],
                ),
              ),

              // ── Content Sheet with Entrance Animation ──────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _sheetFade,
                  child: SlideTransition(
                    position: _sheetSlide,
                    child: Transform.translate(
                      offset: const Offset(0, -24),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Drag handle
                            Center(
                              child: Container(
                                width: 44,
                                height: 4.5,
                                margin: const EdgeInsets.only(bottom: 18),
                                decoration: BoxDecoration(
                                  color: colorScheme.outlineVariant,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            // ── Title + Price row ──────────────────────
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meal.title,
                                        style: AppTextStyles.heading.copyWith(
                                          height: 1.2,
                                          fontSize: 22,
                                        ),
                                      ),
                                      if (categoryNames.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          categoryNames,
                                          style: AppTextStyles.bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  AppFormatters.price(meal.price),
                                  style: AppTextStyles.price.copyWith(
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // ── Rating row ─────────────────────────────
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.star, size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  meal.rating.toStringAsFixed(1),
                                  style: AppTextStyles.body.copyWith(
                                      fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '(${meal.reviewCount} reviews)',
                                  style: AppTextStyles.bodySmall,
                                ),
                                const Spacer(),
                                if (meal.isVegetarian)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.successLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '🌱 Vegetarian',
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // ── Stat row ───────────────────────────────
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  StatItem(
                                    icon: Icons.schedule_rounded,
                                    value:
                                        AppFormatters.duration(meal.duration),
                                    unit: 'Duration',
                                    color: colorScheme.primary,
                                  ),
                                  const CustomVerticalDivider(),
                                  StatItem(
                                    icon: Icons.speed_rounded,
                                    value: meal.complexityLabel,
                                    unit: 'Complexity',
                                    color: colorScheme.secondary,
                                  ),
                                  const CustomVerticalDivider(),
                                  StatItem(
                                    icon: Icons.attach_money_rounded,
                                    value: meal.affordabilityLabel,
                                    unit: 'Affordability',
                                    color: colorScheme.tertiary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ── Diet Tags ──────────────────────────────
                            _buildDietarySection(theme),
                            const SizedBox(height: 20),

                            // ── Segmented Control ──────────────────────
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  SegmentButton(
                                    label: 'Ingredients (${meal.ingredients.length})',
                                    selected: _tabIndex == 0,
                                    onTap: () => setState(() => _tabIndex = 0),
                                  ),
                                  SegmentButton(
                                    label: 'Steps (${meal.steps.length})',
                                    selected: _tabIndex == 1,
                                    onTap: () => setState(() => _tabIndex = 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ── Animated Switcher for Ingredients / Steps ──
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.05, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                              child: _tabIndex == 0
                                  ? _buildIngredientsSection(theme)
                                  : _buildStepsSection(theme),
                            ),

                            // Bottom padding so content is not obscured by bottom bar
                            const SizedBox(height: 110),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Animated Floating Bottom Action Bar ────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _bottomBarSlide,
              child: _buildBottomBar(
                context,
                authProvider,
                cartProvider,
                inCart,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietarySection(ThemeData theme) {
    final tags = <Widget>[];
    if (meal.isGlutenFree) {
      tags.add(const DietTag(
        label: 'Gluten-Free',
        icon: Icons.grass_rounded,
        color: AppColors.primary,
      ));
    }
    if (meal.isLactoseFree) {
      tags.add(const DietTag(
        label: 'Lactose-Free',
        icon: Icons.water_drop_outlined,
        color: AppColors.catSeafood,
      ));
    }
    if (meal.isVegan) {
      tags.add(const DietTag(
        label: 'Vegan',
        icon: Icons.eco_rounded,
        color: AppColors.success,
      ));
    }
    if (meal.isVegetarian) {
      tags.add(const DietTag(
        label: 'Vegetarian',
        icon: Icons.spa_outlined,
        color: AppColors.success,
      ));
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Information',
          style: theme.textTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags,
        ),
      ],
    );
  }

  Widget _buildIngredientsSection(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Container(
      key: const ValueKey('ingredients_tab'),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: List.generate(
          meal.ingredients.length,
          (index) {
            final isLast = index == meal.ingredients.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          meal.ingredients[index],
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    thickness: 0.8,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepsSection(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return ListView.builder(
      key: const ValueKey('steps_tab'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: meal.steps.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  meal.steps[index],
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    AuthProvider authProvider,
    CartProvider cartProvider,
    bool inCart,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalPrice = meal.price * _quantity;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewPadding.bottom + 14,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Quantity selector
          QuantitySelector(
            quantity: _quantity,
            onIncrease: () => setState(() => _quantity++),
            onDecrease: () {
              if (_quantity > 1) setState(() => _quantity--);
            },
          ),
          const SizedBox(width: 14),

          // Add to Cart Button
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _addingToCart
                    ? null
                    : () => _handleAddToCart(context, authProvider, cartProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _addingToCart
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_bag_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Add · ${AppFormatters.price(totalPrice)}',
                            style: AppTextStyles.button.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAddToCart(
    BuildContext context,
    AuthProvider authProvider,
    CartProvider cartProvider,
  ) async {
    setState(() => _addingToCart = true);
    final userId = authProvider.effectiveUserId;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    for (int i = 0; i < _quantity; i++) {
      await cartProvider.addToCart(userId, meal);
    }

    if (!mounted) return;
    setState(() => _addingToCart = false);

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text('🛒 Added $_quantity x "${meal.title}" to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.amberAccent,
          onPressed: () => navigator.pop(),
        ),
      ),
    );
  }
}
