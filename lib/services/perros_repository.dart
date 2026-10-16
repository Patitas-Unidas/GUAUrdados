import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/perro.dart';

class PerrosRepository {
  PerrosRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _perros => _firestore.collection('perros');

  Stream<List<Perro>> observarPerros() => _perros.snapshots().map((s) {
    final perros = s.docs.map(Perro.fromFirestore).toList();
    // El orden se realiza en la app para no ocultar documentos antiguos que
    // todavía no tengan el campo `actualizadoEn`.
    perros.sort((a, b) => (b.actualizadoEn?.millisecondsSinceEpoch ?? 0)
        .compareTo(a.actualizadoEn?.millisecondsSinceEpoch ?? 0));
    return perros;
  });
  Stream<Perro?> observarPerro(String id) => _perros.doc(id).snapshots().map((d) => d.exists ? Perro.fromFirestore(d) : null);
  Stream<List<Perro>> observarPerrosSeguidos(String uid) => _perros.where('seguidores', arrayContains: uid).snapshots().map((s) {
    final perros = s.docs.map(Perro.fromFirestore).toList();
    perros.sort((a, b) => (b.actualizadoEn?.millisecondsSinceEpoch ?? 0).compareTo(a.actualizadoEn?.millisecondsSinceEpoch ?? 0));
    return perros;
  });

  Future<void> actualizarSeguimiento({
    required String idPerro,
    required String uid,
    required bool seguir,
  }) => _perros.doc(idPerro).update({
        'seguidores': seguir
            ? FieldValue.arrayUnion([uid])
            : FieldValue.arrayRemove([uid]),
      });
}
