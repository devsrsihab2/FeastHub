import 'package:first_project/model/meal.dart';
import 'package:first_project/widgets/meal_details.dart';
import 'package:flutter/material.dart';
import 'package:first_project/widgets/not_found.dart';

class MealsDetailsScreen extends StatelessWidget {
  const MealsDetailsScreen({
    super.key,
    required this.title,
    required this.meal,
  });

  final String title;
  final Meal? meal;

  @override
  Widget build(BuildContext context) {
    Widget content = meal == null
        ? const NotFoundWideget()
        : MealDetails(meal: meal!);

    return Scaffold(
      // appBar: AppBar(title: Text(title)),
      body: content,
    );
  }
}
