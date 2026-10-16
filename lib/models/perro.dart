import 'package:cloud_firestore/cloud_firestore.dart';

/// Representa un documento de la colección `perros` en Cloud Firestore.
class Perro {
  const Perro({
    required this.id, required this.nombre, required this.estado,
    required this.raza, required this.edad, required this.peso,
    required this.ultimaComida, required this.tamano, required this.vacunacion,
    required this.descripcion, required this.caracter, required this.imagenAsset,
    required this.fotoUrl,
    this.actualizadoEn, this.seguidores = const [], this.carnetUrls = const [],
  });
  final String id, nombre, estado, raza, edad, peso, ultimaComida, tamano;
  final String vacunacion, descripcion, caracter, imagenAsset, fotoUrl;
  final Timestamp? actualizadoEn;
  final List<String> seguidores;
  final List<String> carnetUrls;

  bool esSeguidoPor(String? uid) => uid != null && seguidores.contains(uid);

  factory Perro.fromFirestore(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    // Firestore puede contener números (por ejemplo, edad: 2) o texto.
    // Ambos se muestran como texto en la interfaz sin romper la lectura.
    String text(List<String> keys, [String fallback = 'Sin información']) {
      for (final key in keys) {
        final value = data[key];
        if (value != null) return value.toString();
      }
      return fallback;
    }

    final imagen = text(
      ['imagenAsset', 'imagenAssets', 'imagen_asset', 'imagen_assets'],
      '',
    );
    final fotoUrl = text(['fotoUrl', 'foto_url'], '');
    final url = fotoUrl.isNotEmpty
        ? fotoUrl
        : imagen.startsWith('http')
            ? imagen
            : '';
    final carnetUrls = <String>[];
    for (final key in ['carnetUrls', 'carnet_urls', 'carnetUrl', 'carnet_url', 'carnet_asset', 'carnet_assets']) {
      final value = data[key];
      final values = value is List ? value : value == null ? const [] : [value];
      for (final item in values) {
        final carnet = item.toString();
        if (carnet.isNotEmpty) {
          carnetUrls.add(carnet.startsWith('http') ? carnet : 'https://guaurdados.web.app/carnets/$carnet');
        }
      }
    }
    return Perro(
      id: document.id,
      nombre: text(['nombre'], 'Sin nombre'),
      estado: text(['estado'], 'Sin estado'),
      raza: text(['raza']),
      edad: text(['edad']),
      peso: text(['peso']),
      ultimaComida: text(['ultimaComida', 'ultima_comida']),
      tamano: text(['tamano']),
      vacunacion: text(['vacunacion']),
      descripcion: text(['descripcion'], ''),
      caracter: text(['caracter']),
      imagenAsset: url.isEmpty ? imagen : '',
      fotoUrl: url,
      actualizadoEn: (data['actualizadoEn'] ?? data['actualizado_en']) as Timestamp?,
      seguidores: List<String>.from(data['seguidores'] as List? ?? const []),
      carnetUrls: carnetUrls.toSet().toList(),
    );
  }
}
