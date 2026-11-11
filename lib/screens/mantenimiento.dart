import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/colores_app.dart';
import '../widgets/iconos.dart';
import '../widgets/logo.dart';

class Mantenimiento extends StatelessWidget {
  const Mantenimiento({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;
    final coloresFondo = ColoresApp.claro;
    return Scaffold(
      backgroundColor: AppColors.cremaRosada,
      appBar: AppBar(
        title: const NombreGUAUrdados(alto: 28),
        centerTitle: true,
        backgroundColor: colores.surface,
        foregroundColor: colores.onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.crema,
                    child: Icono(
                      Iconos.settings,
                      size: 38,
                      color: coloresFondo.acento,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Esta app está en mantenimiento',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: coloresFondo.texto,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'GUAUrdados se desarrolló como un proyecto para la feria de software. '
                    'La fase de prueba ya terminó y la app está fuera de servicio.',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodyLarge?.copyWith(
                      color: coloresFondo.texto,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gracias por probar la app y ser parte de nuestro proyecto.',
                    textAlign: TextAlign.center,
                    style: tema.textTheme.bodyMedium?.copyWith(
                      color: coloresFondo.texto,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
