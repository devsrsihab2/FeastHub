import 'package:first_project/data/database/app_database.dart';
import 'package:first_project/model/meal.dart';

class MealRepository {
  final AppDatabase _db = AppDatabase.instance;

  /// Fetches all meals with their category IDs.
  Future<List<Meal>> getAll() async {
    return _queryMeals();
  }

  /// Fetches meals belonging to a specific category.
  Future<List<Meal>> getByCategory(String categoryId) async {
    return _queryMeals(categoryId: categoryId);
  }

  /// Search meals by title, description, or ingredients.
  Future<List<Meal>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final q = '%${query.trim()}%';
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT m.*
      FROM meals m
      WHERE m.title LIKE ?
         OR m.description LIKE ?
         OR m.ingredients LIKE ?
      ORDER BY m.rating DESC
    ''', [q, q, q]);
    return _attachCategories(rows);
  }

  /// Fetch a single meal by ID.
  Future<Meal?> getById(String id) async {
    final rows = await _db.query('meals', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    final categories = await _getCategoryIds(id);
    return Meal.fromMap(rows.first, categories);
  }

  /// Fetch top-rated meals (for home screen).
  Future<List<Meal>> getPopular({int limit = 10}) async {
    return _queryMeals(orderBy: 'm.rating DESC, m.review_count DESC', limit: limit);
  }

  // ── Private helpers ───────────────────────────────────────────

  Future<List<Meal>> _queryMeals({
    String? categoryId,
    String? orderBy,
    int? limit,
  }) async {
    final db = await _db.database;

    String sql;
    List<Object?> args = [];

    if (categoryId != null) {
      sql = '''
        SELECT DISTINCT m.*
        FROM meals m
        INNER JOIN meal_categories mc ON mc.meal_id = m.id
        WHERE mc.category_id = ?
        ORDER BY ${orderBy ?? 'm.title ASC'}
        ${limit != null ? 'LIMIT $limit' : ''}
      ''';
      args = [categoryId];
    } else {
      sql = '''
        SELECT m.*
        FROM meals m
        ORDER BY ${orderBy ?? 'm.title ASC'}
        ${limit != null ? 'LIMIT $limit' : ''}
      ''';
    }

    final rows = await db.rawQuery(sql, args);
    return _attachCategories(rows);
  }

  Future<List<Meal>> _attachCategories(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return [];
    final meals = <Meal>[];
    for (final row in rows) {
      final mealId = row['id'] as String;
      final categories = await _getCategoryIds(mealId);
      meals.add(Meal.fromMap(row, categories));
    }
    return meals;
  }

  Future<List<String>> _getCategoryIds(String mealId) async {
    final catRows = await _db.query(
      'meal_categories',
      where: 'meal_id = ?',
      whereArgs: [mealId],
    );
    return catRows.map((r) => r['category_id'] as String).toList();
  }
}
