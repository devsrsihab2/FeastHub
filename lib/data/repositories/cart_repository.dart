import 'package:first_project/data/database/app_database.dart';
import 'package:sqflite/sqflite.dart';

class CartRepository {
  final AppDatabase _db = AppDatabase.instance;

  /// Returns map of meal_id → quantity for user.
  Future<Map<String, int>> getCartItems(String userId) async {
    final rows = await _db.query(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at ASC',
    );
    return {
      for (final row in rows)
        row['meal_id'] as String: row['quantity'] as int,
    };
  }

  Future<void> addItem(String userId, String mealId) async {
    final db = await _db.database;
    // Insert with quantity 1, or increment if already exists
    await db.rawInsert('''
      INSERT INTO cart_items (user_id, meal_id, quantity, created_at)
      VALUES (?, ?, 1, ?)
      ON CONFLICT(user_id, meal_id) DO UPDATE SET quantity = quantity + 1
    ''', [userId, mealId, DateTime.now().toIso8601String()]);
  }

  Future<void> setQuantity(String userId, String mealId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(userId, mealId);
      return;
    }
    final existing = await _db.query(
      'cart_items',
      where: 'user_id = ? AND meal_id = ?',
      whereArgs: [userId, mealId],
    );
    if (existing.isEmpty) {
      await _db.insert('cart_items', {
        'user_id': userId,
        'meal_id': mealId,
        'quantity': quantity,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else {
      await _db.update(
        'cart_items',
        {'quantity': quantity},
        where: 'user_id = ? AND meal_id = ?',
        whereArgs: [userId, mealId],
      );
    }
  }

  Future<void> removeItem(String userId, String mealId) async {
    await _db.delete(
      'cart_items',
      where: 'user_id = ? AND meal_id = ?',
      whereArgs: [userId, mealId],
    );
  }

  Future<void> clearCart(String userId) async {
    await _db.delete('cart_items', where: 'user_id = ?', whereArgs: [userId]);
  }
}
