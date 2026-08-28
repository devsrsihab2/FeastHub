import 'package:first_project/model/meal.dart';
import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final List<Meal> _favoriteMeals = [];

  List<Meal> get favoriteMeals => _favoriteMeals;

  bool isFavorite(Meal meal) => _favoriteMeals.contains(meal);

  // true = added, false = removed — caller কে জানানোর জন্য return করছি
  bool toggleFavorite(Meal meal) {
    final isExisting = _favoriteMeals.contains(meal);
    if (isExisting) {
      _favoriteMeals.remove(meal);
    } else {
      _favoriteMeals.add(meal);
    }
    notifyListeners();
    return !isExisting;
  }
}
