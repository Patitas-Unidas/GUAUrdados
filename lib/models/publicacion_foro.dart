import 'package:cloud_firestore/cloud_firestore.dart';

/// Publicación visible en el foro general o en el foro de un perro.
///
/// El ID del documento de Firestore es el ID de la publicación. El documento
/// padre del foro usa el ID del perro, así que no hace falta guardar otro ID
/// de foro en cada perro.
class PublicacionForo {
  const PublicacionForo({
    required this.id,
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
  });

  final String id;
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

  factory PublicacionForo.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    final creado = data['creadoEn'];

    return PublicacionForo(
      id: document.id,
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
    );
  }
}
