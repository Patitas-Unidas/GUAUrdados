import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NovedadesDescartadas {
  NovedadesDescartadas(this.uid);
  final String uid;
  final Map<String, int> _versiones = {};

  String get _clave => 'novedades_descartadas_$uid';

  Future<void> cargar() async {
    try {
      final guardadas = (await SharedPreferences.getInstance()).getString(_clave);
      if (guardadas == null) return;
      final mapa = jsonDecode(guardadas) as Map<String, dynamic>;
      _versiones.addAll(mapa.map((clave, version) => MapEntry(clave, (version as num).toInt())));
    } catch (_) {}
  }

  bool estaDescartada(String clave, int version) {
    final descartada = _versiones[clave];
    return descartada != null && descartada >= version;
  }

  Future<void> descartar(Map<String, int> novedades) async {
    _versiones.addAll(novedades);
    try {
      await (await SharedPreferences.getInstance()).setString(_clave, jsonEncode(_versiones));
    } catch (_) {}
  }
}
