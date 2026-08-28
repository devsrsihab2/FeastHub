import 'package:flutter/material.dart';

class NotFoundWideget extends StatelessWidget {
  const NotFoundWideget({
    super.key,
    this.title = 'No meals found',
    this.message =
        'This category is empty right now. Try browsing a different one.',
    this.icon = Icons.restaurant_menu_rounded,
    this.onBrowse,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onBrowse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                size: 46,
                color: colorScheme.primary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (onBrowse != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onBrowse,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Browse categories'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
