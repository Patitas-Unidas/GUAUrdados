import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/homepage.dart';
import 'screens/iniciar_sesion.dart';
import 'screens/mantenimiento.dart';
import 'services/notificaciones_service.dart';
import 'services/perfiles_usuario_repository.dart';
import 'services/rutas.dart';
import 'widgets/escala_pantalla.dart';
import 'theme/app_theme.dart';
import 'theme/preferencias.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Preferencias.cargar();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _estado = FirebaseFirestore.instance
      .doc('configuracion/servicio')
      .snapshots(includeMetadataChanges: true);
  bool _confirmada = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _estado,
      builder: (context, snapshot) {
        final documento = snapshot.data;
        final valor = snapshot.hasError ? null : documento?.data()?['habilitada'];
        final delServidor = documento != null && !documento.metadata.isFromCache && !documento.metadata.hasPendingWrites;
        if (valor == false) _confirmada = false;
        if (valor == true && delServidor) _confirmada = true;
        if (_confirmada) return const _AppActiva();

        return ListenableBuilder(
          listenable: Preferencias.tema,
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'GUAUrdados',
            theme: AppTheme.claro,
            darkTheme: AppTheme.oscuro,
            themeMode: Preferencias.tema.value,
            home: valor == false ? const Mantenimiento() : const VerificandoServicio(),
          ),
        );
      },
    );
  }
}

class _AppActiva extends StatefulWidget {
  const _AppActiva();

  @override
  State<_AppActiva> createState() => _AppActivaState();
}

class _AppActivaState extends State<_AppActiva> {
  late final StreamSubscription<User?> _sesion;

  @override
  void initState() {
    super.initState();
    _sesion = FirebaseAuth.instance.authStateChanges().listen((usuario) {
      if (usuario != null) {
        NotificacionesService.inicializar().catchError((_) {});
        usuario.reload().catchError((_) {}).whenComplete(
          () => PerfilesUsuarioRepository().sincronizar(FirebaseAuth.instance.currentUser ?? usuario).catchError((_) {}),
        );
      }
    });
  }

  @override
  void dispose() {
    _sesion.cancel();
    RegistroRutas.instancia.limpiar();
    super.dispose();
  }

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
        navigatorObservers: [RegistroRutas.instancia],
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
              child: EscalaPantalla(child: child!),
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
