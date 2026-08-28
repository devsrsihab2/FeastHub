import "package:first_project/screens/tabs.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:google_fonts/google_fonts.dart";
import "package:first_project/provider/favorites_provider.dart";
import "package:provider/provider.dart";

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (ctx) => FavoritesProvider(),
      child: const MyApp(),
    ),
  );
}

var kColorScheme = ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B35));

// dar theme
var kDarkColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 5, 99, 125),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark().copyWith(colorScheme: kDarkColorScheme),
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        scaffoldBackgroundColor: kColorScheme.surface,
        appBarTheme: AppBarTheme(backgroundColor: kColorScheme.inversePrimary),
        cardTheme: CardThemeData(
          color: kColorScheme.secondaryContainer,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ), // CardThemeData
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kColorScheme.primaryContainer,
          ),
        ),
        textTheme: ThemeData().textTheme.copyWith(
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            color: kColorScheme.onSecondaryContainer,
            fontSize: 18,
            fontFamily: GoogleFonts.lato().fontFamily,
          ),
        ),
      ),
      home: const TabsScreen(),
    );
  }
}
