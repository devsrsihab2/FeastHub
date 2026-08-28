import 'package:first_project/data/repositories/meal_repository.dart';
import 'package:first_project/model/meal.dart';
import 'package:flutter/material.dart';

class MealProvider extends ChangeNotifier {
  final MealRepository _repo = MealRepository();

  List<Meal> _allMeals = [];
  List<Meal> _popularMeals = [];
  List<Meal> _searchResults = [];
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';

  List<Meal> get allMeals => _allMeals;
  List<Meal> get popularMeals => _popularMeals;
  List<Meal> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String get searchQuery => _searchQuery;

  Future<void> loadAll() async {
    if (_allMeals.isNotEmpty) return;
    _isLoading = true;
    notifyListeners();
    _allMeals = await _repo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPopular({int limit = 12}) async {
    if (_popularMeals.isNotEmpty) return;
    _popularMeals = await _repo.getPopular(limit: limit);
    notifyListeners();
  }

  Future<List<Meal>> getMealsByCategory(String categoryId) async {
    return _repo.getByCategory(categoryId);
  }

  Future<Meal?> getMealById(String id) async {
    // Check cache first
    try {
      return _allMeals.firstWhere((m) => m.id == id);
    } catch (_) {
      return _repo.getById(id);
    }
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }
    _isSearching = true;
    notifyListeners();
    _searchResults = await _repo.search(query);
    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    notifyListeners();
  }
}
