import 'package:firebase_auth/firebase_auth.dart';

import 'foro_repository.dart';

class PermisoPublicar {
  const PermisoPublicar({required this.puede, this.desde});

  final bool puede;
  final DateTime? desde;
}

class PermisosUsuario {
  PermisosUsuario._();

  static const antiguedadParaPublicar = Duration(days: 2);
  static const rachaParaPublicar = 2;

  static (String, Future<bool>)? _admin;

  static Future<bool> esAdmin() {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return Future.value(false);
    if (_admin?.$1 != usuario.uid) {
      _admin = (usuario.uid, usuario.getIdTokenResult().then((r) => r.claims?['admin'] == true).catchError((_) => false));
    }
    return _admin!.$2;
  }

  static Future<PermisoPublicar> puedePublicar() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return const PermisoPublicar(puede: false);
    final creada = usuario.metadata.creationTime;
    final desde = creada?.add(antiguedadParaPublicar);
    if (desde == null || !DateTime.now().isBefore(desde)) return const PermisoPublicar(puede: true);
    if (await esAdmin()) return const PermisoPublicar(puede: true);
    final racha = await ForoRepository()
        .observarResumenUsuario(usuario.uid)
        .first
        .then((resumen) => resumen.rachaDias)
        .timeout(const Duration(seconds: 8), onTimeout: () => 0)
        .catchError((_) => 0);
    return PermisoPublicar(puede: racha >= rachaParaPublicar, desde: desde);
  }
}
