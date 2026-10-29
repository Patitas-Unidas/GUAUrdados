import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/homepage.dart';
import 'screens/iniciar_sesion.dart';
import 'services/notificaciones_service.dart';
import 'services/perfiles_usuario_repository.dart';
import 'theme/app_theme.dart';
import 'theme/preferencias.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Preferencias.cargar();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  FirebaseAuth.instance.authStateChanges().listen((usuario) {
    if (usuario != null) {
      NotificacionesService.inicializar().catchError((_) {});
      usuario.reload().catchError((_) {}).whenComplete(
        () => PerfilesUsuarioRepository().sincronizar(FirebaseAuth.instance.currentUser ?? usuario).catchError((_) {}),
      );
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([Preferencias.tema, Preferencias.escalaTexto]),
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GUAUrdados',
        theme: AppTheme.claro,
        darkTheme: AppTheme.oscuro,
        themeMode: Preferencias.tema.value,
        themeAnimationDuration: const Duration(milliseconds: 350),
        builder: (context, child) {
          final medidas = MediaQuery.of(context);
          final oscuro = Theme.of(context).brightness == Brightness.dark;
          return MediaQuery(
            data: medidas.copyWith(textScaler: TextScaler.linear(medidas.textScaler.scale(1) * Preferencias.escalaTexto.value)),
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: (oscuro ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
                statusBarColor: Colors.transparent,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarDividerColor: Colors.transparent,
                systemNavigationBarIconBrightness: oscuro ? Brightness.light : Brightness.dark,
                systemNavigationBarContrastEnforced: false,
              ),
              child: child!,
            ),
          );
        },
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, sesion) {
            if (sesion.connectionState == ConnectionState.waiting) return const Scaffold();
            return sesion.data == null ? const IniciarSesion() : const Homepage();
          },
        ),
      ),
    );
  }
}
