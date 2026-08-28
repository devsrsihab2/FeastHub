import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/core/utils/formatters.dart';
import 'package:first_project/model/cart_item.dart';
import 'package:first_project/provider/auth_provider.dart';
import 'package:first_project/provider/cart_provider.dart';
import 'package:first_project/screens/checkout_screen.dart';
import 'package:first_project/screens/tabs.dart';
import 'package:first_project/widgets/app_image.dart';
import 'package:first_project/widgets/quantity_selector.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Cart', style: AppTextStyles.heading),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () {
                _showClearDialog(context, auth, cart);
              },
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.items.isEmpty
          ? _EmptyCart(context: context)
          : _CartBody(cart: cart, auth: auth),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : _CheckoutBar(cart: cart),
    );
  }

  void _showClearDialog(
      BuildContext context, AuthProvider auth, CartProvider cart) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart(auth.effectiveUserId);
              Navigator.pop(context);
            },
            child: Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.context});
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer,
              ),
              child: const Icon(Icons.shopping_cart_outlined,
                  size: 46, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text('Your cart is empty', style: AppTextStyles.heading),
            const SizedBox(height: 8),
            Text(
              'Add some delicious meals\nto get started!',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const TabsScreen()),
                    (route) => false,
                  );
                }
              },
              child: const Text('Browse Meals'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBody extends StatelessWidget {
  const _CartBody({required this.cart, required this.auth});
  final CartProvider cart;
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: cart.items.length,
      itemBuilder: (ctx, i) => _CartItemTile(
        item: cart.items[i],
        onIncrease: () =>
            cart.increaseQuantity(auth.effectiveUserId, cart.items[i].meal.id),
        onDecrease: () =>
            cart.decreaseQuantity(auth.effectiveUserId, cart.items[i].meal.id),
        onRemove: () =>
            cart.removeItem(auth.effectiveUserId, cart.items[i].meal.id),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AppImage(
                imageUrl: item.meal.imageUrl,
                width: 76,
                height: 76,
                fit: BoxFit.cover,
                placeholderIconSize: 32,
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.meal.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.price(item.meal.price),
                    style: AppTextStyles.priceSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      QuantitySelector(
                        quantity: item.quantity,
                        size: QuantitySelectorSize.small,
                        onIncrease: onIncrease,
                        onDecrease: onDecrease,
                        minQuantity: 0,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.cart});
  final CartProvider cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewPadding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Row('Subtotal', AppFormatters.price(cart.subtotal)),
          const SizedBox(height: 6),
          _Row('Delivery Fee', AppFormatters.price(cart.deliveryFee)),
          const Divider(height: 20),
          _Row(
            'Total',
            AppFormatters.price(cart.total),
            bold: true,
            priceColor: AppColors.primary,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
              child: Text(
                'Checkout · ${AppFormatters.price(cart.total)}',
                style: AppTextStyles.button,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value,
      {this.bold = false, this.priceColor = AppColors.textPrimary});
  final String label;
  final String value;
  final bool bold;
  final Color priceColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body.copyWith(
                fontWeight: bold ? FontWeight.w600 : null,
                color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.body.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: priceColor,
            )),
      ],
    );
  }
}
