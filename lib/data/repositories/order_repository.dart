import 'package:first_project/data/database/app_database.dart';
import 'package:first_project/model/order.dart';
import 'package:uuid/uuid.dart';

class OrderRepository {
  final AppDatabase _db = AppDatabase.instance;
  final _uuid = const Uuid();

  static const double deliveryFee = 3.00;

  /// Create a new order from the given items. Clears cart afterwards is done by CartProvider.
  Future<AppOrder> createOrder({
    required String userId,
    required List<OrderItem> items,
  }) async {
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final total = subtotal + deliveryFee;
    final orderId = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    final order = AppOrder(
      id: orderId,
      userId: userId,
      items: items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      total: total,
      status: OrderStatus.confirmed,
      createdAt: now,
    );

    await _db.transaction((txn) async {
      await txn.insert('orders', order.toMap());
      for (final item in items) {
        await txn.insert('order_items', item.copyWith(orderId: orderId).toMap());
      }
    });

    return order;
  }

  Future<List<AppOrder>> getOrdersForUser(String userId) async {
    final orderRows = await _db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    final orders = <AppOrder>[];
    for (final row in orderRows) {
      final orderId = row['id'] as String;
      final itemRows = await _db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );
      final items = itemRows.map(OrderItem.fromMap).toList();
      orders.add(AppOrder.fromMap(row, items));
    }
    return orders;
  }

  Future<AppOrder?> getOrderById(String orderId) async {
    final rows = await _db.query('orders', where: 'id = ?', whereArgs: [orderId]);
    if (rows.isEmpty) return null;
    final itemRows = await _db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    final items = itemRows.map(OrderItem.fromMap).toList();
    return AppOrder.fromMap(rows.first, items);
  }
}

extension _OrderItemCopy on OrderItem {
  OrderItem copyWith({String? orderId}) {
    return OrderItem(
      id: id,
      orderId: orderId ?? this.orderId,
      mealId: mealId,
      mealTitle: mealTitle,
      price: price,
      quantity: quantity,
    );
  }
}
