import 'package:first_project/data/repositories/favorite_repository.dart';
import 'package:first_project/data/repositories/meal_repository.dart';
import 'package:first_project/model/meal.dart';
import 'package:flutter/material.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoriteRepository _repo = FavoriteRepository();
  final MealRepository _mealRepo = MealRepository();

  List<Meal> _favoriteMeals = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = false;

  List<Meal> get favoriteMeals => _favoriteMeals;
  bool get isLoading => _isLoading;

  bool isFavorite(String mealId) => _favoriteIds.contains(mealId);

  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    final ids = await _repo.getFavoriteMealIds(userId);
    _favoriteIds = ids.toSet();

    final meals = <Meal>[];
    for (final id in ids) {
      final meal = await _mealRepo.getById(id);
      if (meal != null) meals.add(meal);
    }
    _favoriteMeals = meals;
    _isLoading = false;
    notifyListeners();
  }

  /// Returns true if added, false if removed.
  Future<bool> toggleFavorite(String userId, Meal meal) async {
    final wasFav = _favoriteIds.contains(meal.id);
    if (wasFav) {
      _favoriteIds.remove(meal.id);
      _favoriteMeals.removeWhere((m) => m.id == meal.id);
      await _repo.removeFavorite(userId, meal.id);
    } else {
      _favoriteIds.add(meal.id);
      _favoriteMeals.insert(0, meal);
      await _repo.addFavorite(userId, meal.id);
    }
    notifyListeners();
    return !wasFav;
  }

  void clear() {
    _favoriteMeals = [];
    _favoriteIds = {};
    notifyListeners();
  }
}
