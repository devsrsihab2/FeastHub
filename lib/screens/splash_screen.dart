import 'package:first_project/core/theme/app_colors.dart';
import 'package:first_project/core/theme/app_text_styles.dart';
import 'package:first_project/data/database/app_database.dart';
import 'package:first_project/provider/auth_provider.dart';
import 'package:first_project/provider/cart_provider.dart';
import 'package:first_project/provider/category_provider.dart';
import 'package:first_project/provider/favorites_provider.dart';
import 'package:first_project/provider/meal_provider.dart';
import 'package:first_project/screens/tabs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    _init();
  }

  Future<void> _init() async {
    // Capture all providers synchronously before any await
    final authProvider = context.read<AuthProvider>();
    final categoryProvider = context.read<CategoryProvider>();
    final mealProvider = context.read<MealProvider>();
    final favoritesProvider = context.read<FavoritesProvider>();
    final cartProvider = context.read<CartProvider>();

    // Initialize DB (creates tables + seeds if empty)
    await AppDatabase.instance.database;

    // Restore auth session
    await authProvider.restoreSession();

    // Pre-load data in parallel
    await Future.wait([
      categoryProvider.load(),
      mealProvider.loadAll(),
      mealProvider.loadPopular(),
    ]);

    // Load user-specific data
    final userId = authProvider.effectiveUserId;
    await Future.wait([
      favoritesProvider.loadFavorites(userId),
      cartProvider.loadCart(userId),
    ]);

    // Ensure smooth display time for animation completion
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (ctx, animation, secondary) => FadeTransition(
          opacity: animation,
          child: const TabsScreen(),
        ),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Animated Logo Icon ─────────────────────────
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        color: AppColors.primary,
                        size: 56,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Animated Text ──────────────────────────────
                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        Text(
                          'FeastHub',
                          style: AppTextStyles.display.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover. Order. Enjoy.',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 36),
                        // Sleek progress indicator
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
