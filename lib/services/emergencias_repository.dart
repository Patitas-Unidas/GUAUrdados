import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guaurdados_oficial/models/emergencia.dart';

/// Guarda las emergencias en la colección `emergencias`.
/// Una Cloud Function (ver functions/index.js) reacciona a cada documento
/// nuevo y envía la notificación push a los seguidores de los perros.
class EmergenciasRepository {
  EmergenciasRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _emergencias => _firestore.collection('emergencias');

  Future<void> crear({
    required Map<String, String> perros,
    required String tipo,
    required String ubicacion,
    required String uid,
    required String nombreUsuario,
  }) =>
      _emergencias.add({
        'idsPerros': perros.keys.toList(),
        'nombresPerros': perros.values.toList(),
        'tipo': tipo,
        'ubicacion': ubicacion,
        'creadoPor': uid,
        'nombreUsuario': nombreUsuario,
        'estado': EstadoEmergencia.enCurso.valor,
        'creadoEn': FieldValue.serverTimestamp(),
      });

  Future<void> cerrar(String id, {required EstadoEmergencia estado, String nota = ''}) =>
      _emergencias.doc(id).update({
        'estado': estado.valor,
        'nota': nota.trim(),
        'cerradaEn': FieldValue.serverTimestamp(),
      });

  Stream<List<Emergencia>> observarRecientes() => _emergencias
      .where('creadoEn', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 7))))
      .snapshots()
      .map((s) => s.docs.map(Emergencia.fromFirestore).toList());

  Stream<List<Emergencia>> observarDeUsuario(String uid) => _emergencias
      .where('creadoPor', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map(Emergencia.fromFirestore).toList()..sort(ordenarEmergencias));
}

int ordenarEmergencias(Emergencia a, Emergencia b) {
  if (a.enCurso != b.enCurso) return a.enCurso ? -1 : 1;
  final fa = a.ultimaNovedad?.millisecondsSinceEpoch ?? 1 << 62;
  final fb = b.ultimaNovedad?.millisecondsSinceEpoch ?? 1 << 62;
  return fb.compareTo(fa);
}
