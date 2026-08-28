import 'package:first_project/data/repositories/category_repository.dart';
import 'package:first_project/model/category.dart';
import 'package:flutter/material.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepository _repo = CategoryRepository();

  List<Category> _categories = [];
  bool _isLoading = false;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> load() async {
    if (_categories.isNotEmpty) return; // Already loaded
    _isLoading = true;
    notifyListeners();
    _categories = await _repo.getAll();
    _isLoading = false;
    notifyListeners();
  }

  Category? findById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns category names for a list of IDs (used in meal details).
  String getCategoryNames(List<String> ids) {
    return ids
        .map((id) => findById(id)?.title ?? '')
        .where((name) => name.isNotEmpty)
        .join(' • ');
  }
}
