import 'package:first_project/model/meal.dart';
import 'package:first_project/screens/meal_details.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:first_project/widgets/info_badge.dart';

class MealItem extends StatelessWidget {
  const MealItem({super.key, required this.meal});

  final Meal meal;

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

  // select meal card
  void _selectMeal(BuildContext context, Meal meal) {
    // navigator
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => MealsDetailsScreen(title: meal.title, meal: meal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: InkWell(
        onTap: () {
          _selectMeal(context, meal);
        },
        child: Stack(
          children: [
            FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: NetworkImage(meal.imageUrl),
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),

            // label
            Positioned(
              top: 12,
              right: 12,
              child: InfoBadge(
                icon: Icons.schedule,
                label: '${meal.duration} min',
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,

              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      meal.title,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 4),

                        Text(
                          complexityText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 14),

                        Icon(
                          Icons.attach_money,
                          size: 16,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 4),

                        Text(
                          affordabilityText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
