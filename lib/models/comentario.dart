import 'package:cloud_firestore/cloud_firestore.dart';

class Comentario {
  const Comentario({
    required this.id,
    required this.idUsuario,
    required this.nombreUsuario,
    required this.texto,
    required this.creadoEn,
    this.fotoUsuario,
  });

  final String id;
  final String idUsuario;
  final String nombreUsuario;
  final String texto;
  final DateTime? creadoEn;
  final String? fotoUsuario;

  factory Comentario.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> documento) {
    final datos = documento.data();
    final creado = datos['creadoEn'];
    return Comentario(
      id: documento.id,
      idUsuario: datos['idUsuario'] as String? ?? '',
      nombreUsuario: datos['nombreUsuario'] as String? ?? 'Usuario',
      texto: datos['texto'] as String? ?? '',
      creadoEn: creado is Timestamp ? creado.toDate() : null,
      fotoUsuario: datos['fotoUsuario'] as String?,
    );
  }
}
