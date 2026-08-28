import 'package:flutter/material.dart';

class Category {
  const Category({
    required this.id,
    required this.title,
    this.color = Colors.orange,
    this.iconCode = 0xe57a, // Icons.restaurant_menu
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final Color color;
  final int iconCode;
  final int sortOrder;

  IconData get icon {
    switch (id) {
      case 'c1':
        return Icons.restaurant_rounded;
      case 'c2':
        return Icons.bolt_rounded;
      case 'c3':
        return Icons.lunch_dining_rounded;
      case 'c4':
        return Icons.local_drink_rounded;
      case 'c5':
        return Icons.spa_rounded;
      case 'c6':
        return Icons.travel_explore_rounded;
      case 'c7':
        return Icons.free_breakfast_rounded;
      case 'c8':
        return Icons.ramen_dining_rounded;
      case 'c9':
        return Icons.wine_bar_rounded;
      case 'c10':
        return Icons.wb_sunny_rounded;
      case 'c11':
        return Icons.cake_rounded;
      case 'c12':
        return Icons.eco_rounded;
      case 'c13':
        return Icons.set_meal_rounded;
      case 'c14':
        return Icons.grass_rounded;
      case 'c15':
        return Icons.local_bar_rounded;
      default:
        return Icons.restaurant_menu_rounded;
    }
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'color_hex': color.toARGB32().toRadixString(16).padLeft(8, '0'),
      'icon_code': iconCode,
      'sort_order': sortOrder,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    final colorHex = map['color_hex'] as String? ?? 'ffff6b35';
    final colorValue = int.parse(colorHex, radix: 16);
    return Category(
      id: map['id'] as String,
      title: map['title'] as String,
      color: Color(colorValue),
      iconCode: map['icon_code'] as int? ?? 0xe57a,
      sortOrder: map['sort_order'] as int? ?? 0,
    );
  }
}
