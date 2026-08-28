import 'package:flutter/material.dart';

class StatItem extends StatelessWidget {
  const StatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.unit,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          // icon
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),

          // value text
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          // unit text
          Text(
            unit,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
