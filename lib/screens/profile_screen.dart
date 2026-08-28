import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/provider/auth_provider.dart';
import 'package:first_project/provider/cart_provider.dart';
import 'package:first_project/provider/favorites_provider.dart';
import 'package:first_project/provider/order_provider.dart';
import 'package:first_project/screens/auth/login_screen.dart';
import 'package:first_project/screens/favorite_meal.dart';
import 'package:first_project/screens/orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return _GuestProfile();
    }

    return _UserProfile(auth: auth);
  }
}

class _GuestProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Profile', style: AppTextStyles.heading)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryContainer,
                ),
                child: const Icon(Icons.person_rounded,
                    size: 50, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('Welcome!', style: AppTextStyles.heading),
              const SizedBox(height: 8),
              Text(
                'Sign in to access favorites,\norders and personalised features.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: const Text('Sign In'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen(startOnSignup: true)),
                  ),
                  child: const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserProfile extends StatelessWidget {
  const _UserProfile({required this.auth});
  final AuthProvider auth;

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser!;
    final favCount =
        context.watch<FavoritesProvider>().favoriteMeals.length;
    final cartCount = context.watch<CartProvider>().totalCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.heading),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── User header ────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  child: Center(
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: AppTextStyles.display.copyWith(
                          color: Colors.white, fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name,
                          style: AppTextStyles.title
                              .copyWith(color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(user.email,
                          style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Stats ──────────────────────────────────────────
          Row(
            children: [
              _StatBox(label: 'Favorites', value: '$favCount'),
              const SizedBox(width: 12),
              _StatBox(label: 'In Cart', value: '$cartCount'),
            ],
          ),
          const SizedBox(height: 16),

          // ── Menu ───────────────────────────────────────────
          _MenuSection(
            items: [
              _MenuItem(
                icon: Icons.receipt_long_rounded,
                label: 'My Orders',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                ),
              ),
              _MenuItem(
                icon: Icons.favorite_border_rounded,
                label: 'My Favorites',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MenuSection(
            items: [
              _MenuItem(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: AppColors.error,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              final favProvider = context.read<FavoritesProvider>();
              final cartProvider = context.read<CartProvider>();
              final orderProvider = context.read<OrderProvider>();
              Navigator.pop(context);
              await authProvider.logout();
              favProvider.clear();
              cartProvider.clear();
              orderProvider.clear();
            },
            child: Text('Logout',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.heading),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: items
            .asMap()
            .entries
            .map((e) => Column(
                  children: [
                    e.value,
                    if (e.key < items.length - 1)
                      const Divider(height: 0, indent: 52),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: c),
      title: Text(label, style: AppTextStyles.body.copyWith(color: c)),
      trailing:
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
    );
  }
}
