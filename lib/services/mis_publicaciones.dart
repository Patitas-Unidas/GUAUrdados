import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:guaurdados_oficial/models/publicacion_foro.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';

class MisPublicaciones {
  MisPublicaciones._();

  static final recientes = ValueNotifier<List<PublicacionForo>>(const []);
  static StreamSubscription<List<PublicacionForo>>? _suscripcion;
  static String? _uid;

  static void escuchar() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_uid == uid && _suscripcion != null) return;
    _suscripcion?.cancel();
    _uid = uid;
    recientes.value = const [];
    _suscripcion = ForoRepository().observarPublicacionesDe(uid).listen(
      (lista) => recientes.value = lista,
      onError: (_) => _suscripcion = null,
      onDone: () => _suscripcion = null,
    );
  }
}
