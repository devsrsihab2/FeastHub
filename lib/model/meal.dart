import 'dart:convert';

enum Complexity { simple, challenging, hard }

enum Affordability { affordable, pricey, luxurious }

class Meal {
  const Meal({
    required this.id,
    required this.categories,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.ingredients,
    required this.steps,
    required this.duration,
    required this.complexity,
    required this.affordability,
    required this.isGlutenFree,
    required this.isLactoseFree,
    required this.isVegan,
    required this.isVegetarian,
    this.rating = 4.0,
    this.reviewCount = 0,
  });

  final String id;
  final List<String> categories;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final List<String> ingredients;
  final List<String> steps;
  final int duration;
  final Complexity complexity;
  final Affordability affordability;
  final bool isGlutenFree;
  final bool isLactoseFree;
  final bool isVegan;
  final bool isVegetarian;
  final double rating;
  final int reviewCount;

  String get complexityLabel {
    switch (complexity) {
      case Complexity.simple:
        return 'Simple';
      case Complexity.challenging:
        return 'Challenging';
      case Complexity.hard:
        return 'Hard';
    }
  }

  String get affordabilityLabel {
    switch (affordability) {
      case Affordability.affordable:
        return 'Affordable';
      case Affordability.pricey:
        return 'Pricey';
      case Affordability.luxurious:
        return 'Luxurious';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'duration': duration,
      'complexity': complexity.name,
      'affordability': affordability.name,
      'is_gluten_free': isGlutenFree ? 1 : 0,
      'is_lactose_free': isLactoseFree ? 1 : 0,
      'is_vegan': isVegan ? 1 : 0,
      'is_vegetarian': isVegetarian ? 1 : 0,
      'rating': rating,
      'review_count': reviewCount,
      'ingredients': jsonEncode(ingredients),
      'steps': jsonEncode(steps),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map, List<String> categoryIds) {
    return Meal(
      id: map['id'] as String,
      categories: categoryIds,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String,
      price: (map['price'] as num).toDouble(),
      duration: map['duration'] as int,
      complexity: Complexity.values.firstWhere(
        (e) => e.name == map['complexity'],
        orElse: () => Complexity.simple,
      ),
      affordability: Affordability.values.firstWhere(
        (e) => e.name == map['affordability'],
        orElse: () => Affordability.affordable,
      ),
      isGlutenFree: (map['is_gluten_free'] as int) == 1,
      isLactoseFree: (map['is_lactose_free'] as int) == 1,
      isVegan: (map['is_vegan'] as int) == 1,
      isVegetarian: (map['is_vegetarian'] as int) == 1,
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['review_count'] as int,
      ingredients: List<String>.from(jsonDecode(map['ingredients'] as String)),
      steps: List<String>.from(jsonDecode(map['steps'] as String)),
    );
  }

  Meal copyWith({
    String? id,
    List<String>? categories,
    String? title,
    String? description,
    String? imageUrl,
    double? price,
    List<String>? ingredients,
    List<String>? steps,
    int? duration,
    Complexity? complexity,
    Affordability? affordability,
    bool? isGlutenFree,
    bool? isLactoseFree,
    bool? isVegan,
    bool? isVegetarian,
    double? rating,
    int? reviewCount,
  }) {
    return Meal(
      id: id ?? this.id,
      categories: categories ?? this.categories,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      duration: duration ?? this.duration,
      complexity: complexity ?? this.complexity,
      affordability: affordability ?? this.affordability,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isLactoseFree: isLactoseFree ?? this.isLactoseFree,
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
