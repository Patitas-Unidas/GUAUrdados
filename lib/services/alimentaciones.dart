import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:guaurdados_oficial/services/cuidados.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';

class Alimentaciones {
  Alimentaciones._();

  static final recientes = ValueNotifier<Map<String, List<Alimentacion>>>(const {});
  static StreamSubscription<Map<String, List<Alimentacion>>>? _suscripcion;

  static void escuchar() {
    _suscripcion ??= ForoRepository().observarAlimentacionesRecientes().listen(
      (porPerro) => recientes.value = porPerro,
      onError: (_) => _suscripcion = null,
      onDone: () => _suscripcion = null,
    );
  }

  static List<Alimentacion> de(String idPerro) => recientes.value[idPerro] ?? const [];
}
