import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

/// +/− quantity selector with animated count.
class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrease,
    required this.onDecrease,
    this.minQuantity = 1,
    this.size = QuantitySelectorSize.medium,
  });

  final int quantity;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final int minQuantity;
  final QuantitySelectorSize size;

  @override
  Widget build(BuildContext context) {
    final btnSize = size == QuantitySelectorSize.small ? 28.0 : 36.0;
    final fontSize = size == QuantitySelectorSize.small ? 14.0 : 16.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            size: btnSize,
            onTap: quantity > minQuantity ? onDecrease : null,
          ),
          SizedBox(
            width: 36,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Text(
                '$quantity',
                key: ValueKey(quantity),
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(fontSize: fontSize),
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            size: btnSize,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

enum QuantitySelectorSize { small, medium }

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.size, this.onTap});

  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.divider,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
