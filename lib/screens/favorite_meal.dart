import 'package:first_project/provider/favorites_provider.dart';
import 'package:first_project/widgets/meal_item.dart';
import 'package:first_project/widgets/not_found.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key, this.title});

  final String? title;
  @override
  Widget build(BuildContext context) {
    // final meals = context.watch<FavoritesProvider>().favoriteMeals;
    final meals = context.watch<FavoritesProvider>().favoriteMeals;

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
