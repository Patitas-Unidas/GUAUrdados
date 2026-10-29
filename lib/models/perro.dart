import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/painting.dart' show Alignment;

/// Representa un documento de la colección `perros` en Cloud Firestore.
class Perro {
  const Perro({
    required this.id, required this.nombre, required this.estado,
    required this.raza, required this.edad, required this.peso,
    required this.ultimaComida, required this.tamano, required this.vacunacion,
    required this.descripcion, required this.caracter, required this.imagenAsset,
    required this.fotoUrl,
    this.actualizadoEn, this.seguidores = const [], this.carnetUrls = const [],
    this.esterilizado, this.ultimaComidaEn, this.ultimaVacunaEn,
    this.ultimaDesparasitacionEn, this.condiciones = const [],
    this.restricciones = const [], this.fotoCentroX, this.fotoCentroY,
  });
  final String id, nombre, estado, raza, edad, peso, ultimaComida, tamano;
  final String vacunacion, descripcion, caracter, imagenAsset, fotoUrl;
  final Timestamp? actualizadoEn;
  final List<String> seguidores;
  final List<String> carnetUrls;

  final bool? esterilizado;
  final DateTime? ultimaComidaEn, ultimaVacunaEn, ultimaDesparasitacionEn;

  final List<String> condiciones;

  final List<String> restricciones;

  final double? fotoCentroX, fotoCentroY;

  Alignment get encuadre => fotoCentroX == null || fotoCentroY == null
      ? const Alignment(0, -.2)
      : Alignment(fotoCentroX! * 2 - 1, fotoCentroY! * 2 - 1);

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
        // Firestore guarda la URL de descarga completa de Firebase Storage.
        final uri = Uri.tryParse(carnet);
        if (uri != null && uri.hasAuthority &&
            (uri.scheme == 'https' || uri.scheme == 'http')) {
          carnetUrls.add(carnet);
        }
      }
    }
    DateTime? fechaOpcional(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value is Timestamp) return value.toDate();
        if (value is String) {
          final f = DateTime.tryParse(value.trim());
          if (f != null) return f;
        }
      }
      return null;
    }

    bool? siNo(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value is bool) return value;
        if (value is String && value.trim().isNotEmpty) {
          final v = value.trim().toLowerCase();
          return !(v == 'no' || v.startsWith('no ') || v == 'false');
        }
      }
      return null;
    }

    List<String> lista(List<String> keys) {
      for (final key in keys) {
        final value = data[key];
        if (value is List) return value.map((v) => v.toString().trim()).where((v) => v.isNotEmpty).toList();
        if (value is String && value.trim().isNotEmpty) return [value.trim()];
      }
      return const [];
    }

    double? centro(int i) {
      var valor = data['fotoCentro'];
      if (valor is String) valor = valor.split(',');
      final crudo = valor is Map ? valor[i == 0 ? 'x' : 'y'] : valor is List && valor.length > i ? valor[i] : null;
      final numero = crudo is num ? crudo.toDouble() : double.tryParse('$crudo'.trim());
      return numero?.clamp(0.0, 1.0);
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
      esterilizado: siNo(['esterilizado', 'esterilizada', 'castrado', 'castrada']),
      ultimaComidaEn: fechaOpcional(['ultimaComidaEn', 'ultima_comida_en']),
      ultimaVacunaEn: fechaOpcional(['ultimaVacunaEn', 'ultima_vacuna_en']),
      ultimaDesparasitacionEn: fechaOpcional(['ultimaDesparasitacionEn', 'ultima_desparasitacion_en']),
      condiciones: lista(['condiciones', 'condicionesMedicas', 'condiciones_medicas']),
      restricciones: lista(['restricciones', 'restriccionesAlimentarias', 'restricciones_alimentarias', 'alergias']),
      fotoCentroX: centro(0),
      fotoCentroY: centro(1),
    );
  }
}
