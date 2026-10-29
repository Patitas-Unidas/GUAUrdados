import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';

import 'colores_app.dart';
import 'formas.dart';
import 'tipografia.dart';

class _TransicionSuave extends PageTransitionsBuilder {
  const _TransicionSuave();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 380);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final aparece = animation.drive(CurveTween(curve: const Interval(0, .7, curve: Curves.easeOut)));
    final sube = animation.drive(Tween(begin: const Offset(0, .04), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic)));
    final seAleja = secondaryAnimation.drive(Tween(begin: 1.0, end: .96).chain(CurveTween(curve: Curves.easeOutCubic)));
    return ScaleTransition(
      scale: seAleja,
      child: FadeTransition(opacity: aparece, child: SlideTransition(position: sube, child: child)),
    );
  }
}

class AppTheme {
  static ThemeData get claro => _construir(ColoresApp.claro, Brightness.light);
  static ThemeData get oscuro => _construir(ColoresApp.oscuro, Brightness.dark);

  static ThemeData _construir(ColoresApp c, Brightness brillo) {
    final esquema = ColorScheme(
      brightness: brillo,
      primary: c.acento,
      onPrimary: c.sobreAcento,
      primaryContainer: c.contenedor,
      onPrimaryContainer: c.texto,
      secondary: c.secundario,
      onSecondary: c.sobreAcento,
      secondaryContainer: c.superficie,
      onSecondaryContainer: c.textoTenue,
      tertiary: c.medico,
      onTertiary: c.sobreAcento,
      error: c.emergencia,
      onError: c.sobreAcento,
      surface: c.fondo,
      onSurface: c.texto,
      onSurfaceVariant: c.textoSecundario,
      surfaceContainerLowest: c.superficie,
      surfaceContainerLow: c.superficie,
      surfaceContainer: c.superficie,
      surfaceContainerHigh: c.superficie,
      surfaceContainerHighest: c.contenedor,
      outline: c.textoTenue,
      outlineVariant: c.divisor,
      surfaceTint: Colors.transparent,
      inverseSurface: c.texto,
      onInverseSurface: c.fondo,
      inversePrimary: c.tonal,
    );

    final base = ThemeData(
      brightness: brillo,
      colorScheme: esquema,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: c.fondo,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.fondo,
        foregroundColor: c.texto,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(color: c.superficie, surfaceTintColor: Colors.transparent, shape: Formas.squircle(14)),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.fondo,
        surfaceTintColor: Colors.transparent,
        shape: Formas.squircleArriba(25),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(shape: WidgetStatePropertyAll(Formas.squircle(20)))),
      filledButtonTheme: FilledButtonThemeData(style: ButtonStyle(shape: WidgetStatePropertyAll(Formas.squircle(20)))),
      textButtonTheme: TextButtonThemeData(style: ButtonStyle(shape: WidgetStatePropertyAll(Formas.squircle(20)))),
      outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(shape: WidgetStatePropertyAll(Formas.squircle(20)))),
      navigationBarTheme: NavigationBarThemeData(indicatorShape: Formas.squircle(16)),
      dialogTheme: DialogThemeData(shape: Formas.squircle(28)),
      popupMenuTheme: PopupMenuThemeData(shape: Formas.squircle(12)),
      checkboxTheme: CheckboxThemeData(shape: Formas.squircle(4)),
      actionIconTheme: ActionIconThemeData(backButtonIconBuilder: (_) => const Icono(Iconos.chevronLeft)),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: _TransicionSuave(),
        TargetPlatform.iOS: _TransicionSuave(),
      }),
      tooltipTheme: TooltipThemeData(decoration: Formas.fondo(c.texto, 8)),
      dividerTheme: DividerThemeData(color: c.divisor),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.acento),
    );

    final t = base.textTheme;
    TextStyle? junto(TextStyle? s) => s?.copyWith(letterSpacing: -.3);
    TextStyle? titulo(TextStyle? s) => s?.copyWith(letterSpacing: -.3).display;
    return base.copyWith(
      textTheme: t.copyWith(
        bodySmall: junto(t.bodySmall),
        bodyMedium: junto(t.bodyMedium),
        bodyLarge: junto(t.bodyLarge),
        labelSmall: junto(t.labelSmall),
        labelMedium: junto(t.labelMedium),
        labelLarge: junto(t.labelLarge),
        displaySmall: titulo(t.displaySmall),
        displayMedium: titulo(t.displayMedium),
        displayLarge: titulo(t.displayLarge),
        headlineSmall: titulo(t.headlineSmall),
        headlineMedium: titulo(t.headlineMedium),
        headlineLarge: titulo(t.headlineLarge),
        titleLarge: titulo(t.titleLarge),
      ),
    );
  }
}
