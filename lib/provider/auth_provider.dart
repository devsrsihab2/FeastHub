import 'package:first_project/data/repositories/user_repository.dart';
import 'package:first_project/model/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final UserRepository _userRepo = UserRepository();
  static const String _sessionKey = 'session_user_id';

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get effectiveUserId =>
      _currentUser?.id ?? 'guest';

  /// Restore session on app start.
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_sessionKey);
    if (userId != null) {
      _currentUser = await _userRepo.getUserById(userId);
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400)); // UX delay
    final user = await _userRepo.authenticate(email, password);

    _isLoading = false;
    if (user == null) {
      _errorMessage = 'Invalid email or password. Please try again.';
      notifyListeners();
      return false;
    }

    _currentUser = user;
    await _saveSession(user.id);
    notifyListeners();
    return true;
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));
    try {
      final user = await _userRepo.createUser(
        name: name,
        email: email,
        password: password,
      );
      _currentUser = user;
      await _saveSession(user.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } on DuplicateEmailException {
      _errorMessage = 'An account with this email already exists.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, userId);
  }
}
