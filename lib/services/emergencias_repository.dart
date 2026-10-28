import 'package:cloud_firestore/cloud_firestore.dart';

/// Guarda las emergencias en la colección `emergencias`.
/// Una Cloud Function (ver functions/index.js) reacciona a cada documento
/// nuevo y envía la notificación push a los seguidores del perro.
class EmergenciasRepository {
  EmergenciasRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  Future<void> crear({
    required String? idPerro,
    required String? nombrePerro,
    required String tipo,
    required String ubicacion,
    required String uid,
  }) =>
      _firestore.collection('emergencias').add({
        'idPerro': idPerro,
        'nombrePerro': nombrePerro,
        'tipo': tipo,
        'ubicacion': ubicacion,
        'creadoPor': uid,
        'creadoEn': FieldValue.serverTimestamp(),
      });
}
