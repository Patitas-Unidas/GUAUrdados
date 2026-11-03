import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:guaurdados_oficial/models/emergencia.dart';
import 'package:guaurdados_oficial/services/emergencias_repository.dart';

class Emergencias {
  Emergencias._();

  static final recientes = ValueNotifier<List<Emergencia>>(const []);
  static StreamSubscription<List<Emergencia>>? _suscripcion;

  static void escuchar() {
    _suscripcion ??= EmergenciasRepository().observarRecientes().listen(
      (lista) => recientes.value = lista,
      onError: (_) => _suscripcion = null,
      onDone: () => _suscripcion = null,
    );
  }

  static List<Emergencia> enForo({String? idPerro}) {
    final ahora = DateTime.now();
    return recientes.value
        .where((e) => e.visibleEnForo(ahora) && (idPerro == null || e.involucra(idPerro)))
        .toList()
      ..sort(ordenarEmergencias);
  }
}
