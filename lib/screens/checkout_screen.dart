import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/core/utils/formatters.dart';
import 'package:first_project/provider/auth_provider.dart';
import 'package:first_project/provider/cart_provider.dart';
import 'package:first_project/provider/order_provider.dart';
import 'package:first_project/screens/auth/login_screen.dart';
import 'package:first_project/screens/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'cash';
  final TextEditingController _addressController = TextEditingController(
      text: '123 Main Street, Downtown');

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Checkout', style: AppTextStyles.heading),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Order Summary ─────────────────────────────────────
          _Section(
            title: 'Order Summary',
            child: Column(
              children: [
                ...cart.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(item.meal.title,
                                style: AppTextStyles.body),
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
                _SummaryRow('Subtotal', AppFormatters.price(cart.subtotal)),
                const SizedBox(height: 6),
                _SummaryRow(
                    'Delivery Fee', AppFormatters.price(cart.deliveryFee)),
                const SizedBox(height: 6),
                _SummaryRow(
                  'Total',
                  AppFormatters.price(cart.total),
                  bold: true,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Delivery Address ──────────────────────────────────
          _Section(
            title: 'Delivery Address',
            child: TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                prefixIcon:
                    const Icon(Icons.location_on_rounded, color: AppColors.primary),
                hintText: 'Enter delivery address',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Payment Method ────────────────────────────────────
          _Section(
            title: 'Payment Method',
            child: Column(
              children: [
                _PaymentOption(
                  label: 'Cash on Delivery',
                  icon: Icons.money_rounded,
                  value: 'cash',
                  groupValue: _selectedPayment,
                  onChanged: (v) => setState(() => _selectedPayment = v!),
                ),
                const SizedBox(height: 8),
                _PaymentOption(
                  label: 'Card (Demo)',
                  icon: Icons.credit_card_rounded,
                  value: 'card',
                  groupValue: _selectedPayment,
                  onChanged: (v) => setState(() => _selectedPayment = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
      bottomNavigationBar: _PlaceOrderBar(
        cart: cart,
        auth: auth,
        orderProvider: orderProvider,
        addressController: _addressController,
      ),
    );
  }
}

class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar({
    required this.cart,
    required this.auth,
    required this.orderProvider,
    required this.addressController,
  });

  final CartProvider cart;
  final AuthProvider auth;
  final OrderProvider orderProvider;
  final TextEditingController addressController;

  @override
  Widget build(BuildContext context) {
    final isPlacing = context.watch<OrderProvider>().isPlacingOrder;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewPadding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: AppTextStyles.title),
              Text(AppFormatters.price(cart.total),
                  style: AppTextStyles.price),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isPlacing
                  ? null
                  : () => _placeOrder(context),
              child: isPlacing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Place Order'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (!auth.isLoggedIn) {
      final didLogin = await navigator.push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (didLogin != true || !context.mounted) return;
    }

    final order = await orderProvider.placeOrder(
      userId: auth.effectiveUserId,
      cartItems: cart.items,
    );

    if (order == null || !context.mounted) return;
    await cart.clearCart(auth.effectiveUserId);

    navigator.pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, secondary) => FadeTransition(
          opacity: animation,
          child: OrderSuccessScreen(order: order),
        ),
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => route.isFirst,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value,
      {this.bold = false, this.color = AppColors.textPrimary});
  final String label;
  final String value;
  final bool bold;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontWeight: bold ? FontWeight.w600 : null)),
        Text(value,
            style: AppTextStyles.body.copyWith(
                color: color,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });
  final String label;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 12),
            Text(label,
                style: AppTextStyles.body.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : null)),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
