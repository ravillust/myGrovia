import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/collection_page.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff4f8e73)),
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: TextTheme(
          titleLarge: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          headlineSmall: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
          ),
          bodyLarge: GoogleFonts.inter(),
          bodyMedium: GoogleFonts.inter(),
          labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        scaffoldBackgroundColor: const Color(0xfff8faf7),
        useMaterial3: true,
      ),
      home: const CollectionPage(),
    );
  }
}
