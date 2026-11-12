import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum MotivoReporte {
  ofensivo('ofensivo', 'Ofensivo o irrespetuoso'),
  acoso('acoso', 'Acoso o amenazas'),
  spam('spam', 'Spam o publicidad'),
  falso('falso', 'Información falsa'),
  datosPersonales('datos_personales', 'Datos personales de alguien'),
  maltrato('maltrato', 'Maltrato animal'),
  otro('otro', 'Otro motivo');

  const MotivoReporte(this.clave, this.texto);

  final String clave;
  final String texto;

  static MotivoReporte desde(String? clave) => values.firstWhere((m) => m.clave == clave, orElse: () => otro);
}

enum TipoContenido {
  publicacion('publicacion', 'publicación', 'esta publicación', 'la'),
  comentario('comentario', 'comentario', 'este comentario', 'lo');

  const TipoContenido(this.clave, this.texto, this.conEste, this.pronombre);

  final String clave;
  final String texto;
  final String conEste;
  final String pronombre;

  static TipoContenido desde(String? clave) => clave == comentario.clave ? comentario : publicacion;
}

class ContenidoReportable {
  const ContenidoReportable({
    required this.tipo,
    required this.ruta,
    required this.idAutor,
    required this.nombreAutor,
    required this.texto,
    this.fotoAutor,
    this.rutaPublicacion,
  });

  final TipoContenido tipo;
  final String ruta;
  final String idAutor;
  final String nombreAutor;
  final String texto;
  final String? fotoAutor;
  final String? rutaPublicacion;
}

class UsuarioBloqueado {
  const UsuarioBloqueado({required this.uid, required this.nombre, this.fotoUrl, this.en});

  final String uid;
  final String nombre;
  final String? fotoUrl;
  final DateTime? en;
}

enum ResultadoReporte { enviado, pendiente, repetido, error }

class Reporte {
  const Reporte({
    required this.id,
    required this.contenido,
    required this.motivo,
    required this.detalle,
    required this.idReportante,
    required this.nombreReportante,
    required this.creadoEn,
  });

  final String id;
  final ContenidoReportable contenido;
  final MotivoReporte motivo;
  final String detalle;
  final String idReportante;
  final String nombreReportante;
  final DateTime? creadoEn;

  factory Reporte.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> documento) {
    final datos = documento.data();
    final creado = datos['creadoEn'];
    return Reporte(
      id: documento.id,
      contenido: ContenidoReportable(
        tipo: TipoContenido.desde(datos['tipo'] as String?),
        ruta: datos['ruta'] as String? ?? '',
        rutaPublicacion: datos['rutaPublicacion'] as String?,
        idAutor: datos['idAutor'] as String? ?? '',
        nombreAutor: datos['nombreAutor'] as String? ?? 'Usuario',
        fotoAutor: datos['fotoAutor'] as String?,
        texto: datos['texto'] as String? ?? '',
      ),
      motivo: MotivoReporte.desde(datos['motivo'] as String?),
      detalle: datos['detalle'] as String? ?? '',
      idReportante: datos['idReportante'] as String? ?? '',
      nombreReportante: datos['nombreReportante'] as String? ?? 'Usuario',
      creadoEn: creado is Timestamp ? creado.toDate() : null,
    );
  }
}

class ReportesDeContenido {
  const ReportesDeContenido(this.reportes);

  final List<Reporte> reportes;

  ContenidoReportable get contenido => reportes.first.contenido;
  DateTime? get ultimo => reportes.map((r) => r.creadoEn).whereType<DateTime>().fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);
  List<MotivoReporte> get motivos => {for (final r in reportes) r.motivo}.toList();
}

class Moderacion {
  Moderacion._();

