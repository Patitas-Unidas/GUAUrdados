import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/services/perfiles_usuario_repository.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:guaurdados_oficial/widgets/insignia_ganada.dart';

class Insignia {
  const Insignia({required this.id, required this.nombre, required this.meta, required this.objetivo, required this.imagen, required this.logro});
  final String id;
  final String nombre;
  final String meta;
  final int objetivo;
  final String imagen;
  final String logro;

  String get titulo => '¡Ganaste la insignia de $nombre!';
}

class GamificacionService {
  static final _firestore = FirebaseFirestore.instance;

  static const fotoExclusiva = 'foto_godzilla.png';

  static const bronce = Insignia(
    id: 'bronce',
    nombre: 'Bronce',
    meta: 'Sigue a 3 perritos',
    objetivo: 3,
    imagen: 'fotos/medalla_bronce.png',
    logro: 'Ya sigues a 3 perritos. Te enterarás de todo lo que les pase.',
  );
  static const plata = Insignia(
    id: 'plata',
    nombre: 'Plata',
    meta: 'Escanea 3 perritos',
    objetivo: 3,
    imagen: 'fotos/medalla_plata.png',
    logro: 'Escaneaste a 3 perritos distintos con la cámara. ¡Ya los reconoces a todos!',
  );
  static const oro = Insignia(
    id: 'oro',
    nombre: 'Oro',
    meta: '7 días de racha',
    objetivo: 7,
    imagen: 'fotos/medalla_oro.png',
    logro: 'Llevas 7 días seguidos ayudando a los perritos. ¡Eres un GUAUrdián de verdad!',
  );
  static const insignias = [bronce, plata, oro];

  /// Registra el escaneo de un perro y evalúa la medalla de plata (3 perros escaneados)
  static Future<void> registrarEscaneo(String idPerro, BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || idPerro.trim().isEmpty) return;

    final docUsuario = _firestore.collection('usuarios').doc(uid);

    try {
      final antes = await docUsuario.get();
      final List<dynamic> previos = antes.data()?['perros_escaneados'] ?? [];
      final List<dynamic> logros = antes.data()?['logros'] ?? [];

      if (previos.contains(idPerro)) return;

      // Guarda el ID del perro escaneado sin duplicados
      await docUsuario.set({
        'perros_escaneados': FieldValue.arrayUnion([idPerro]),
      }, SetOptions(merge: true));

      final int totalEscaneados = previos.length + 1;

      // Medalla de plata: 3 perros distintos escaneados
      if (totalEscaneados >= plata.objetivo && !logros.contains(plata.id) && context.mounted) {
        await _desbloquearLogro(uid: uid, insignia: plata, context: context);
      }
    } catch (e) {
      debugPrint("Error al registrar escaneo: $e");
    }
  }

  /// Evalúa la medalla de bronce (3 perros seguidos) y oro (racha de 7 días)
  static Future<void> evaluarSeguimientoYRacha(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final docUsuario = await _firestore.collection('usuarios').doc(uid).get();
      final List<dynamic> logros = docUsuario.data()?['logros'] ?? [];

      // 1. Evaluar Bronce: Seguir a 3 perritos
      if (!logros.contains(bronce.id)) {
        final perrosSeguidos = await PerrosRepository().observarPerrosSeguidos(uid).first;
        if (perrosSeguidos.length >= bronce.objetivo && context.mounted) {
          await _desbloquearLogro(uid: uid, insignia: bronce, context: context);
        }
      }

      // 2. Evaluar Oro: Racha de 7 días en el foro/alimentación
      if (!logros.contains(oro.id)) {
        final resumen = await ForoRepository().observarResumenUsuario(uid).first;
        if (resumen.rachaDias >= oro.objetivo && context.mounted) {
          await _desbloquearLogro(uid: uid, insignia: oro, context: context);
        }
      }
    } catch (e) {
      debugPrint("Error evaluando logros: $e");
    }
  }

  static Future<void> _desbloquearLogro({required String uid, required Insignia insignia, required BuildContext context}) async {
    await _firestore.collection('usuarios').doc(uid).set({
      'logros': FieldValue.arrayUnion([insignia.id]),
    }, SetOptions(merge: true));

    if (!context.mounted) return;
    final usarFoto = await _mostrarInsignia(context, insignia);
    if (usarFoto == true && context.mounted) await _asignarAvatarExclusivo(context);
  }

  static Future<bool?> _mostrarInsignia(BuildContext context, Insignia insignia) => showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => InsigniaGanada(
          nivel: insignias.indexOf(insignia),
          imagen: insignia.imagen,
          titulo: insignia.titulo,
          descripcion: insignia.logro,
          fotoSorpresa: insignia == plata ? fotoExclusiva : null,
        ),
      );

  static Future<void> _asignarAvatarExclusivo(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Asignamos la ruta del asset local como photoURL
        await user.updatePhotoURL(fotoExclusiva);
        await user.reload();
        await PerfilesUsuarioRepository().sincronizar(FirebaseAuth.instance.currentUser!);
      }
      messenger.avisar('¡Listo! Ya tienes tu foto de perfil secreta. Puedes cambiarla cuando quieras desde tu perfil.', tipo: TipoAviso.exito);
    } catch (e) {
      debugPrint("Error actualizando avatar exclusivo: $e");
      messenger.avisar('No se pudo cambiar la foto. Inténtalo de nuevo desde tu perfil.', tipo: TipoAviso.error);
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> streamUsuario(String uid) {
    return _firestore.collection('usuarios').doc(uid).snapshots();
  }
}
