import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/core/utils/formatters.dart';
import 'package:first_project/model/order.dart';
import 'package:first_project/provider/auth_provider.dart';
import 'package:first_project/provider/cart_provider.dart';
import 'package:first_project/provider/order_provider.dart';
import 'package:first_project/screens/auth/login_screen.dart';
import 'package:first_project/screens/cart_screen.dart';
import 'package:first_project/widgets/cart_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      context.read<OrderProvider>().loadOrders(auth.currentUser!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: Text('Orders', style: AppTextStyles.heading)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.receipt_long_outlined,
                    size: 64, color: AppColors.textDisabled),
                const SizedBox(height: 20),
                Text('Sign in to view orders', style: AppTextStyles.heading),
                const SizedBox(height: 8),
                Text('Your order history will appear here.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Orders', style: AppTextStyles.heading),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            icon: CartBadge(
              count: context.watch<CartProvider>().totalCount,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.orders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_outlined,
                            size: 64, color: AppColors.textDisabled),
                        const SizedBox(height: 20),
                        Text('No orders yet', style: AppTextStyles.heading),
                        const SizedBox(height: 8),
                        Text('Your completed orders will appear here.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderProvider.orders.length,
                  itemBuilder: (ctx, i) =>
                      _OrderCard(order: orderProvider.orders[i]),
                ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});
  final AppOrder order;

  @override
  Widget build(BuildContext context) {
    final statusColor = order.status == OrderStatus.delivered
        ? AppColors.success
        : order.status == OrderStatus.cancelled
            ? AppColors.error
            : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Order ${AppFormatters.orderNumber(order.id)}',
                  style: AppTextStyles.title,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.status.label,
                    style: AppTextStyles.label.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              AppFormatters.date(DateTime.parse(order.createdAt)),
              style: AppTextStyles.caption,
            ),
            const Divider(height: 20),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(item.mealTitle,
                            style: AppTextStyles.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Text('x${item.quantity}',
                          style: AppTextStyles.bodySmall),
                      const SizedBox(width: 12),
                      Text(AppFormatters.price(item.subtotal),
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${order.items.length} item${order.items.length == 1 ? '' : 's'}',
                    style: AppTextStyles.bodySmall),
                Text(
                  AppFormatters.price(order.total),
                  style: AppTextStyles.price.copyWith(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
