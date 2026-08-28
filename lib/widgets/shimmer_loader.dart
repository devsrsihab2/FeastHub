import 'package:first_project/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Skeleton shimmer loading placeholder for meal cards.
class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({super.key, this.height = 240, this.borderRadius = 16});

  final double height;
  final double borderRadius;

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                AppColors.surfaceVariant,
                AppColors.divider,
                AppColors.surfaceVariant,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Full-page shimmer grid for the categories screen.
class CategoryShimmerGrid extends StatelessWidget {
  const CategoryShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 10,
      itemBuilder: (ctx, i) => const ShimmerLoader(height: 130, borderRadius: 20),
    );
  }
}

/// Full-page shimmer list for the meals screen.
class MealListShimmer extends StatelessWidget {
  const MealListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (ctx, i) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: ShimmerLoader(height: 240),
      ),
    );
  }
}
