import 'package:first_project/data/database/app_database.dart';
import 'package:first_project/model/category.dart';

class CategoryRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<Category>> getAll() async {
    final rows = await _db.query('categories', orderBy: 'sort_order ASC');
    return rows.map(Category.fromMap).toList();
  }

  Future<Category?> getById(String id) async {
    final rows = await _db.query('categories', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Category.fromMap(rows.first);
  }
}
