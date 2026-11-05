import 'package:cloud_firestore/cloud_firestore.dart';

enum ResultadoAviso { registrado, yaRegistrado }

const emojisReaccion = ['❤️', '🥰', '🐶', '😂', '😮', '😢', '💪'];

class Reaccion {
  const Reaccion({required this.uid, required this.emoji, required this.nombre, this.foto});

  final String uid;
  final String emoji;
  final String nombre;
  final String? foto;
}

/// Publicación visible en el foro general o en el foro de un perro.
///
/// El ID del documento de Firestore es el ID de la publicación. El documento
/// padre del foro usa el ID del perro, así que no hace falta guardar otro ID
/// de foro en cada perro.
class PublicacionForo {
  const PublicacionForo({
    required this.id,
    this.ruta = '',
    required this.idPerro,
    required this.nombrePerro,
    required this.idUsuario,
    required this.nombreUsuario,
    required this.tipoPublicacion,
    required this.descripcion,
    required this.creadoEn,
    this.fotoUsuario,
    this.tipoComida,
    this.cantidadComida,
    this.procedimiento,
    this.ubicacion,
    this.fotoUrl,
    this.resultadoAviso,
    this.idPerroAviso,
    this.notaGuau,
    this.reacciones = const [],
    this.numComentarios = 0,
    this.ultimoComentarioDe,
    this.ultimoComentarioPor,
    this.ultimoComentarioEn,
  });

  final String id;
  final String ruta;
  final String idPerro;
  final String nombrePerro;
  final String idUsuario;
  final String nombreUsuario;
  final String tipoPublicacion;
  final String descripcion;
  final DateTime? creadoEn;
  final String? fotoUsuario;
  final String? tipoComida;
  final String? cantidadComida;
  final String? procedimiento;
  final String? ubicacion;
  final String? fotoUrl;
  final ResultadoAviso? resultadoAviso;
  final String? idPerroAviso;
  final String? notaGuau;
  final List<Reaccion> reacciones;
  final int numComentarios;
  final String? ultimoComentarioDe;
  final String? ultimoComentarioPor;
  final DateTime? ultimoComentarioEn;

  bool get admiteReacciones => tipoPublicacion == 'normal' || esPerritoNuevo;

  String? reaccionDe(String? uid) {
    for (final reaccion in reacciones) {
      if (reaccion.uid == uid) return reaccion.emoji;
    }
    return null;
  }

  List<String> get emojisPrincipales {
    final cuenta = <String, int>{};
    for (final reaccion in reacciones) {
      cuenta[reaccion.emoji] = (cuenta[reaccion.emoji] ?? 0) + 1;
    }
    final orden = cuenta.keys.toList()
      ..sort((a, b) => cuenta[b]! != cuenta[a]! ? cuenta[b]!.compareTo(cuenta[a]!) : emojisReaccion.indexOf(a).compareTo(emojisReaccion.indexOf(b)));
    return orden.take(3).toList();
  }

  bool get esPerritoNuevo => tipoPublicacion == 'perrito_nuevo';
  bool get avisoRevisado => esPerritoNuevo && resultadoAviso != null;

  factory PublicacionForo.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final creado = data['creadoEn'];
    final ultimo = data['ultimoComentario'];
    final ultimoEn = ultimo is Map ? ultimo['en'] : null;

    return PublicacionForo(
      id: document.id,
      ruta: document.reference.path,
      idPerro: data['idPerro'] as String? ?? '',
      nombrePerro: data['nombrePerro'] as String? ?? 'Un perrito',
      idUsuario: data['idUsuario'] as String? ?? '',
      nombreUsuario: data['nombreUsuario'] as String? ?? 'Usuario',
      tipoPublicacion: data['tipoPublicacion'] as String? ?? 'normal',
      descripcion: data['descripcion'] as String? ?? '',
      creadoEn: creado is Timestamp ? creado.toDate() : null,
      fotoUsuario: data['fotoUsuario'] as String?,
      tipoComida: data['tipoComida'] as String?,
      cantidadComida: data['cantidadComida'] as String?,
      procedimiento: data['procedimiento'] as String?,
      ubicacion: data['ubicacion'] as String?,
      fotoUrl: data['fotoUrl'] as String?,
      resultadoAviso: switch (data['resultadoAviso']) {
        'registrado' => ResultadoAviso.registrado,
        'ya_registrado' => ResultadoAviso.yaRegistrado,
        _ => null,
      },
      idPerroAviso: (data['idPerroAviso'] as String?)?.trim(),
      notaGuau: (data['notaGuau'] as String?)?.trim(),
      reacciones: [
        if (data['reacciones'] is Map)
          for (final MapEntry(:key, :value) in (data['reacciones'] as Map).entries)
            if (value is Map && emojisReaccion.contains(value['e']))
              Reaccion(
                uid: '$key',
                emoji: value['e'] as String,
                nombre: value['n'] is String ? value['n'] as String : 'Alguien',
                foto: value['f'] is String ? value['f'] as String : null,
              ),
      ],
      numComentarios: data['numComentarios'] is int ? (data['numComentarios'] as int).clamp(0, 1 << 30) : 0,
      ultimoComentarioDe: ultimo is Map && ultimo['nombre'] is String ? ultimo['nombre'] as String : null,
      ultimoComentarioPor: ultimo is Map && ultimo['idUsuario'] is String ? ultimo['idUsuario'] as String : null,
      ultimoComentarioEn: ultimoEn is Timestamp ? ultimoEn.toDate() : null,
    );
  }
}
