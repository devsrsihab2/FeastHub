import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:first_project/data/database/app_database.dart';
import 'package:first_project/model/user.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  /// Hash a password using SHA-256. Not production-grade but sufficient for local/demo auth.
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  /// Create a new user. Returns the user if successful.
  /// Throws [DuplicateEmailException] if email already exists.
  Future<AppUser> createUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final existing = await getUserByEmail(email);
    if (existing != null) throw DuplicateEmailException();

    final user = AppUser(
      id: _uuid.v4(),
      name: name,
      email: email.toLowerCase().trim(),
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now().toIso8601String(),
    );

    await _db.insert('users', user.toMap());
    return user;
  }

  /// Authenticate a user by email and password.
  /// Returns the user if credentials are valid, null otherwise.
  Future<AppUser?> authenticate(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) return null;
    final hash = _hashPassword(password);
    if (user.passwordHash != hash) return null;
    return user;
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final rows = await _db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase().trim()],
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> getUserById(String id) async {
    final rows = await _db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<void> updateName(String userId, String name) async {
    await _db.update(
      'users',
      {'name': name},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }
}

class DuplicateEmailException implements Exception {
  @override
  String toString() => 'An account with this email already exists.';
}
