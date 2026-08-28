import 'package:first_project/model/meal.dart';
import 'package:first_project/widgets/meal_item.dart';
import 'package:first_project/widgets/not_found.dart';
import 'package:flutter/material.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key, this.title, required this.meals});

  final String? title;
  final List<Meal> meals;

  @override
  Widget build(BuildContext context) {
    Widget content = ListView.builder(
      itemCount: meals.length,
      itemBuilder: (ctx, index) => MealItem(meal: meals[index]),
    );
    if (meals.isEmpty) {
      content = NotFoundWideget();
    }

    if (title == null) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title!)),

      body: content,
    );
  }
}
