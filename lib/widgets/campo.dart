import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';

final correoValido = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

InputDecoration decoracionCampo(
  BuildContext context, {
  String? pista,
  String? etiqueta,
  Widget? prefijo,
  double radio = 24,
  bool borde = false,
  EdgeInsetsGeometry relleno = const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
}) {
  final c = context.colores;
  return InputDecoration(
    hintText: pista,
    labelText: etiqueta,
    alignLabelWithHint: etiqueta != null,
    hintStyle: TextStyle(color: c.textoTenue),
    prefixIcon: prefijo,
    filled: true,
    fillColor: c.superficie,
    contentPadding: relleno,
    border: BordeSquircle(radio: radio),
    enabledBorder: BordeSquircle(radio: radio, borderSide: borde ? BorderSide(color: c.divisor) : BorderSide.none),
    disabledBorder: BordeSquircle(radio: radio, borderSide: borde ? BorderSide(color: c.divisor) : BorderSide.none),
    focusedBorder: BordeSquircle(radio: radio, borderSide: BorderSide(color: c.acento, width: 1.5)),
    errorBorder: BordeSquircle(radio: radio, borderSide: BorderSide(color: c.emergencia, width: 1.2)),
    focusedErrorBorder: BordeSquircle(radio: radio, borderSide: BorderSide(color: c.emergencia, width: 1.8)),
    errorStyle: TextStyle(color: c.emergenciaTexto, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.3),
    errorMaxLines: 3,
  );
}
