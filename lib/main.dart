import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor:Color(0xff4f8e73),
        ),
        scaffoldBackgroundColor:  Color(0xfff7faf7),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'myGrovia',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xfff7faf7),
      ),
      body: const Center(
        child: Text(
          'Rawat tanamanmu bersama myGrovia',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}