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

  Stream<List<Perro>> observarNovedadesSeguidos(String uid) {
    return _perros.where('seguidores', arrayContains: uid).snapshots().map((s) {
      final perros = s.docs.map(Perro.fromFirestore).toList();
      perros.sort((a, b) => (b.actualizadoEn?.millisecondsSinceEpoch ?? 0)
          .compareTo(a.actualizadoEn?.millisecondsSinceEpoch ?? 0));
      return perros;
    });
  }

  Stream<List<Map<String, dynamic>>> observarPublicacionesForoSeguidos(String uid) {
    return observarPerrosSeguidos(uid).asyncExpand((perrosSeguidos) {
      if (perrosSeguidos.isEmpty) return Stream.value(<Map<String, dynamic>>[]);

      final porId = {for (final perro in perrosSeguidos) perro.id: perro};
      final idsPerrosSeguidos = porId.keys.take(30).toList();
      return _firestore
          .collectionGroup('publicaciones')
          .where('idPerro', whereIn: idsPerrosSeguidos)
          .snapshots()
          .map((snapshot) {
            final novedades = snapshot.docs.map((doc) {
              final data = doc.data();
              final idPerro = data['idPerro'] as String? ?? '';
              final perro = porId[idPerro];
              final tipo = data['tipoPublicacion'] as String? ?? 'normal';
              final descripcion = data['descripcion'] as String? ?? '';
              final comentario = descripcion.isNotEmpty
                  ? descripcion
                  : tipo == 'alimentacion'
                      ? 'Registró ${data['cantidadComida'] ?? ''} de ${data['tipoComida'] ?? 'alimento'} para ${perro?.nombre ?? 'el perro'}.'
                      : '';
              return <String, dynamic>{
                'id': doc.id,
                'tipo': 'foro',
                'idPerro': idPerro,
                'nombrePerro': perro?.nombre ?? data['nombrePerro'] ?? 'un perrito',
                'nombreUsuario': data['nombreUsuario'] ?? 'Usuario',
                'idUsuario': data['idUsuario'],
                'tipoPublicacion': tipo,
                'comentario': comentario,
                'fecha': data['creadoEn'],
              };
            }).toList();
            novedades.sort((a, b) {
              final fechaA = a['fecha'] as Timestamp?;
              final fechaB = b['fecha'] as Timestamp?;
              return (fechaB?.millisecondsSinceEpoch ?? 0)
                  .compareTo(fechaA?.millisecondsSinceEpoch ?? 0);
            });
            return novedades;
          });
    });
  }
}
