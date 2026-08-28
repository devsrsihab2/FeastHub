import 'package:first_project/core/theme/app_theme.dart';
import 'package:first_project/provider/auth_provider.dart';
import 'package:first_project/provider/cart_provider.dart';
import 'package:first_project/provider/category_provider.dart';
import 'package:first_project/provider/favorites_provider.dart';
import 'package:first_project/provider/meal_provider.dart';
import 'package:first_project/provider/order_provider.dart';
import 'package:first_project/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const FeastHubApp(),
    ),
  );
}

class FeastHubApp extends StatelessWidget {
  const FeastHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FeastHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
