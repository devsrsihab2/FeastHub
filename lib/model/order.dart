enum OrderStatus { confirmed, preparing, outForDelivery, delivered, cancelled }

extension OrderStatusExtension on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get emoji {
    switch (this) {
      case OrderStatus.confirmed:
        return '✓';
      case OrderStatus.preparing:
        return '👨‍🍳';
      case OrderStatus.outForDelivery:
        return '🛵';
      case OrderStatus.delivered:
        return '✅';
      case OrderStatus.cancelled:
        return '✗';
    }
  }
}

class OrderItem {
  const OrderItem({
    required this.id,
    required this.orderId,
    required this.mealId,
    required this.mealTitle,
    required this.price,
    required this.quantity,
  });

  final String id;
  final String orderId;
  final String mealId;
  final String mealTitle;
  final double price;
  final int quantity;

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'meal_id': mealId,
      'meal_title': mealTitle,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] as String,
      orderId: map['order_id'] as String,
      mealId: map['meal_id'] as String,
      mealTitle: map['meal_title'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}

class AppOrder {
  const AppOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final OrderStatus status;
  final String createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'total': total,
      'status': status.name,
      'created_at': createdAt,
    };
  }

  factory AppOrder.fromMap(Map<String, dynamic> map, List<OrderItem> items) {
    return AppOrder(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      items: items,
      subtotal: (map['subtotal'] as num).toDouble(),
      deliveryFee: (map['delivery_fee'] as num).toDouble(),
      total: (map['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.confirmed,
      ),
      createdAt: map['created_at'] as String,
    );
  }
}
