import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/services/perfiles_usuario_repository.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';

class GamificacionService {
  static final _firestore = FirebaseFirestore.instance;

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
      if (totalEscaneados >= 3 && !logros.contains('plata')) {
        await _desbloquearLogro(
          uid: uid,
          idLogro: 'plata',
          titulo: '¡Insignia de Plata Desbloqueada!',
          descripcion: '¡Has escaneado a 3 perritos comunitarios distintos! Desbloqueaste una foto de perfil exclusiva.',
          icono: Icons.auto_awesome,
          colorInsignia: const Color(0xff9e9e9e),
          context: context,
          esPlata: true,
        );
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
      if (!logros.contains('bronce')) {
        final perrosSeguidos = await PerrosRepository().observarPerrosSeguidos(uid).first;
        if (perrosSeguidos.length >= 3 && context.mounted) {
          await _desbloquearLogro(
            uid: uid,
            idLogro: 'bronce',
            titulo: '¡Insignia de Bronce Desbloqueada!',
            descripcion: '¡Ya sigues a 3 perritos comunitarios! Estás atento a toda su información.',
            icono: Icons.pets,
            colorInsignia: const Color(0xffcd7f32),
            context: context,
          );
        }
      }

      // 2. Evaluar Oro: Racha de 7 días en el foro/alimentación
      if (!logros.contains('oro')) {
        final resumen = await ForoRepository().observarResumenUsuario(uid).first;
        final int racha = resumen.rachaDias;
        if (racha >= 7 && context.mounted) {
          await _desbloquearLogro(
            uid: uid,
            idLogro: 'oro',
            titulo: '¡Guardián Dorado Desbloqueado!',
            descripcion: '¡Alcanzaste una racha activa de 7 días consecutivos cuidando la comunidad!',
            icono: Icons.military_tech,
            colorInsignia: const Color(0xfff5a623),
            context: context,
          );
        }
      }
    } catch (e) {
      debugPrint("Error evaluando logros: $e");
    }
  }

  static Future<void> _desbloquearLogro({
    required String uid,
    required String idLogro,
    required String titulo,
    required String descripcion,
    required IconData icono,
    required Color colorInsignia,
    required BuildContext context,
    bool esPlata = false,
  }) async {
    await _firestore.collection('usuarios').doc(uid).set({
      'logros': FieldValue.arrayUnion([idLogro]),
    }, SetOptions(merge: true));

    if (!context.mounted) return;
    final c = context.colores;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: Formas.squircle(20),
        backgroundColor: c.fondo,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            if (esPlata)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorInsignia, width: 3),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'fotos/foto_godzilla.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(icono, size: 40, color: colorInsignia),
                  ),
                ),
              )
            else
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colorInsignia.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, size: 36, color: colorInsignia),
              ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold).display,
            ),
            const SizedBox(height: 8),
            Text(
              descripcion,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: c.textoSecundario),
            ),
            const SizedBox(height: 20),
            if (esPlata) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.acento,
                    shape: Formas.squircle(12),
                    elevation: 0,
                  ),
                  icon: Icon(Icons.check, color: c.sobreAcento),
                  label: Text("Usar foto de perfil exclusiva", style: TextStyle(color: c.sobreAcento)),
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    await _asignarAvatarGodzilla(uid, context);
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text("Conservar foto actual", style: TextStyle(color: c.textoSecundario)),
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.acento,
                    shape: Formas.squircle(12),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text("¡Genial!", style: TextStyle(color: c.sobreAcento)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Future<void> _asignarAvatarGodzilla(String uid, BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Asignamos la ruta del asset local como photoURL
        await user.updatePhotoURL('foto_godzilla.png');
        await user.reload();
        await PerfilesUsuarioRepository().sincronizar(FirebaseAuth.instance.currentUser!);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Foto de perfil actualizada con éxito!')),
        );
      }
    } catch (e) {
      debugPrint("Error actualizando avatar exclusivo: $e");
    }
  }

  static Stream<DocumentSnapshot> streamUsuario(String uid) {
    return _firestore.collection('usuarios').doc(uid).snapshots();
  }
}