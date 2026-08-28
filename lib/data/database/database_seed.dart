import 'dart:convert';
import 'package:sqflite/sqflite.dart';

/// Seeds the database with initial categories and meals on first launch.
/// Called only when the database is empty (onCreate or onUpgrade).
class DatabaseSeed {
  DatabaseSeed._();

  static Future<void> seed(Database db) async {
    await _seedCategories(db);
    await _seedMeals(db);
  }

  // ─────────────────────────────────────────────
  // CATEGORIES
  // ─────────────────────────────────────────────
  static Future<void> _seedCategories(Database db) async {
    final categories = [
      // id, title, colorHex, iconCode, sortOrder
      ('c1', 'Italian', 'ffb39ddb', 0xe1b7, 1), // restaurant icon
      ('c2', 'Quick & Easy', 'ffec4899', 0xe41e, 2), // bolt
      ('c3', 'Hamburgers', 'ffff6b35', 0xe532, 3), // lunch_dining
      ('c4', 'German', 'fff59e0b', 0xe7d0, 4), // local_drink
      ('c5', 'Light & Lovely', 'ff06b6d4', 0xe3f4, 5), // spa
      ('c6', 'Exotic', 'ff10b981', 0xef64, 6), // travel_explore
      ('c7', 'Breakfast', 'ff3b82f6', 0xe533, 7), // free_breakfast
      ('c8', 'Asian', 'ffef4444', 0xe1b7, 8), // ramen_dining
      ('c9', 'French', 'ff6366f1', 0xe569, 9), // wine_bar
      ('c10', 'Summer', 'ff14b8a6', 0xe01b, 10), // wb_sunny
      ('c11', 'Desserts', 'fff472b6', 0xeace, 11), // cake
      ('c12', 'Healthy', 'ff22c55e', 0xe3f4, 12), // eco
      ('c13', 'Seafood', 'ff0ea5e9', 0xe1b7, 13), // set_meal
      ('c14', 'Vegetarian', 'ff84cc16', 0xe56d, 14), // grass
      ('c15', 'Drinks', 'ff8b5cf6', 0xe7d0, 15), // local_bar
    ];

    for (final cat in categories) {
      await db.insert('categories', {
        'id': cat.$1,
        'title': cat.$2,
        'color_hex': cat.$3,
        'icon_code': cat.$4,
        'sort_order': cat.$5,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // ─────────────────────────────────────────────
  // MEALS (30 Curated Dishes with Local Assets)
  // ─────────────────────────────────────────────
  static Future<void> _seedMeals(Database db) async {
    final now = DateTime.now().toIso8601String();

    Future<void> addMeal({
      required String id,
      required List<String> categoryIds,
      required String title,
      required String description,
      required String imageUrl,
      required double price,
      required int duration,
      required String complexity,
      required String affordability,
      required bool isGlutenFree,
      required bool isLactoseFree,
      required bool isVegan,
      required bool isVegetarian,
      required double rating,
      required int reviewCount,
      required List<String> ingredients,
      required List<String> steps,
    }) async {
      await db.insert('meals', {
        'id': id,
        'title': title,
        'description': description,
        'image_url': imageUrl,
        'price': price,
        'duration': duration,
        'complexity': complexity,
        'affordability': affordability,
        'is_gluten_free': isGlutenFree ? 1 : 0,
        'is_lactose_free': isLactoseFree ? 1 : 0,
        'is_vegan': isVegan ? 1 : 0,
        'is_vegetarian': isVegetarian ? 1 : 0,
        'rating': rating,
        'review_count': reviewCount,
        'ingredients': jsonEncode(ingredients),
        'steps': jsonEncode(steps),
        'created_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (final catId in categoryIds) {
        await db.insert('meal_categories', {
          'meal_id': id,
          'category_id': catId,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    // ── 1. HAMBURGERS / QUICK & EASY ──────────────────
    await addMeal(
      id: 'm1',
      categoryIds: ['c3', 'c2'],
      title: 'Classic Cheeseburger',
      description:
          'A juicy beef patty loaded with cheddar, fresh veggies, and house sauce on a toasted brioche bun. A timeless comfort classic.',
      imageUrl: 'assets/images/Classic_Cheeseburger.webp',
      price: 8.99,
      duration: 20,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: false,
      rating: 4.7,
      reviewCount: 832,
      ingredients: [
        'Beef patty (200g)',
        'Cheddar cheese',
        'Brioche bun',
        'Lettuce',
        'Tomato',
        'Red onion',
        'Pickles',
        'Ketchup',
        'Mustard',
        'Butter',
      ],
      steps: [
        'Season patty generously with salt and pepper.',
        'Heat a cast-iron skillet over high heat.',
        'Cook patty 3–4 minutes per side for medium.',
        'Add cheese in the last minute, cover to melt.',
        'Toast brioche buns with butter.',
        'Assemble with lettuce, tomato, onion, pickles, and condiments.',
      ],
    );

    await addMeal(
      id: 'm2',
      categoryIds: ['c3'],
      title: 'BBQ Bacon Smash Burger',
      description:
          'Double-smashed beef patties with crispy bacon, smoked BBQ sauce, caramelised onions, and pepper jack cheese.',
      imageUrl: 'assets/images/BBQ_Bacon_Smash_Burger.jpg',
      price: 11.99,
      duration: 25,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: false,
      rating: 4.9,
      reviewCount: 1241,
      ingredients: [
        'Double beef patties',
        'Crispy bacon',
        'Pepper jack cheese',
        'Caramelised onions',
        'Brioche bun',
        'BBQ sauce',
        'Jalapeños',
        'Mayo',
      ],
      steps: [
        'Form two thin beef patties.',
        'Smash onto hot griddle and season.',
        'Cook bacon until crispy.',
        'Caramelise onions slowly in butter.',
        'Stack patties, cheese, bacon, onions.',
        'Apply BBQ sauce and mayo to bun.',
        'Serve immediately.',
      ],
    );

    // ── 2. ITALIAN ────────────────────────────────────
    await addMeal(
      id: 'm3',
      categoryIds: ['c1', 'c10'],
      title: 'Margherita Pizza',
      description:
          'Neapolitan-style pizza with San Marzano tomato sauce, buffalo mozzarella, and fresh basil on a hand-stretched dough.',
      imageUrl: 'assets/images/Margherita_Pizza.jpg',
      price: 12.50,
      duration: 35,
      complexity: 'challenging',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: true,
      rating: 4.8,
      reviewCount: 956,
      ingredients: [
        'Pizza dough',
        'San Marzano tomatoes',
        'Buffalo mozzarella',
        'Fresh basil',
        'Extra virgin olive oil',
        'Sea salt',
        'Dried oregano',
      ],
      steps: [
        'Preheat oven to 250°C with pizza stone.',
        'Stretch dough by hand to 30cm circle.',
        'Crush tomatoes and spread, leaving 2cm border.',
        'Tear mozzarella and distribute evenly.',
        'Bake 10–12 minutes until crust is charred and bubbly.',
        'Finish with fresh basil and olive oil.',
      ],
    );

    await addMeal(
      id: 'm4',
      categoryIds: ['c1'],
      title: 'Spaghetti Carbonara',
      description:
          'Roman classic: silky egg-and-Pecorino sauce with crispy guanciale and black pepper. No cream, just technique.',
      imageUrl: 'assets/images/Spaghetti_Carbonara.webp',
      price: 14.50,
      duration: 25,
      complexity: 'challenging',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: false,
      rating: 4.9,
      reviewCount: 703,
      ingredients: [
        'Spaghetti 200g',
        'Guanciale 100g',
        'Egg yolks 4',
        'Pecorino Romano 80g',
        'Parmesan 40g',
        'Black pepper (generous)',
        'Salt',
      ],
      steps: [
        'Bring salted water to boil.',
        'Render guanciale in cold pan until crispy.',
        'Whisk egg yolks with grated cheese and black pepper.',
        'Cook pasta until al dente, reserve 200ml pasta water.',
        'Off heat, combine pasta with guanciale fat.',
        'Add egg mix and pasta water slowly, stirring to create silky sauce.',
        'Plate and top with more cheese and pepper.',
      ],
    );

    // ── 3. QUICK & EASY / BREAKFAST ────────────────────
    await addMeal(
      id: 'm5',
      categoryIds: ['c7', 'c2'],
      title: 'Fluffy Pancakes',
      description:
          'Thick, airy American-style pancakes with a buttery finish. Served with pure maple syrup and fresh berries.',
      imageUrl: 'assets/images/Fluffy_Pancakes.jpg',
      price: 7.50,
      duration: 15,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: true,
      rating: 4.6,
      reviewCount: 534,
      ingredients: [
        'All-purpose flour 200g',
        'Eggs 2',
        'Buttermilk 240ml',
        'Baking powder 2 tsp',
        'Sugar 2 tbsp',
        'Butter (melted)',
        'Maple syrup',
        'Mixed berries',
      ],
      steps: [
        'Whisk dry ingredients in a bowl.',
        'Combine eggs, buttermilk, and melted butter.',
        'Fold wet into dry — lumps are fine, don\'t overmix.',
        'Pour batter on a medium-heat buttered pan.',
        'Flip when bubbles form and edges look set.',
        'Cook 1 more minute.',
        'Serve stacked with maple syrup and berries.',
      ],
    );

    await addMeal(
      id: 'm6',
      categoryIds: ['c2', 'c12'],
      title: 'Avocado Toast with Poached Egg',
      description:
          'Smashed avocado on sourdough, topped with a perfectly poached egg, chili flakes, and microgreens.',
      imageUrl: 'assets/images/Avocado_Toast_with_Poached_Egg.webp',
      price: 9.99,
      duration: 12,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: true,
      rating: 4.5,
      reviewCount: 421,
      ingredients: [
        'Sourdough bread 2 slices',
        'Ripe avocado',
        'Eggs 2',
        'Lemon juice',
        'Chili flakes',
        'Microgreens',
        'Sea salt',
        'Black pepper',
        'White vinegar',
      ],
      steps: [
        'Toast sourdough until golden.',
        'Smash avocado with lemon juice, salt, and pepper.',
        'Bring a pot of water to gentle simmer, add vinegar.',
        'Crack egg into a small bowl, swirl water, slide egg in.',
        'Poach for 3 minutes.',
        'Spread avocado on toast, place poached egg on top.',
        'Finish with chili flakes and microgreens.',
      ],
    );

    // ── 4. ASIAN / EXOTIC ─────────────────────────────
    await addMeal(
      id: 'm7',
      categoryIds: ['c8', 'c6'],
      title: 'Chicken Pad Thai',
      description:
          'Street-food favourite: stir-fried rice noodles with chicken, egg, bean sprouts, and a tangy tamarind-fish sauce.',
      imageUrl: 'assets/images/Chicken_Pad_Thai.jpg',
      price: 13.99,
      duration: 30,
      complexity: 'challenging',
      affordability: 'pricey',
      isGlutenFree: true,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.8,
      reviewCount: 672,
      ingredients: [
        'Rice noodles 200g',
        'Chicken breast 250g',
        'Eggs 2',
        'Bean sprouts 100g',
        'Crushed peanuts',
        'Tamarind paste 3 tbsp',
        'Fish sauce 2 tbsp',
        'Palm sugar 1 tbsp',
        'Lime',
        'Scallions',
        'Chili powder',
      ],
      steps: [
        'Soak noodles in warm water 30 min, drain.',
        'Mix tamarind, fish sauce, and sugar for sauce.',
        'Stir-fry chicken in hot wok until cooked.',
        'Push aside, scramble eggs.',
        'Add noodles and sauce, toss vigorously.',
        'Add bean sprouts and scallions, quick toss.',
        'Serve topped with peanuts and lime wedge.',
      ],
    );

    await addMeal(
      id: 'm8',
      categoryIds: ['c8'],
      title: 'Ramen Tonkotsu',
      description:
          'Rich, milky pork-bone broth with springy noodles, chashu pork, soft-boiled egg, nori, and bamboo shoots.',
      imageUrl: 'assets/images/Ramen_Tonkotsu.webp',
      price: 16.99,
      duration: 240,
      complexity: 'hard',
      affordability: 'pricey',
      isGlutenFree: false,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.9,
      reviewCount: 1102,
      ingredients: [
        'Pork trotters 1kg',
        'Pork belly 400g',
        'Ramen noodles',
        'Eggs 4',
        'Soy sauce',
        'Mirin',
        'Garlic',
        'Ginger',
        'Nori sheets',
        'Bamboo shoots',
        'Scallions',
        'Sesame oil',
      ],
      steps: [
        'Blanch pork trotters 10 min, drain and rinse.',
        'Simmer trotters with garlic and ginger 4 hours until milky.',
        'Braise pork belly in soy and mirin for chashu.',
        'Marinate soft-boiled eggs in leftover braising liquid.',
        'Season broth with tare (soy-salt mixture).',
        'Cook noodles al dente.',
        'Assemble: noodles, broth, sliced chashu, egg, nori, bamboo shoots.',
      ],
    );

    await addMeal(
      id: 'm9',
      categoryIds: ['c8', 'c6'],
      title: 'Beef Rendang',
      description:
          'Slow-cooked Indonesian beef in aromatic coconut milk and spice paste until the sauce caramelises into a rich, dry coating.',
      imageUrl: 'assets/images/Beef_Rendang.webp',
      price: 15.99,
      duration: 150,
      complexity: 'hard',
      affordability: 'pricey',
      isGlutenFree: true,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.8,
      reviewCount: 418,
      ingredients: [
        'Beef chuck 800g',
        'Coconut milk 400ml',
        'Lemongrass 3 stalks',
        'Galangal 3cm',
        'Red chili paste',
        'Garlic 6 cloves',
        'Shallots 8',
        'Kaffir lime leaves',
        'Turmeric',
        'Toasted coconut',
      ],
      steps: [
        'Blend chilies, shallots, garlic, galangal, and lemongrass.',
        'Sauté paste in oil until fragrant (15 min).',
        'Add beef and stir to coat with paste.',
        'Pour in coconut milk, bring to boil.',
        'Reduce heat, simmer 2 hours stirring occasionally.',
        'Continue cooking until sauce evaporates and beef darkens.',
        'Serve with steamed rice.',
      ],
    );

    // ── 5. LIGHT & LOVELY / SUMMER ────────────────────
    await addMeal(
      id: 'm10',
      categoryIds: ['c5', 'c10'],
      title: 'Greek Salad',
      description:
          'Crisp cucumber, ripe tomatoes, Kalamata olives, and creamy feta dressed with good olive oil and dried oregano.',
      imageUrl: 'assets/images/Greek_Salad.webp',
      price: 7.50,
      duration: 10,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: true,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: true,
      rating: 4.5,
      reviewCount: 389,
      ingredients: [
        'Cucumber 1',
        'Tomatoes 3',
        'Red onion',
        'Feta cheese 150g',
        'Kalamata olives 100g',
        'Extra virgin olive oil',
        'Dried oregano',
        'Salt',
        'Black pepper',
      ],
      steps: [
        'Cut cucumber into large chunks.',
        'Quarter tomatoes, slice red onion thin.',
        'Combine vegetables and olives in a bowl.',
        'Place feta block on top (or crumble).',
        'Drizzle generously with olive oil.',
        'Season with oregano, salt, and pepper.',
        'Toss gently and serve immediately.',
      ],
    );

    await addMeal(
      id: 'm11',
      categoryIds: ['c5', 'c12'],
      title: 'Grilled Salmon with Quinoa',
      description:
          'Pan-seared Atlantic salmon over herbed quinoa with roasted asparagus and lemon-dill dressing.',
      imageUrl: 'assets/images/Grilled_Salmon_with_Quinoa.webp',
      price: 18.99,
      duration: 30,
      complexity: 'simple',
      affordability: 'luxurious',
      isGlutenFree: true,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.7,
      reviewCount: 567,
      ingredients: [
        'Salmon fillet 200g',
        'Quinoa 100g',
        'Asparagus 150g',
        'Lemon',
        'Dill',
        'Olive oil',
        'Garlic 2 cloves',
        'Salt',
        'Black pepper',
        'Capers',
      ],
      steps: [
        'Cook quinoa in vegetable stock, fluff with fork.',
        'Mix in chopped dill and lemon zest.',
        'Roast asparagus at 200°C with olive oil 12 min.',
        'Season salmon with salt, pepper, and lemon.',
        'Sear skin-side down 4 min, flip 2 min.',
        'Mix lemon juice, oil, and capers for dressing.',
        'Plate quinoa, salmon, asparagus, and drizzle dressing.',
      ],
    );

    // ── 6. FRENCH ─────────────────────────────────────
    await addMeal(
      id: 'm12',
      categoryIds: ['c9', 'c6'],
      title: 'Beef Bourguignon',
      description:
          'Classic French braise: tender beef slow-cooked in Burgundy red wine with pearl onions, mushrooms, and lardons.',
      imageUrl: 'assets/images/Beef_Bourguignon.jpg',
      price: 22.99,
      duration: 180,
      complexity: 'hard',
      affordability: 'luxurious',
      isGlutenFree: false,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.9,
      reviewCount: 312,
      ingredients: [
        'Beef chuck 1kg',
        'Burgundy wine 750ml',
        'Lardons 150g',
        'Pearl onions 200g',
        'Mushrooms 250g',
        'Carrots 2',
        'Garlic 4 cloves',
        'Thyme',
        'Bay leaves',
        'Beef stock',
        'Tomato paste',
        'Flour',
      ],
      steps: [
        'Marinate beef in wine overnight.',
        'Sear beef in batches until browned, set aside.',
        'Cook lardons until crispy, sauté onions and garlic.',
        'Dust with flour, add tomato paste, stir.',
        'Add wine, beef stock, herbs, and beef.',
        'Braise in 160°C oven for 2.5 hours.',
        'Sauté mushrooms separately, add 30 min before end.',
        'Adjust seasoning, serve with mashed potato or crusty bread.',
      ],
    );

    await addMeal(
      id: 'm13',
      categoryIds: ['c9'],
      title: 'Croque Monsieur',
      description:
          'The iconic French bistro sandwich: ham and Gruyère between golden bread smothered in Mornay béchamel.',
      imageUrl: 'assets/images/Croque_Monsieur.avif',
      price: 10.50,
      duration: 20,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: false,
      rating: 4.6,
      reviewCount: 287,
      ingredients: [
        'Brioche or pain de mie 4 slices',
        'Black Forest ham 100g',
        'Gruyère 120g (grated)',
        'Butter 40g',
        'Flour 2 tbsp',
        'Whole milk 300ml',
        'Dijon mustard',
        'Nutmeg',
      ],
      steps: [
        'Make béchamel: melt butter, whisk in flour, add milk gradually.',
        'Season with nutmeg, salt, and half the cheese.',
        'Spread Dijon on bread, layer ham and remaining cheese.',
        'Spread béchamel generously on top.',
        'Grill/broil 4–5 minutes until bubbly and golden.',
        'Serve immediately with cornichons.',
      ],
    );

    // ── 7. GERMAN ─────────────────────────────────────
    await addMeal(
      id: 'm14',
      categoryIds: ['c4'],
      title: 'Bratwurst with Sauerkraut',
      description:
          'Juicy grilled pork bratwurst served with tangy sauerkraut, whole-grain mustard, and a crusty pretzel roll.',
      imageUrl: 'assets/images/Bratwurst_with_Sauerkraut.jpg',
      price: 11.99,
      duration: 25,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.5,
      reviewCount: 198,
      ingredients: [
        'Pork bratwurst 2',
        'Sauerkraut 200g',
        'Pretzel roll',
        'Whole-grain mustard',
        'Beer (for poaching)',
        'Onion 1',
        'Caraway seeds',
        'Butter',
      ],
      steps: [
        'Poach bratwurst in beer with sliced onion 10 min.',
        'Grill or pan-fry until golden and charred.',
        'Warm sauerkraut with caraway seeds and butter.',
        'Toast pretzel roll.',
        'Serve bratwurst on roll with sauerkraut and generous mustard.',
      ],
    );

    // ── 8. BREAKFAST ──────────────────────────────────
    await addMeal(
      id: 'm15',
      categoryIds: ['c7'],
      title: 'Full English Breakfast',
      description:
          'The legendary fry-up: back bacon, sausage, fried eggs, baked beans, grilled tomato, mushrooms, and toast.',
      imageUrl: 'assets/images/Full_English_Breakfast.webp',
      price: 13.50,
      duration: 25,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.7,
      reviewCount: 741,
      ingredients: [
        'Back bacon 2 rashers',
        'Pork sausages 2',
        'Eggs 2',
        'Baked beans',
        'Tomato (halved)',
        'Mushrooms 100g',
        'Toast',
        'Butter',
        'Black pudding (optional)',
      ],
      steps: [
        'Grill sausages and bacon until cooked through.',
        'Fry eggs in butter, sunny side up or over-easy.',
        'Grill tomato halves and mushrooms.',
        'Warm baked beans in a small pot.',
        'Toast bread until golden.',
        'Arrange all components on a large plate and serve hot.',
      ],
    );

    // ── 9. SEAFOOD ────────────────────────────────────
    await addMeal(
      id: 'm16',
      categoryIds: ['c13', 'c9'],
      title: 'Bouillabaisse',
      description:
          'Provençal fisherman\'s stew with saffron, sea bass, mussels, prawns, and fennel in a golden tomato broth.',
      imageUrl: 'assets/images/Bouillabaisse.jpg',
      price: 24.99,
      duration: 60,
      complexity: 'challenging',
      affordability: 'luxurious',
      isGlutenFree: true,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.8,
      reviewCount: 156,
      ingredients: [
        'Sea bass fillet 300g',
        'Mussels 300g',
        'Tiger prawns 200g',
        'Fennel bulb 1',
        'Canned tomatoes 400g',
        'Fish stock 1L',
        'Saffron pinch',
        'Garlic 4 cloves',
        'Leek',
        'White wine',
        'Orange zest',
        'Rouille and baguette to serve',
      ],
      steps: [
        'Sauté fennel, leek, and garlic in olive oil.',
        'Add white wine, reduce by half.',
        'Add tomatoes, fish stock, saffron, and orange zest.',
        'Simmer 20 minutes, blend half the broth for body.',
        'Add sea bass, cook 5 minutes.',
        'Add mussels and prawns, cook until mussels open.',
        'Serve with rouille-spread baguette slices.',
      ],
    );

    await addMeal(
      id: 'm17',
      categoryIds: ['c13', 'c5'],
      title: 'Grilled Tiger Prawns',
      description:
          'Jumbo tiger prawns marinated in garlic, chili, and lemon, char-grilled and served with herb butter and aioli.',
      imageUrl: 'assets/images/Grilled_Tiger_Prawns.webp',
      price: 19.99,
      duration: 20,
      complexity: 'simple',
      affordability: 'pricey',
      isGlutenFree: true,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: false,
      rating: 4.7,
      reviewCount: 223,
      ingredients: [
        'Tiger prawns 400g',
        'Garlic 4 cloves',
        'Red chili 1',
        'Lemon',
        'Olive oil',
        'Butter 40g',
        'Parsley',
        'Aioli',
        'Sea salt',
      ],
      steps: [
        'Butterfly prawns along the back.',
        'Marinate with garlic, chili, lemon juice, and olive oil (15 min).',
        'Heat grill to high.',
        'Grill prawns 2–3 min per side until pink and charred.',
        'Baste with herb butter in last minute.',
        'Serve with aioli and crusty bread.',
      ],
    );

    // ── 10. VEGETARIAN ─────────────────────────────────
    await addMeal(
      id: 'm18',
      categoryIds: ['c14', 'c12'],
      title: 'Mushroom Risotto',
      description:
          'Creamy Arborio risotto with mixed wild mushrooms, Parmesan, and truffle oil. Deeply savoury and luxurious.',
      imageUrl: 'assets/images/Mushroom_Risotto.jpg',
      price: 14.99,
      duration: 40,
      complexity: 'challenging',
      affordability: 'affordable',
      isGlutenFree: true,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: true,
      rating: 4.8,
      reviewCount: 489,
      ingredients: [
        'Arborio rice 300g',
        'Mixed mushrooms 400g',
        'Parmesan 80g',
        'White wine 150ml',
        'Vegetable stock 1L',
        'Shallots 3',
        'Garlic 3 cloves',
        'Butter 60g',
        'Truffle oil',
        'Thyme',
        'Flat-leaf parsley',
      ],
      steps: [
        'Heat stock and keep warm.',
        'Sauté shallots and garlic in butter until soft.',
        'Add rice, toast 2 minutes.',
        'Pour in wine, stir until absorbed.',
        'Add stock ladle by ladle, stirring and waiting for absorption each time (18–20 min).',
        'Sauté mushrooms separately in butter and thyme.',
        'Fold mushrooms and Parmesan into risotto.',
        'Finish with truffle oil and parsley.',
      ],
    );

    await addMeal(
      id: 'm19',
      categoryIds: ['c14', 'c5'],
      title: 'Falafel Pita Wrap',
      description:
          'Crispy chickpea falafel in warm pita with hummus, tahini, pickled cabbage, cucumber, and hot sauce.',
      imageUrl: 'assets/images/Falafel_Pita_Wrap.webp',
      price: 9.50,
      duration: 30,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: true,
      isVegan: true,
      isVegetarian: true,
      rating: 4.6,
      reviewCount: 334,
      ingredients: [
        'Dried chickpeas 200g (soaked overnight)',
        'Onion 1',
        'Garlic 4 cloves',
        'Parsley & coriander',
        'Cumin & coriander powder',
        'Pita bread 2',
        'Hummus',
        'Tahini sauce',
        'Pickled red cabbage',
        'Cucumber',
        'Hot sauce',
      ],
      steps: [
        'Drain and pulse chickpeas (not canned!) with onion, herbs, garlic, and spices until coarse.',
        'Form into balls, rest 30 min in fridge.',
        'Deep-fry at 175°C for 3–4 minutes until deep golden.',
        'Warm pita bread.',
        'Spread hummus, add falafel, pickled cabbage, cucumber.',
        'Drizzle tahini and hot sauce.',
      ],
    );

    // ── 11. DESSERTS ───────────────────────────────────
    await addMeal(
      id: 'm20',
      categoryIds: ['c11'],
      title: 'Classic Tiramisu',
      description:
          'Italian dessert royalty: espresso-soaked ladyfingers layered with mascarpone cream and dusted with cocoa.',
      imageUrl: 'assets/images/Classic_Tiramisu.webp',
      price: 7.99,
      duration: 30,
      complexity: 'challenging',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: true,
      rating: 4.9,
      reviewCount: 712,
      ingredients: [
        'Ladyfingers (savoiardi) 200g',
        'Mascarpone 500g',
        'Egg yolks 5',
        'Caster sugar 100g',
        'Espresso (cooled) 300ml',
        'Marsala wine (optional)',
        'Cocoa powder',
        'Dark chocolate (grated)',
      ],
      steps: [
        'Whisk yolks and sugar until pale and fluffy.',
        'Fold mascarpone into yolk mixture gently.',
        'Dip ladyfingers quickly in espresso (don\'t soak too long).',
        'Layer: biscuits, then cream, then biscuits, then cream.',
        'Refrigerate at least 4 hours or overnight.',
        'Dust generously with cocoa before serving.',
      ],
    );

    await addMeal(
      id: 'm21',
      categoryIds: ['c11', 'c9'],
      title: 'Crème Brûlée',
      description:
          'Silky vanilla custard with a caramelised sugar crust that cracks dramatically at the spoon.',
      imageUrl: 'assets/images/Crème_Brûlée.avif',
      price: 8.50,
      duration: 60,
      complexity: 'challenging',
      affordability: 'pricey',
      isGlutenFree: true,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: true,
      rating: 4.8,
      reviewCount: 445,
      ingredients: [
        'Heavy cream 500ml',
        'Egg yolks 6',
        'Caster sugar 100g',
        'Vanilla bean 1',
        'Extra sugar for brûlée',
      ],
      steps: [
        'Heat cream with split vanilla bean until steaming.',
        'Whisk yolks with sugar until pale.',
        'Slowly pour warm cream into yolk mix, tempering.',
        'Strain and pour into ramekins.',
        'Bake in water bath at 150°C for 35–40 min until just set.',
        'Chill 3 hours.',
        'Sprinkle sugar on top and torch until deep amber caramel forms.',
      ],
    );

    // ── 12. HEALTHY / SUMMER ───────────────────────────
    await addMeal(
      id: 'm22',
      categoryIds: ['c12', 'c7', 'c10'],
      title: 'Acai Power Bowl',
      description:
          'Frozen acai blended thick, topped with granola, fresh berries, chia seeds, coconut flakes, and peanut butter.',
      imageUrl: 'assets/images/Acai_Power_Bowl.webp',
      price: 9.99,
      duration: 10,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: true,
      isLactoseFree: true,
      isVegan: true,
      isVegetarian: true,
      rating: 4.7,
      reviewCount: 623,
      ingredients: [
        'Frozen acai puree 200g',
        'Frozen banana 1',
        'Almond milk 100ml',
        'Granola 50g',
        'Blueberries & strawberries',
        'Chia seeds',
        'Coconut flakes',
        'Peanut butter 1 tbsp',
      ],
      steps: [
        'Blend acai, frozen banana, and almond milk until thick and smooth.',
        'Pour into a bowl.',
        'Arrange granola, berries, chia, and coconut neatly on top.',
        'Drizzle with peanut butter.',
        'Serve immediately while icy.',
      ],
    );

    await addMeal(
      id: 'm23',
      categoryIds: ['c12', 'c2'],
      title: 'Mediterranean Wrap',
      description:
          'Warm whole-wheat flatbread stuffed with grilled chicken, hummus, tzatziki, roasted peppers, and spinach.',
      imageUrl: 'assets/images/Mediterranean_Wrap.jpg',
      price: 10.99,
      duration: 15,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: false,
      rating: 4.6,
      reviewCount: 388,
      ingredients: [
        'Whole-wheat flatbread',
        'Grilled chicken breast 150g',
        'Hummus 2 tbsp',
        'Tzatziki 2 tbsp',
        'Baby spinach',
        'Roasted red peppers',
        'Kalamata olives',
        'Feta cheese',
      ],
      steps: [
        'Warm flatbread on a dry pan.',
        'Spread hummus and tzatziki evenly.',
        'Layer spinach, sliced grilled chicken, and peppers.',
        'Sprinkle olives and feta.',
        'Roll tightly, cut in half diagonally.',
        'Serve warm.',
      ],
    );

    // ── 13. EXOTIC / ASIAN ─────────────────────────────
    await addMeal(
      id: 'm24',
      categoryIds: ['c6', 'c8'],
      title: 'Thai Green Curry',
      description:
          'Fragrant coconut curry with tender chicken, Thai eggplant, bamboo shoots, and sweet basil leaves.',
      imageUrl: 'assets/images/Thai_Green_Curry.jpg',
      price: 14.50,
      duration: 35,
      complexity: 'challenging',
      affordability: 'affordable',
      isGlutenFree: true,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.8,
      reviewCount: 512,
      ingredients: [
        'Chicken thigh 400g',
        'Green curry paste 3 tbsp',
        'Coconut milk 400ml',
        'Thai eggplants 4',
        'Bamboo shoots 100g',
        'Fish sauce 2 tbsp',
        'Palm sugar 1 tbsp',
        'Kaffir lime leaves',
        'Thai basil',
      ],
      steps: [
        'Fry curry paste in coconut cream until fragrant oil splits.',
        'Add chicken pieces, stir until sealed.',
        'Add remaining coconut milk, eggplant, and bamboo shoots.',
        'Simmer 15 minutes.',
        'Season with fish sauce and palm sugar.',
        'Tear in lime leaves and basil just before serving.',
        'Serve with jasmine rice.',
      ],
    );

    // ── 14. ITALIAN COMFORT ───────────────────────────
    await addMeal(
      id: 'm25',
      categoryIds: ['c1', 'c14'],
      title: 'Gnocchi al Gorgonzola',
      description:
          'Pillowy potato gnocchi in a rich Gorgonzola cream sauce topped with toasted walnuts and fresh sage.',
      imageUrl: 'assets/images/Gnocchi_al_Gorgonzola.jpg',
      price: 13.99,
      duration: 20,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: true,
      rating: 4.7,
      reviewCount: 290,
      ingredients: [
        'Potato gnocchi 400g',
        'Gorgonzola cheese 150g',
        'Heavy cream 150ml',
        'Butter 20g',
        'Walnuts 50g (toasted)',
        'Fresh sage leaves',
        'Black pepper',
      ],
      steps: [
        'Melt Gorgonzola and cream in a pan over low heat.',
        'Cook gnocchi in boiling salted water until they float (2–3 min).',
        'Transfer gnocchi to the sauce with a slotted spoon.',
        'Toss gently to coat in velvety sauce.',
        'Fry sage leaves in butter until crisp.',
        'Garnish with toasted walnuts, crispy sage, and cracked pepper.',
      ],
    );

    // ── 15. SUMMER SALAD ──────────────────────────────
    await addMeal(
      id: 'm26',
      categoryIds: ['c10', 'c1', 'c5'],
      title: 'Caprese Salad',
      description:
          'Slices of fresh buffalo mozzarella and ripe beefsteak tomatoes alternated with basil leaves and balsamic glaze.',
      imageUrl: 'assets/images/Caprese_Salad.webp',
      price: 8.50,
      duration: 10,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: true,
      isLactoseFree: false,
      isVegan: false,
      isVegetarian: true,
      rating: 4.6,
      reviewCount: 340,
      ingredients: [
        'Buffalo mozzarella 200g',
        'Ripe tomatoes 3',
        'Fresh basil leaves',
        'Extra virgin olive oil',
        'Balsamic glaze reduction',
        'Flaky sea salt',
        'Freshly ground black pepper',
      ],
      steps: [
        'Slice mozzarella and tomatoes into thick rounds.',
        'Arrange alternately on a platter with whole basil leaves.',
        'Drizzle with high-quality olive oil and thick balsamic glaze.',
        'Sprinkle with flaky sea salt and black pepper.',
        'Serve immediately at room temperature.',
      ],
    );

    // ── 16. SEAFOOD CEVICHE ───────────────────────────
    await addMeal(
      id: 'm27',
      categoryIds: ['c13', 'c6', 'c10'],
      title: 'Ceviche Mixto',
      description:
          'Fresh white fish and shrimp cured in fresh lime juice with red onion, cilantro, sweet potato, and cancha corn.',
      imageUrl: 'assets/images/Ceviche_Mixto.webp',
      price: 16.50,
      duration: 25,
      complexity: 'challenging',
      affordability: 'pricey',
      isGlutenFree: true,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.8,
      reviewCount: 278,
      ingredients: [
        'Fresh sea bass 250g (diced)',
        'Shrimp 150g (blanched)',
        'Fresh lime juice 150ml',
        'Red onion 1 (thinly sliced)',
        'Aji limo / habanero chili',
        'Coriander',
        'Boiled sweet potato',
        'Sea salt',
      ],
      steps: [
        'Toss diced fish with salt in a cold bowl.',
        'Pour fresh lime juice over fish, toss and marinate 5–7 minutes.',
        'Add blanched shrimp, sliced onion, minced chili, and coriander.',
        'Toss gently to blend flavors.',
        'Serve immediately with chilled sweet potato slices.',
      ],
    );

    // ── 17. KOREAN ────────────────────────────────────
    await addMeal(
      id: 'm28',
      categoryIds: ['c8', 'c12'],
      title: 'Korean Bibimbap',
      description:
          'Warm rice topped with seasoned vegetables, sautéed beef, fried egg, and savoury Gochujang chili paste.',
      imageUrl: 'assets/images/Korean_Bibimbap.webp',
      price: 13.99,
      duration: 35,
      complexity: 'challenging',
      affordability: 'affordable',
      isGlutenFree: false,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.9,
      reviewCount: 615,
      ingredients: [
        'Steamed short-grain rice 200g',
        'Beef bulgogi 150g',
        'Shiitake mushrooms',
        'Spinach (blanched with sesame)',
        'Bean sprouts',
        'Carrot ribbons (sautéed)',
        'Fried egg (sunny side up)',
        'Gochujang paste 2 tbsp',
        'Sesame oil & seeds',
      ],
      steps: [
        'Sauté beef with soy, garlic, and sesame oil.',
        'Prepare vegetables separately with light sesame seasoning.',
        'Place warm rice in bottom of bowl.',
        'Arrange vegetables and beef in colorful sections around the top.',
        'Top with fried egg and a dollop of Gochujang.',
        'Mix thoroughly before eating.',
      ],
    );

    // ── 18. MOROCCAN / EXOTIC ─────────────────────────
    await addMeal(
      id: 'm29',
      categoryIds: ['c6'],
      title: 'Lamb Tagine',
      description:
          'Tender lamb shank braised with prunes, toasted almonds, apricots, and Moroccan spices in a traditional clay pot.',
      imageUrl: 'assets/images/Lamb_Tagine.webp',
      price: 21.50,
      duration: 120,
      complexity: 'hard',
      affordability: 'luxurious',
      isGlutenFree: true,
      isLactoseFree: true,
      isVegan: false,
      isVegetarian: false,
      rating: 4.9,
      reviewCount: 367,
      ingredients: [
        'Lamb shanks / shoulder 800g',
        'Dried prunes 100g',
        'Dried apricots 60g',
        'Onions 2 (finely diced)',
        'Ginger & cinnamon & saffron',
        'Honey 2 tbsp',
        'Toasted almonds',
        'Coriander & parsley',
      ],
      steps: [
        'Brown lamb in olive oil with onions and spices.',
        'Add water/broth to cover halfway, simmer covered on low 1.5 hours.',
        'Add prunes, apricots, and honey to the sauce.',
        'Simmer uncovered 20 minutes until sauce reduces to thick glaze.',
        'Garnish with toasted almonds and fresh herbs.',
        'Serve with warm couscous.',
      ],
    );

    // ── 19. DRINKS & REFRESHMENTS ─────────────────────
    await addMeal(
      id: 'm30',
      categoryIds: ['c15', 'c12', 'c10'],
      title: 'Fresh Fruit Smoothie',
      description:
          'Chilled blend of dragonfruit, mango, passion fruit, and coconut water. Tropical, refreshing, and vitamin-packed.',
      imageUrl: 'assets/images/Fresh_Fruit_Smoothie.webp',
      price: 5.99,
      duration: 5,
      complexity: 'simple',
      affordability: 'affordable',
      isGlutenFree: true,
      isLactoseFree: true,
      isVegan: true,
      isVegetarian: true,
      rating: 4.8,
      reviewCount: 452,
      ingredients: [
        'Ripe mango 1',
        'Pink dragonfruit 1/2',
        'Passion fruit pulp 2 tbsp',
        'Coconut water 200ml',
        'Ice cubes',
        'Fresh mint sprig',
      ],
      steps: [
        'Peel and dice mango and dragonfruit.',
        'Add fruits, passion fruit pulp, and coconut water to blender.',
        'Add ice cubes and blend on high for 45 seconds until velvety.',
        'Pour into tall chilled glass.',
        'Garnish with mint and fresh passion fruit seeds.',
        'Serve ice cold.',
      ],
    );
  }
}
