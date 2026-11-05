import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/comentario.dart';
import '../models/publicacion_foro.dart';
import 'cuidados.dart';

class ForoRepository {
  ForoRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Query<Map<String, dynamic>> get _publicaciones =>
      _firestore.collectionGroup('publicaciones');

  Stream<List<PublicacionForo>> observarPublicaciones({String? idPerro}) {
    Query<Map<String, dynamic>> consulta = _publicaciones;
    if (idPerro != null) {
      return consulta
          .where('idPerro', isEqualTo: idPerro)
          .limit(100)
          .snapshots()
          .map((snapshot) {
            final publicaciones = snapshot.docs
                .map(PublicacionForo.fromFirestore)
                .toList();
            publicaciones.sort(_ordenarRecientes);
            return publicaciones;
          });
    }

    return consulta
        .orderBy('creadoEn', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(PublicacionForo.fromFirestore)
              .toList(),
        );
  }

  Stream<Map<String, List<Alimentacion>>> observarAlimentacionesRecientes() => _publicaciones
      .where('creadoEn', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(ReglasCuidado.historial)))
      .orderBy('creadoEn', descending: true)
      .limit(300)
      .snapshots()
      .map((snapshot) {
        final porPerro = <String, List<Alimentacion>>{};
        for (final documento in snapshot.docs) {
          final publicacion = PublicacionForo.fromFirestore(documento);
          final alimentacion = Alimentacion.desde(publicacion);
          if (alimentacion != null) porPerro.putIfAbsent(publicacion.idPerro, () => []).add(alimentacion);
        }
        return porPerro;
      });

  Stream<List<PublicacionForo>> observarPublicacionesDe(String uid) =>
      _publicaciones.where('idUsuario', isEqualTo: uid).snapshots().map((snapshot) => snapshot.docs.map(PublicacionForo.fromFirestore).toList());

  Stream<ResumenActividadForo> observarResumenUsuario(String uid) =>
      _publicaciones.where('idUsuario', isEqualTo: uid).snapshots().map((snapshot) {
        final actividad = snapshot.docs.map(PublicacionForo.fromFirestore).toList()
          ..sort(_ordenarRecientes);
        final registros = actividad.where((publicacion) =>
          const {'normal', 'alimentacion', 'estado_medico'}.contains(publicacion.tipoPublicacion),
        ).toList();
        final perros = registros.map((publicacion) => publicacion.idPerro).where((id) => id.isNotEmpty).toSet();
        return ResumenActividadForo(
          perrosAyudados: perros.length,
          registros: registros.length,
          rachaDias: _rachaActual(registros),
          actividadReciente: actividad.where((publicacion) => registros.contains(publicacion) || publicacion.esPerritoNuevo).take(8).toList(),
        );
      });

  int _rachaActual(List<PublicacionForo> registros) {
    String clave(DateTime fecha) => '${fecha.year}-${fecha.month}-${fecha.day}';
    final diasActivos = registros
        .map((registro) => registro.creadoEn)
        .whereType<DateTime>()
        .map((fecha) => clave(fecha))
        .toSet();
    final ahora = DateTime.now();
    var cursor = DateTime(ahora.year, ahora.month, ahora.day);
    final ayer = DateTime(cursor.year, cursor.month, cursor.day - 1);
    if (!diasActivos.contains(clave(cursor))) {
      if (!diasActivos.contains(clave(ayer))) return 0;
      cursor = ayer;
    }

    var racha = 0;
    while (diasActivos.contains(clave(cursor))) {
      racha++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return racha;
  }

  static int _ordenarRecientes(PublicacionForo a, PublicacionForo b) =>
      (b.creadoEn?.millisecondsSinceEpoch ?? 0)
          .compareTo(a.creadoEn?.millisecondsSinceEpoch ?? 0);

  Future<void> crearPublicacion({
    required String idPerro,
    required String nombrePerro,
    required User usuario,
    required String tipoPublicacion,
    String? descripcion,
    String? tipoComida,
    String? cantidadComida,
    String? procedimiento,
  }) async {
    if (!['normal', 'alimentacion', 'estado_medico'].contains(tipoPublicacion)) {
      throw ArgumentError.value(tipoPublicacion, 'tipoPublicacion');
    }

    final texto = descripcion?.trim() ?? '';
    if (tipoPublicacion == 'normal' && texto.isEmpty) {
      throw ArgumentError.value(descripcion, 'descripcion');
    }
    if (tipoPublicacion == 'alimentacion' &&
        ((tipoComida?.trim().isEmpty ?? true) ||
            (cantidadComida?.trim().isEmpty ?? true))) {
      throw ArgumentError('La alimentación requiere tipo y cantidad.');
    }
    if (tipoPublicacion == 'estado_medico' &&
        (procedimiento?.trim().isEmpty ?? true)) {
      throw ArgumentError('El estado médico requiere un detalle.');
    }

    final foros = _firestore.collection('foro');
    final forosExistentes = await foros
        .where('idperro', isEqualTo: idPerro)
        .limit(1)
        .get();
    final foro = forosExistentes.docs.isNotEmpty
        ? forosExistentes.docs.first.reference
        : foros.doc(idPerro);
    if (forosExistentes.docs.isEmpty) {
      await foro.set({'idperro': idPerro}, SetOptions(merge: true));
    }

    final nombreCorreo = usuario.email?.split('@').first.trim() ?? '';
    final nombre = usuario.displayName?.trim().isNotEmpty == true
        ? usuario.displayName!.trim()
        : nombreCorreo.isNotEmpty
            ? nombreCorreo
            : 'Usuario';

    final data = <String, dynamic>{
      'idPerro': idPerro,
      'nombrePerro': nombrePerro,
      'idUsuario': usuario.uid,
      'nombreUsuario': nombre,
      'tipoPublicacion': tipoPublicacion,
      'descripcion': texto,
      'creadoEn': FieldValue.serverTimestamp(),
    };
    final foto = usuario.photoURL?.trim();
    if (foto != null && foto.isNotEmpty) data['fotoUsuario'] = foto;

    if (tipoPublicacion == 'alimentacion') {
      data['tipoComida'] = tipoComida!.trim();
      data['cantidadComida'] = cantidadComida!.trim();
    }
    if (tipoPublicacion == 'estado_medico') {
      data['procedimiento'] = procedimiento!.trim();
    }

    await foro.collection('publicaciones').add(data);
  }

  Future<void> registrarAlimentacion({
    required String idPerro,
    required String nombrePerro,
    required User usuario,
    required String tipoComida,
    required String cantidadComida,
  }) async {
    final comida = tipoComida.trim();
    final cantidad = cantidadComida.trim();
    if (comida.isEmpty || comida.length > 60 || cantidad.isEmpty || cantidad.length > 80) {
      throw ArgumentError('Completa el alimento y una cantidad válida.');
    }

    final foro = await _obtenerOCrearForo(idPerro);
    final nombre = _nombreUsuario(usuario);
    final foto = usuario.photoURL?.trim();
    final ahoraServidor = FieldValue.serverTimestamp();
    final publicacion = <String, dynamic>{
      'idPerro': idPerro,
      'nombrePerro': nombrePerro,
      'idUsuario': usuario.uid,
      'nombreUsuario': nombre,
      'tipoPublicacion': 'alimentacion',
      'descripcion': '',
      'tipoComida': comida,
      'cantidadComida': cantidad,
      'creadoEn': ahoraServidor,
    };
    if (foto != null && foto.isNotEmpty) publicacion['fotoUsuario'] = foto;

    final lote = _firestore.batch();
    lote.update(
      _firestore.collection('perros').doc(idPerro),
      tipoAlimento(comida) == TipoAlimento.agua
          ? {'ultimaAguaEn': ahoraServidor, 'actualizadoEn': ahoraServidor}
          : {'ultimaComida': '$comida · $cantidad', 'ultimaComidaEn': ahoraServidor, 'actualizadoEn': ahoraServidor},
    );
    lote.set(foro.collection('publicaciones').doc(), publicacion);
    await lote.commit();
  }

  Future<void> avisarPerritoNuevo({required User usuario, required String descripcion, String ubicacion = '', File? foto}) async {
    final datos = <String, dynamic>{
      'idUsuario': usuario.uid,
      'nombreUsuario': _nombreUsuario(usuario),
      'tipoPublicacion': 'perrito_nuevo',
      'descripcion': descripcion.trim(),
      'creadoEn': FieldValue.serverTimestamp(),
    };
    final fotoUsuario = usuario.photoURL?.trim();
    if (fotoUsuario != null && fotoUsuario.isNotEmpty) datos['fotoUsuario'] = fotoUsuario;
    if (ubicacion.trim().isNotEmpty) datos['ubicacion'] = ubicacion.trim();
    if (foto != null) {
      final archivo = FirebaseStorage.instance.ref('avisos/${usuario.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await archivo.putFile(foto, SettableMetadata(contentType: 'image/jpeg'));
      datos['fotoUrl'] = await archivo.getDownloadURL();
    }
    await _firestore.collection('foro').doc('sin_registrar').collection('publicaciones').add(datos);
  }

  Future<void> reaccionar(PublicacionForo publicacion, User usuario, String? emoji) {
    final datos = emoji == null
        ? FieldValue.delete()
        : <String, dynamic>{
            'e': emoji,
            'n': _nombreUsuario(usuario),
            if ((usuario.photoURL ?? '').trim().isNotEmpty) 'f': usuario.photoURL!.trim(),
          };
    return _firestore.doc(publicacion.ruta).update({'reacciones.${usuario.uid}': datos});
  }

  Stream<List<Comentario>> observarComentarios(PublicacionForo publicacion) =>
      _firestore.doc(publicacion.ruta).collection('comentarios').limit(300).snapshots().map((snapshot) {
        final comentarios = snapshot.docs.map(Comentario.fromFirestore).toList()
          ..sort((a, b) => (a.creadoEn ?? DateTime(9999)).compareTo(b.creadoEn ?? DateTime(9999)));
        return comentarios;
      });

  Future<void> comentar(PublicacionForo publicacion, User usuario, String texto) {
    final limpio = texto.trim();
    if (limpio.isEmpty || limpio.length > 500) throw ArgumentError.value(texto, 'texto');
    final nombre = _nombreUsuario(usuario);
    final foto = usuario.photoURL?.trim() ?? '';
    final ahora = FieldValue.serverTimestamp();
    final publicacionRef = _firestore.doc(publicacion.ruta);
    final lote = _firestore.batch()
      ..set(publicacionRef.collection('comentarios').doc(), {
        'idUsuario': usuario.uid,
        'nombreUsuario': nombre,
        if (foto.isNotEmpty) 'fotoUsuario': foto,
        'texto': limpio,
        'creadoEn': ahora,
      })
      ..update(publicacionRef, {
        'numComentarios': FieldValue.increment(1),
        'ultimoComentario': {'idUsuario': usuario.uid, 'nombre': nombre, 'en': ahora},
      });
    return lote.commit();
  }

  Future<void> eliminarComentario(PublicacionForo publicacion, Comentario comentario) {
    final publicacionRef = _firestore.doc(publicacion.ruta);
    final lote = _firestore.batch()
      ..delete(publicacionRef.collection('comentarios').doc(comentario.id))
      ..update(publicacionRef, {'numComentarios': FieldValue.increment(-1)});
    return lote.commit();
  }

  Future<void> eliminarPublicacion(PublicacionForo publicacion) async {
    await _firestore.doc(publicacion.ruta).delete();
    final foto = publicacion.fotoUrl ?? '';
    if (foto.isNotEmpty) await FirebaseStorage.instance.refFromURL(foto).delete().catchError((_) {});
  }

  Future<DocumentReference<Map<String, dynamic>>> _obtenerOCrearForo(String idPerro) async {
    final foros = _firestore.collection('foro');
    final existentes = await foros.where('idperro', isEqualTo: idPerro).limit(1).get();
    if (existentes.docs.isNotEmpty) return existentes.docs.first.reference;
    final foro = foros.doc(idPerro);
    await foro.set({'idperro': idPerro}, SetOptions(merge: true));
    return foro;
  }

  String _nombreUsuario(User usuario) {
    final nombre = usuario.displayName?.trim() ?? '';
    if (nombre.isNotEmpty) return nombre;
    final correo = usuario.email?.split('@').first.trim() ?? '';
    return correo.isEmpty ? 'Usuario' : correo;
  }
}

class ResumenActividadForo {
  const ResumenActividadForo({
    required this.perrosAyudados,
    required this.registros,
    required this.rachaDias,
    required this.actividadReciente,
  });

  final int perrosAyudados;
  final int registros;
  final int rachaDias;
  final List<PublicacionForo> actividadReciente;
}
