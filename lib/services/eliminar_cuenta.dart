import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'notificaciones_service.dart';

class EliminarCuenta {
  EliminarCuenta._();

  static const nombreEliminado = 'Usuario eliminado';
  static const _tiposConversacion = {'normal', 'perrito_nuevo'};

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static Future<void> confirmarIdentidad(User usuario, String contrasena) async {
    final correo = usuario.email;
    if (correo == null) throw FirebaseAuthException(code: 'invalid-credential');
    await usuario.reauthenticateWithCredential(EmailAuthProvider.credential(email: correo, password: contrasena));
  }

  static Future<void> eliminar(User usuario) async {
    try {
      await NotificacionesService.desregistrar().timeout(const Duration(seconds: 5));
    } catch (_) {}
    await borrarDatos(usuario.uid);
    await usuario.delete();
  }

  static Future<void> borrarDatos(String uid) async {
    final lotes = _Lotes(_firestore);

    final propias = await _firestore.collectionGroup('publicaciones').where('idUsuario', isEqualTo: uid).get();
    final borradas = <String>{};
    for (final documento in propias.docs) {
      if (_tiposConversacion.contains(documento.data()['tipoPublicacion'])) {
        borradas.add(documento.reference.path);
        lotes.borrar(documento.reference);
      } else {
        lotes.actualizar(documento.reference, {'nombreUsuario': nombreEliminado, 'fotoUsuario': FieldValue.delete()});
      }
    }
    await lotes.enviar();

    for (final tipo in _tiposConversacion) {
      final publicaciones = await _firestore
          .collectionGroup('publicaciones')
          .where('tipoPublicacion', isEqualTo: tipo)
          .orderBy('creadoEn', descending: true)
          .get();
      for (final publicacion in publicaciones.docs) {
        if (borradas.contains(publicacion.reference.path)) continue;
        final datos = publicacion.data();
        final reacciones = datos['reacciones'];
        if (reacciones is Map && reacciones.containsKey(uid)) {
          await publicacion.reference.update({'reacciones.$uid': FieldValue.delete()});
        }
        if ((datos['numComentarios'] as num? ?? 0) <= 0) continue;
        final comentarios = await publicacion.reference.collection('comentarios').where('idUsuario', isEqualTo: uid).get();
        var ultimoEsMio = datos['ultimoComentario'] is Map && (datos['ultimoComentario'] as Map)['idUsuario'] == uid;
        for (final comentario in comentarios.docs) {
          await (_firestore.batch()
                ..delete(comentario.reference)
                ..update(publicacion.reference, {
                  'numComentarios': FieldValue.increment(-1),
                  if (ultimoEsMio) 'ultimoComentario': FieldValue.delete(),
                }))
              .commit();
          ultimoEsMio = false;
        }
      }
    }

    final emergencias = await _firestore.collection('emergencias').where('creadoPor', isEqualTo: uid).get();
    for (final documento in emergencias.docs) {
      if (documento.data()['nombreUsuario'] != nombreEliminado) {
        lotes.actualizar(documento.reference, {'nombreUsuario': nombreEliminado});
      }
    }

    final seguidos = await _firestore.collection('perros').where('seguidores', arrayContains: uid).get();
    for (final documento in seguidos.docs) {
      lotes.actualizar(documento.reference, {'seguidores': FieldValue.arrayRemove([uid])});
    }

    final reportes = await _firestore.collection('reportes').where('idReportante', isEqualTo: uid).get();
    for (final documento in reportes.docs) {
      lotes.borrar(documento.reference);
    }

    lotes.borrar(_firestore.doc('perfiles_publicos/$uid'));
    lotes.borrar(_firestore.doc('usuarios/$uid'));
    await lotes.enviar();
  }
}

class _Lotes {
  _Lotes(this._firestore);

  final FirebaseFirestore _firestore;
  late WriteBatch _lote = _firestore.batch();
  int _cantidad = 0;
  final _pendientes = <Future<void>>[];

  void borrar(DocumentReference referencia) {
    _lote.delete(referencia);
    _sumar();
  }

  void actualizar(DocumentReference referencia, Map<String, Object?> datos) {
    _lote.update(referencia, datos);
    _sumar();
  }

  void _sumar() {
    if (++_cantidad < 400) return;
    _pendientes.add(_lote.commit());
    _lote = _firestore.batch();
    _cantidad = 0;
  }

  Future<void> enviar() async {
    if (_cantidad > 0) _pendientes.add(_lote.commit());
    _lote = _firestore.batch();
    _cantidad = 0;
    await Future.wait(_pendientes);
    _pendientes.clear();
  }
}
