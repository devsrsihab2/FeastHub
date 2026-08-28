import 'package:first_project/model/meal.dart';
import 'package:first_project/provider/favorites_provider.dart';
import 'package:first_project/widgets/circle_icon_button.dart';
import 'package:first_project/widgets/diet_tag.dart';
import 'package:first_project/widgets/segment_button.dart';
import 'package:first_project/widgets/stat_item.dart';
import 'package:first_project/widgets/vertical_divider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:first_project/data/dummy_data.dart';

class MealDetails extends StatefulWidget {
  const MealDetails({super.key, required this.meal});

  final Meal meal;
  @override
  State<MealDetails> createState() => _MealDetailsState();
}

class _MealDetailsState extends State<MealDetails> {
  int _tabIndex = 0; // 0 = Ingredients, 1 = Steps

  Meal get meal => widget.meal;

  String get complexityText {
    switch (meal.complexity) {
      case Complexity.simple:
        return 'Simple';
      case Complexity.challenging:
        return 'Challenging';
      case Complexity.hard:
        return 'Hard';
    }
  }

  String get affordabilityText {
    switch (meal.affordability) {
      case Affordability.affordable:
        return 'Affordable';
      case Affordability.pricey:
        return 'Pricey';
      case Affordability.luxurious:
        return 'Luxurious';
    }
  }

  String get categoryNames {
    return meal.categories
        .map((id) {
          final category = availableCategories.firstWhere(
            (cat) => cat.id == id,
          );
          return category.title;
        })
        .join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    final favoritesProvider = context.watch<FavoritesProvider>();
    final isFav = favoritesProvider.isFavorite(meal);

    return CustomScrollView(
      slivers: [
        // ---- Image header ----
        SliverAppBar(
          expandedHeight: size.height * 0.42,
          pinned: true,
          stretch: true,
          backgroundColor: colorScheme.surface,
          leading: CircleIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),
          actions: [
            CircleIconButton(
              icon: isFav ? Icons.favorite : Icons.favorite_border,
              onTap: () {
                final wasAdded = context
                    .read<FavoritesProvider>()
                    .toggleFavorite(meal);

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      wasAdded
                          ? 'Added to favorites'
                          : 'Removed from favorites',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: meal.id,
              child: FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: NetworkImage(meal.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.fadeTitle,
            ],
          ),
        ),

        // sliver box adapter
        SliverToBoxAdapter(
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
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    meal.title,
                    style: theme.textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Category-style subtitle
                  Text(
                    categoryNames,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stat row (duration / complexity / affordability)
                  Row(
                    children: [
                      // duration
                      StatItem(
                        icon: Icons.schedule_rounded,
                        value: '${meal.duration}',
                        unit: 'min',
                        color: colorScheme.primary,
                      ),
                      CustomVerticalDivider(),
                      // challenge
                      StatItem(
                        icon: Icons.local_fire_department_rounded,
                        value: complexityText,
                        unit: 'level',
                        color: colorScheme.primary,
                      ),
                      CustomVerticalDivider(),
                      //affordability
                      StatItem(
                        icon: Icons.payments_rounded,
                        value: affordabilityText,
                        unit: 'price',
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dietary tags
                  if (meal.isVegan ||
                      meal.isVegetarian ||
                      meal.isGlutenFree ||
                      meal.isLactoseFree)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // Vegan
                        if (meal.isVegan)
                          const DietTag(
                            label: 'Vegan',
                            icon: Icons.eco_rounded,
                            color: Color(0xFF2E7D32),
                          ),

                        // Vegetarian
                        if (meal.isVegetarian)
                          const DietTag(
                            label: 'Vegetarian',
                            icon: Icons.spa_rounded,
                            color: Color(0xFF558B2F),
                          ),

                        // Gluten-free
                        if (meal.isGlutenFree)
                          const DietTag(
                            label: 'Gluten-free',
                            icon: Icons.grain_rounded,
                            color: Color(0xFFEF6C00),
                          ),

                        // Lactose-free
                        if (meal.isLactoseFree)
                          const DietTag(
                            label: 'Lactose-free',
                            icon: Icons.no_drinks_rounded,
                            color: Color(0xFF1565C0),
                          ),
                      ],
                    ),
                  const SizedBox(height: 28),

                  // segment Tab controll
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        // Ingredients btn
                        SegmentButton(
                          label: 'Ingredients (${meal.ingredients.length})',
                          selected: _tabIndex == 0,
                          onTap: () => setState(() => _tabIndex = 0),
                        ),

                        // Steps btn
                        SegmentButton(
                          label: 'Steps (${meal.steps.length})',
                          selected: _tabIndex == 1,
                          onTap: () => setState(() => _tabIndex = 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tab content
                  if (_tabIndex == 0)
                    ...meal.ingredients.map(
                      (ingredient) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                ingredient,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...meal.steps.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                entry.value,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
