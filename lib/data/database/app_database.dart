import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_seed.dart';

/// Manages SQLite database lifecycle: open, create tables, migrate, seed.
class AppDatabase {
  AppDatabase._();
  static final AppDatabase instance = AppDatabase._();

  static Database? _db;
  static const int _version = 2;
  static const String _dbName = 'feasthub.db';

  Future<Database> get database async {
    _db ??= await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await DatabaseSeed.seed(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Re-seed updated meals and categories with local assets
      await db.delete('meal_categories');
      await db.delete('meals');
      await db.delete('categories');
      await DatabaseSeed.seed(db);
    }
  }

  Future<void> _createTables(Database db) async {
    // Categories
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id          TEXT PRIMARY KEY,
        title       TEXT NOT NULL,
        color_hex   TEXT NOT NULL,
        icon_code   INTEGER NOT NULL,
        sort_order  INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Meals
    await db.execute('''
      CREATE TABLE IF NOT EXISTS meals (
        id              TEXT PRIMARY KEY,
        title           TEXT NOT NULL,
        description     TEXT NOT NULL DEFAULT '',
        image_url       TEXT NOT NULL,
        price           REAL NOT NULL,
        duration        INTEGER NOT NULL,
        complexity      TEXT NOT NULL,
        affordability   TEXT NOT NULL,
        is_gluten_free  INTEGER NOT NULL DEFAULT 0,
        is_lactose_free INTEGER NOT NULL DEFAULT 0,
        is_vegan        INTEGER NOT NULL DEFAULT 0,
        is_vegetarian   INTEGER NOT NULL DEFAULT 0,
        rating          REAL NOT NULL DEFAULT 4.0,
        review_count    INTEGER NOT NULL DEFAULT 0,
        ingredients     TEXT NOT NULL DEFAULT '[]',
        steps           TEXT NOT NULL DEFAULT '[]',
        created_at      TEXT NOT NULL
      )
    ''');

    // Meal ↔ Category (many-to-many)
    await db.execute('''
      CREATE TABLE IF NOT EXISTS meal_categories (
        meal_id     TEXT NOT NULL,
        category_id TEXT NOT NULL,
        PRIMARY KEY (meal_id, category_id),
        FOREIGN KEY (meal_id) REFERENCES meals(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // Users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id            TEXT PRIMARY KEY,
        name          TEXT NOT NULL,
        email         TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at    TEXT NOT NULL
      )
    ''');

    // Favorites
    await db.execute('''
      CREATE TABLE IF NOT EXISTS favorites (
        user_id    TEXT NOT NULL,
        meal_id    TEXT NOT NULL,
        created_at TEXT NOT NULL,
        PRIMARY KEY (user_id, meal_id)
      )
    ''');

    // Cart items
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cart_items (
        user_id    TEXT NOT NULL,
        meal_id    TEXT NOT NULL,
        quantity   INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        PRIMARY KEY (user_id, meal_id)
      )
    ''');

    // Orders
    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id           TEXT PRIMARY KEY,
        user_id      TEXT NOT NULL,
        subtotal     REAL NOT NULL,
        delivery_fee REAL NOT NULL,
        total        REAL NOT NULL,
        status       TEXT NOT NULL DEFAULT 'confirmed',
        created_at   TEXT NOT NULL
      )
    ''');

    // Order items
    await db.execute('''
      CREATE TABLE IF NOT EXISTS order_items (
        id          TEXT PRIMARY KEY,
        order_id    TEXT NOT NULL,
        meal_id     TEXT NOT NULL,
        meal_title  TEXT NOT NULL,
        price       REAL NOT NULL,
        quantity    INTEGER NOT NULL,
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');

    // Create useful indexes
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_meal_categories_category ON meal_categories(category_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_cart_user ON cart_items(user_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id)',
    );
  }

  /// Convenience: run inside a transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return db.transaction(action);
  }

  /// Convenience: execute a query returning rows
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return db.query(table,
        where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit);
  }

  /// Convenience: raw query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? args,
  ]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  /// Convenience: insert
  Future<int> insert(String table, Map<String, dynamic> values,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    final db = await database;
    return db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
  }

  /// Convenience: update
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  /// Convenience: delete
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }
}
