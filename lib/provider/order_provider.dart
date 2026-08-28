import 'package:first_project/data/repositories/order_repository.dart';
import 'package:first_project/model/cart_item.dart';
import 'package:first_project/model/order.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repo = OrderRepository();
  final _uuid = const Uuid();

  List<AppOrder> _orders = [];
  AppOrder? _lastOrder;
  bool _isLoading = false;
  bool _isPlacingOrder = false;

  List<AppOrder> get orders => _orders;
  AppOrder? get lastOrder => _lastOrder;
  bool get isLoading => _isLoading;
  bool get isPlacingOrder => _isPlacingOrder;

  Future<void> loadOrders(String userId) async {
    _isLoading = true;
    notifyListeners();
    _orders = await _repo.getOrdersForUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<AppOrder?> placeOrder({
    required String userId,
    required List<CartItem> cartItems,
  }) async {
    if (cartItems.isEmpty) return null;

    _isPlacingOrder = true;
    notifyListeners();

    final orderItems = cartItems
        .map((ci) => OrderItem(
              id: _uuid.v4(),
              orderId: '',
              mealId: ci.meal.id,
              mealTitle: ci.meal.title,
              price: ci.meal.price,
              quantity: ci.quantity,
            ))
        .toList();

    try {
      final order = await _repo.createOrder(
        userId: userId,
        items: orderItems,
      );
      _lastOrder = order;
      _orders.insert(0, order);
      _isPlacingOrder = false;
      notifyListeners();
      return order;
    } catch (e) {
      _isPlacingOrder = false;
      notifyListeners();
      return null;
    }
  }

  void clear() {
    _orders = [];
    _lastOrder = null;
    notifyListeners();
  }
}
