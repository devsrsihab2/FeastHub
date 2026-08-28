import 'package:first_project/data/database/app_database.dart';

class FavoriteRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<String>> getFavoriteMealIds(String userId) async {
    final rows = await _db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => r['meal_id'] as String).toList();
  }

  Future<bool> isFavorite(String userId, String mealId) async {
    final rows = await _db.query(
      'favorites',
      where: 'user_id = ? AND meal_id = ?',
      whereArgs: [userId, mealId],
    );
    return rows.isNotEmpty;
  }

  Future<void> addFavorite(String userId, String mealId) async {
    await _db.insert('favorites', {
      'user_id': userId,
      'meal_id': mealId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavorite(String userId, String mealId) async {
    await _db.delete(
      'favorites',
      where: 'user_id = ? AND meal_id = ?',
      whereArgs: [userId, mealId],
    );
  }

  Future<void> clearAll(String userId) async {
    await _db.delete('favorites', where: 'user_id = ?', whereArgs: [userId]);
  }
}
