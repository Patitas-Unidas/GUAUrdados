import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferencias {
  static const _claveTema = 'tema';
  static const _claveTexto = 'escala_texto';

  static final tema = ValueNotifier<ThemeMode>(ThemeMode.light);

  static final escalaTexto = ValueNotifier<double>(1);
  static const escalasTexto = [(1.0, 'Normal'), (1.15, 'Grande')];

  static Future<void> cargar() async {
    try {
      final guardadas = await SharedPreferences.getInstance();
      final nombreTema = guardadas.getString(_claveTema);
      tema.value = ThemeMode.values.firstWhere((m) => m.name == nombreTema, orElse: () => ThemeMode.light);
      final escala = guardadas.getDouble(_claveTexto);
      if (escalasTexto.any((e) => e.$1 == escala)) escalaTexto.value = escala!;
    } catch (_) {}
  }

  static Future<void> cambiarTema(ThemeMode nuevo) async {
    tema.value = nuevo;
    await _guardar((g) => g.setString(_claveTema, nuevo.name));
  }

  static Future<void> cambiarEscalaTexto(double nueva) async {
    escalaTexto.value = nueva;
    await _guardar((g) => g.setDouble(_claveTexto, nueva));
  }

  static Future<void> _guardar(Future<bool> Function(SharedPreferences) escribir) async {
    try {
      await escribir(await SharedPreferences.getInstance());
    } catch (_) {}
  }
}
