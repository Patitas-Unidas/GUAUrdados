import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/registro_usuario.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'homepage.dart';
import 'registro_usuario.dart';
import 'iniciar_sesion.dart';

void main() async {
  // 1. Aseguramos que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializamos Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
          bodySmall: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1), letterSpacing: -.3),
          bodyMedium: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1), letterSpacing: -.3),
          bodyLarge: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1), letterSpacing: -.3),
          labelSmall: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1), letterSpacing: -.3),
          labelMedium: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1), letterSpacing: -.3),
          labelLarge: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1), letterSpacing: -.3),
          displaySmall: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1), letterSpacing: -.3),
          displayMedium: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1), letterSpacing: -.3),
          displayLarge: const TextStyle(color: Color.fromRGBO(56, 54, 53, 1), letterSpacing: -.3),
        ),
      ),
      //home: Homepage(),
      home: const IniciarSesion(),
    );
  }
}

