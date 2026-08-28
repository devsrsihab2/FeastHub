import 'package:first_project/data/repositories/cart_repository.dart';
import 'package:first_project/data/repositories/meal_repository.dart';
import 'package:first_project/model/cart_item.dart';
import 'package:first_project/model/meal.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final CartRepository _cartRepo = CartRepository();
  final MealRepository _mealRepo = MealRepository();

  List<CartItem> _items = [];
  bool _isLoading = false;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;

  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.subtotal);

  double get deliveryFee => _items.isEmpty ? 0.0 : 3.00;

  double get total => subtotal + deliveryFee;

  bool containsMeal(String mealId) =>
      _items.any((item) => item.meal.id == mealId);

  int quantityOf(String mealId) {
    try {
      return _items.firstWhere((i) => i.meal.id == mealId).quantity;
    } catch (_) {
      return 0;
    }
  }

  Future<void> loadCart(String userId) async {
    _isLoading = true;
    notifyListeners();

    final quantityMap = await _cartRepo.getCartItems(userId);
    final cartItems = <CartItem>[];

    for (final entry in quantityMap.entries) {
      final meal = await _mealRepo.getById(entry.key);
      if (meal != null) {
        cartItems.add(CartItem(meal: meal, quantity: entry.value));
      }
    }

    _items = cartItems;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addToCart(String userId, Meal meal) async {
    final existingIndex = _items.indexWhere((i) => i.meal.id == meal.id);
    if (existingIndex >= 0) {
      final current = _items[existingIndex];
      _items[existingIndex] = current.copyWith(quantity: current.quantity + 1);
    } else {
      _items.add(CartItem(meal: meal, quantity: 1));
    }
    await _cartRepo.addItem(userId, meal.id);
    notifyListeners();
  }

  Future<void> increaseQuantity(String userId, String mealId) async {
    final index = _items.indexWhere((i) => i.meal.id == mealId);
    if (index < 0) return;
    final current = _items[index];
    _items[index] = current.copyWith(quantity: current.quantity + 1);
    await _cartRepo.setQuantity(userId, mealId, _items[index].quantity);
    notifyListeners();
  }

  Future<void> decreaseQuantity(String userId, String mealId) async {
    final index = _items.indexWhere((i) => i.meal.id == mealId);
    if (index < 0) return;
    final current = _items[index];
    if (current.quantity <= 1) {
      await removeItem(userId, mealId);
    } else {
      _items[index] = current.copyWith(quantity: current.quantity - 1);
      await _cartRepo.setQuantity(userId, mealId, _items[index].quantity);
      notifyListeners();
    }
  }

  Future<void> removeItem(String userId, String mealId) async {
    _items.removeWhere((i) => i.meal.id == mealId);
    await _cartRepo.removeItem(userId, mealId);
    notifyListeners();
  }

  Future<void> clearCart(String userId) async {
    _items = [];
    await _cartRepo.clearCart(userId);
    notifyListeners();
  }

  void clear() {
    _items = [];
    notifyListeners();
  }
}