  static final bloqueados = ValueNotifier<Map<String, UsuarioBloqueado>>(const {});
  static StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _suscripcion;
  static String? _uid;

  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static void escuchar() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _suscripcion?.cancel();
      _suscripcion = null;
      _uid = null;
      bloqueados.value = const {};
      return;
    }
    if (_uid == uid && _suscripcion != null) return;
    _suscripcion?.cancel();
    _uid = uid;
    bloqueados.value = const {};
    _suscripcion = _firestore.doc('usuarios/$uid').snapshots().listen(
      (documento) => bloqueados.value = _leerBloqueados(documento.data()?['bloqueados']),
      onError: (_) => _suscripcion = null,
      onDone: () => _suscripcion = null,
    );
  }

  static Map<String, UsuarioBloqueado> _leerBloqueados(Object? crudo) {
    if (crudo is! Map) return const {};
    return {
      for (final MapEntry(:key, :value) in crudo.entries)
        if (key is String && value is Map)
          key: UsuarioBloqueado(
            uid: key,
            nombre: value['nombre'] as String? ?? 'Usuario',
            fotoUrl: value['fotoUrl'] as String?,
            en: value['en'] is Timestamp ? (value['en'] as Timestamp).toDate() : null,
          ),
    };
  }

  static bool estaBloqueado(String? uid) => uid != null && uid.isNotEmpty && bloqueados.value.containsKey(uid);

  static Future<void> bloquear(String uid, String nombre, {String? fotoUrl}) {
    final propio = FirebaseAuth.instance.currentUser?.uid;
    if (propio == null || uid.isEmpty || uid == propio) return Future.value();
    final foto = fotoUrl?.trim() ?? '';
    return _firestore.doc('usuarios/$propio').set({
      'bloqueados': {
        uid: {'nombre': nombre, if (foto.isNotEmpty) 'fotoUrl': foto, 'en': FieldValue.serverTimestamp()},
      },
    }, SetOptions(merge: true));
  }

  static Future<void> desbloquear(String uid) {
    final propio = FirebaseAuth.instance.currentUser?.uid;
    if (propio == null) return Future.value();
    return _firestore.doc('usuarios/$propio').update({'bloqueados.$uid': FieldValue.delete()});
  }

  static String idReporte(String uid, String ruta) => '${uid}__${ruta.replaceAll('/', '_')}';

  static Future<ResultadoReporte> reportar(ContenidoReportable contenido, MotivoReporte motivo, {String detalle = ''}) async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return ResultadoReporte.error;
    final nombre = usuario.displayName?.trim().isNotEmpty == true ? usuario.displayName!.trim() : 'Usuario';
    final texto = contenido.texto.trim();
    final nota = detalle.trim();
    final foto = contenido.fotoAutor?.trim() ?? '';
    final datos = <String, dynamic>{
      'tipo': contenido.tipo.clave,
      'ruta': contenido.ruta,
      if (contenido.rutaPublicacion != null) 'rutaPublicacion': contenido.rutaPublicacion,
      'idAutor': contenido.idAutor,
      'nombreAutor': contenido.nombreAutor,
      if (foto.isNotEmpty) 'fotoAutor': foto,
      'texto': texto.length > 2000 ? texto.substring(0, 2000) : texto,
      'motivo': motivo.clave,
      if (nota.isNotEmpty) 'detalle': nota,
      'idReportante': usuario.uid,
      'nombreReportante': nombre,
      'estado': 'pendiente',
      'creadoEn': FieldValue.serverTimestamp(),
    };
    try {
      await _firestore
          .collection('reportes')
          .doc(idReporte(usuario.uid, contenido.ruta))
          .set(datos)
          .timeout(const Duration(seconds: 15));
      return ResultadoReporte.enviado;
    } on TimeoutException {
      return ResultadoReporte.pendiente;
    } on FirebaseException catch (e) {
      return e.code == 'permission-denied' ? ResultadoReporte.repetido : ResultadoReporte.error;
    } catch (_) {
      return ResultadoReporte.error;
    }
  }

  static Stream<List<ReportesDeContenido>> observarPendientes() => _firestore
      .collection('reportes')
      .where('estado', isEqualTo: 'pendiente')
      .limit(200)
      .snapshots()
      .map((snapshot) {
        final porRuta = <String, List<Reporte>>{};
        for (final documento in snapshot.docs) {
          final reporte = Reporte.fromFirestore(documento);
          porRuta.putIfAbsent(reporte.contenido.ruta, () => []).add(reporte);
        }
        final grupos = porRuta.values.map(ReportesDeContenido.new).toList()
          ..sort((a, b) => (b.ultimo?.millisecondsSinceEpoch ?? 0).compareTo(a.ultimo?.millisecondsSinceEpoch ?? 0));
        return grupos;
      });

  static Future<void> resolver(ReportesDeContenido grupo, {required bool eliminarContenido}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final contenido = grupo.contenido;
    if (eliminarContenido) {
      final referencia = _firestore.doc(contenido.ruta);
      final rutaPublicacion = contenido.rutaPublicacion;
      if (contenido.tipo == TipoContenido.comentario && rutaPublicacion != null) {
        final publicacion = await _firestore.doc(rutaPublicacion).get();
        final comentario = await referencia.get();
        if (publicacion.exists && comentario.exists) {
          await (_firestore.batch()
                ..delete(referencia)
                ..update(publicacion.reference, {'numComentarios': FieldValue.increment(-1)}))
              .commit();
        } else if (comentario.exists) {
          await referencia.delete();
        }
      } else {
        await referencia.delete();
      }
    }
    final lote = _firestore.batch();
    for (final reporte in grupo.reportes) {
      lote.update(_firestore.collection('reportes').doc(reporte.id), {
        'estado': eliminarContenido ? 'eliminado' : 'descartado',
        'resueltoEn': FieldValue.serverTimestamp(),
        'resueltoPor': uid,
      });
    }
    await lote.commit();
  }
}
