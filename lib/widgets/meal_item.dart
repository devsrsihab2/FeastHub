import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/core/utils/formatters.dart';
import 'package:first_project/widgets/app_image.dart';
import 'package:first_project/model/meal.dart';
import 'package:first_project/provider/auth_provider.dart';
import 'package:first_project/provider/favorites_provider.dart';
import 'package:first_project/screens/meal_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Professional meal card used in lists and grids.
class MealItem extends StatelessWidget {
  const MealItem({super.key, required this.meal, this.animationDelay});

  final Meal meal;
  final Duration? animationDelay;

  @override
  Widget build(BuildContext context) {
    if (animationDelay != null) {
      return _AnimatedMealCard(meal: meal, delay: animationDelay!);
    }
    return _MealCard(meal: meal);
  }
}

class _AnimatedMealCard extends StatefulWidget {
  const _AnimatedMealCard({required this.meal, required this.delay});
  final Meal meal;
  final Duration delay;

  @override
  State<_AnimatedMealCard> createState() => _AnimatedMealCardState();
}

class _AnimatedMealCardState extends State<_AnimatedMealCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: _MealCard(meal: widget.meal),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final favProvider = context.watch<FavoritesProvider>();
    final authProvider = context.read<AuthProvider>();
    final isFav = favProvider.isFavorite(meal.id);

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
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ──────────────────────────────────────
              Stack(
                children: [
                    Hero(
                      tag: 'meal_image_${meal.id}',
                      child: AppImage(
                        imageUrl: meal.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholderIconSize: 48,
                      ),
                    ),
                  // gradient overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // duration badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _Badge(
                      icon: Icons.schedule_rounded,
                      label: AppFormatters.duration(meal.duration),
                    ),
                  ),
                  // favorite button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _FavButton(
                      isFav: isFav,
                      onTap: () {
                        final userId = authProvider.effectiveUserId;
                        context
                            .read<FavoritesProvider>()
                            .toggleFavorite(userId, meal);
                      },
                    ),
                  ),
                  // price on image
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: Text(
                      AppFormatters.price(meal.price),
                      style: AppTextStyles.price.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ── Info ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title,
                    ),
                    if (meal.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meal.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.star, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          meal.rating.toStringAsFixed(1),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${meal.reviewCount})',
                          style: AppTextStyles.caption,
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            meal.complexityLabel,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.label.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  const _FavButton({required this.isFav, required this.onTap});
  final bool isFav;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isFav
              ? AppColors.error.withValues(alpha: 0.9)
              : Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
