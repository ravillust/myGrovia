import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'widgets/plant_widgets.dart';

void main() {
  runApp(const MyGroviaApp());
}

class MyGroviaApp extends StatelessWidget {
  const MyGroviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'myGrovia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: plantGreen).copyWith(
          primary: plantGreen,
          secondaryContainer: neutralSurface,
          surface: Colors.white,
          surfaceTint: Colors.transparent,
        ),
        fontFamily: 'PlusJakartaSans',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
          ),
          titleLarge: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.w700,
          ),
          labelLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        scaffoldBackgroundColor: const Color(0xfffaf9f6),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xfffaf9f6),
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: plantGreen, width: 1.5),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffdce2dc)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xffdce2dc)),
          ),
        ),
        chipTheme: ChipThemeData(
          selectedColor: neutralSurface,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
