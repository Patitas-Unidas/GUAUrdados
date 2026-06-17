import 'package:flutter/material.dart';
import 'homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GUAUrdados',
      theme: ThemeData(
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color.fromRGBO(238,210,195,1),
        textTheme: const TextTheme().copyWith(
          bodySmall: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1)),
          bodyMedium: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1)),
          bodyLarge: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1)),
          labelSmall: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1)),
          labelMedium: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1)),
          labelLarge: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1)),
          displaySmall: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1)),
          displayMedium: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1)),
          displayLarge: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1)),
        ),
      ),
      home: Homepage(),
    );
  }
}

