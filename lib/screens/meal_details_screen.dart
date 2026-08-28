import 'package:first_project/model/meal.dart';
import 'package:first_project/widgets/meal_details.dart';
import 'package:flutter/material.dart';


class MealDetailsScreen extends StatelessWidget {
  const MealDetailsScreen({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    return MealDetails(meal: meal);
  }
}
