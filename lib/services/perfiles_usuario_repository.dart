import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilPublicoUsuario {
  const PerfilPublicoUsuario({required this.uid, required this.nombre, this.fotoUrl});

  final String uid;
  final String nombre;
  final String? fotoUrl;

  factory PerfilPublicoUsuario.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return PerfilPublicoUsuario(
      uid: doc.id,
      nombre: data['nombre'] as String? ?? 'Usuario',
      fotoUrl: data['fotoUrl'] as String?,
    );
  }
}

class PerfilesUsuarioRepository {
  PerfilesUsuarioRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  CollectionReference<Map<String, dynamic>> get _perfiles => _firestore.collection('perfiles_publicos');

  Future<void> sincronizar(User usuario) async {
    final correo = usuario.email?.split('@').first.trim() ?? '';
    final nombre = usuario.displayName?.trim().isNotEmpty == true
        ? usuario.displayName!.trim()
        : correo.isNotEmpty
            ? correo
            : 'Usuario';
    await _perfiles.doc(usuario.uid).set({
      'nombre': nombre,
      'usuario': correo.isEmpty ? nombre : correo,
      'fotoUrl': usuario.photoURL ?? '',
      'actualizadoEn': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, PerfilPublicoUsuario>> observar(List<String> uids) {
    final ids = uids.toSet().take(30).toList();
    if (ids.isEmpty) return Stream.value(const <String, PerfilPublicoUsuario>{});
    return _perfiles.where(FieldPath.documentId, whereIn: ids).snapshots().map(
      (snapshot) => {for (final doc in snapshot.docs) doc.id: PerfilPublicoUsuario.fromFirestore(doc)},
    );
  }
}
