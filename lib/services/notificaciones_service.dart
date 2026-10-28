import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Registra el token FCM del dispositivo en `usuarios/{uid}.tokens`
/// para que la Cloud Function pueda enviarle notificaciones.
class NotificacionesService {
  static bool _escuchandoRefresh = false;

  /// Llamar después de iniciar sesión.
  static Future<void> inicializar() async {
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(); // Necesario en Android 13+
    final token = await messaging.getToken();
    if (token != null) await _guardar(token);

    if (!_escuchandoRefresh) {
      _escuchandoRefresh = true;
      messaging.onTokenRefresh.listen(_guardar);
    }
    // Emergencias de perros "no identificados" llegan por este tema.
    await messaging.subscribeToTopic('emergencias');
  }

  /// Llamar justo antes de cerrar sesión, para no seguir recibiendo
  /// notificaciones de la cuenta anterior en este dispositivo.
  static Future<void> desregistrar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final token = await FirebaseMessaging.instance.getToken();
    if (uid != null && token != null) {
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set(
        {'tokens': FieldValue.arrayRemove([token])},
        SetOptions(merge: true),
      );
    }
    await FirebaseMessaging.instance.unsubscribeFromTopic('emergencias');
  }

  static Future<void> _guardar(String token) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('usuarios').doc(uid).set(
      {'tokens': FieldValue.arrayUnion([token])},
      SetOptions(merge: true),
    );
  }
}
