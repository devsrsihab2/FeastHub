import 'package:first_project/model/meal.dart';

class CartItem {
  const CartItem({
    required this.meal,
    required this.quantity,
  });

  final Meal meal;
  final int quantity;

  double get subtotal => meal.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(meal: meal, quantity: quantity ?? this.quantity);
  }
}
