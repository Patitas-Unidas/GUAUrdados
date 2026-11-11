import 'package:flutter/material.dart';

import '../theme/colores_app.dart';
import '../theme/formas.dart';
import '../theme/tipografia.dart';
import '../widgets/aparicion.dart';
import '../widgets/iconos.dart';
import '../widgets/logo.dart';

class Mantenimiento extends StatelessWidget {
  const Mantenimiento({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.fondoCalido,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: enCascada([
                  const LogoGUAUrdados(alto: 150),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                    decoration: ShapeDecoration(color: c.superficie, shape: Formas.squircle(28)),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: ShapeDecoration(color: c.contenedor, shape: Formas.squircle(20)),
                          child: Center(child: Icono(Iconos.settings, size: 30, color: c.acento)),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Esta app está en mantenimiento',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25, color: c.texto).display,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'GUAUrdados se desarrolló como un proyecto para la feria de software. '
                          'La fase de prueba ya terminó y la app está fuera de servicio.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, height: 1.5, color: c.textoSecundario),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Gracias por probar la app y ser parte de nuestro proyecto.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w600, color: c.texto),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class VerificandoServicio extends StatefulWidget {
  const VerificandoServicio({super.key});

  @override
  State<VerificandoServicio> createState() => _VerificandoServicioState();
}

class _VerificandoServicioState extends State<VerificandoServicio> {
  bool _demora = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _demora = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.fondoCalido,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const LogoGUAUrdados(alto: 150),
                const SizedBox(height: 32),
                SizedBox(
                  height: 72,
                  child: AnimatedOpacity(
                    opacity: _demora ? 1 : 0,
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      children: [
                        SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: c.acento)),
                        const SizedBox(height: 16),
                        Text(
                          'Estamos conectándonos. Revisa tu conexión a internet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, height: 1.4, color: c.textoSecundario),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
