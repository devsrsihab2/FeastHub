import 'package:flutter/material.dart';

/// Centralized color palette for FeastHub.
/// Warm food-app inspired palette with deep orange as primary.
class AppColors {
  AppColors._();

  // Primary brand
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8C5A);
  static const Color primaryDark = Color(0xFFE5521B);
  static const Color primaryContainer = Color(0xFFFFE8DE);

  // Neutral / surface
  static const Color background = Color(0xFFFAFAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F0);
  static const Color divider = Color(0xFFEEEEE8);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textDisabled = Color(0xFFABABAB);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // Card / shadow
  static const Color cardShadow = Color(0x14000000);
  static const Color overlay = Color(0x80000000);

  // Rating
  static const Color star = Color(0xFFFBBF24);

  // Category colors (curated palette)
  static const Color catItalian = Color(0xFF8B5CF6);
  static const Color catQuickEasy = Color(0xFFEC4899);
  static const Color catBurgers = Color(0xFFFF6B35);
  static const Color catGerman = Color(0xFFF59E0B);
  static const Color catLight = Color(0xFF06B6D4);
  static const Color catExotic = Color(0xFF10B981);
  static const Color catBreakfast = Color(0xFF3B82F6);
  static const Color catAsian = Color(0xFFEF4444);
  static const Color catFrench = Color(0xFF6366F1);
  static const Color catSummer = Color(0xFF14B8A6);
  static const Color catDesserts = Color(0xFFF472B6);
  static const Color catHealthy = Color(0xFF22C55E);
  static const Color catSeafood = Color(0xFF0EA5E9);
  static const Color catVegetarian = Color(0xFF84CC16);
  static const Color catDrinks = Color(0xFF8B5CF6);
}
