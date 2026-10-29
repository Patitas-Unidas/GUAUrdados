import 'package:flutter/material.dart';

bool _oscuro(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

class LogoGUAUrdados extends StatelessWidget {
  const LogoGUAUrdados({super.key, required this.alto});
  final double alto;

  @override
  Widget build(BuildContext context) => Image.asset(
    _oscuro(context) ? 'fotos/GUAUrdados_oscuro.png' : 'fotos/GUAUrdados.png',
    height: alto,
    filterQuality: FilterQuality.medium,
    semanticLabel: 'GUAUrdados',
  );
}

class NombreGUAUrdados extends StatelessWidget {
  const NombreGUAUrdados({super.key, this.ancho, this.alto});
  final double? ancho;
  final double? alto;

  @override
  Widget build(BuildContext context) => Image.asset(
    _oscuro(context) ? 'fotos/Letras_oscuro.png' : 'fotos/Letras.png',
    width: ancho,
    height: alto,
    filterQuality: FilterQuality.medium,
    semanticLabel: 'GUAUrdados',
  );
}
