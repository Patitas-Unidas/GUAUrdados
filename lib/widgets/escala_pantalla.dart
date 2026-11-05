import 'package:flutter/material.dart';

class EscalaPantalla extends StatelessWidget {
  const EscalaPantalla({super.key, required this.child});
  final Widget child;

  static const _anchoBase = 412.0;
  static const _altoBase = 860.0;

  @override
  Widget build(BuildContext context) {
    final medidas = MediaQuery.of(context);
    final tamano = medidas.size;
    if (tamano.isEmpty) return child;
    final escala = (tamano.width / _anchoBase < tamano.height / _altoBase ? tamano.width / _anchoBase : tamano.height / _altoBase).clamp(.9, 1.8);
    if ((escala - 1).abs() < .04) return child;
    final logico = tamano / escala;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: FittedBox(
        fit: BoxFit.fill,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: logico.width,
          height: logico.height,
          child: MediaQuery(
            data: medidas.copyWith(
              size: logico,
              devicePixelRatio: medidas.devicePixelRatio * escala,
              padding: medidas.padding / escala,
              viewPadding: medidas.viewPadding / escala,
              viewInsets: medidas.viewInsets / escala,
              systemGestureInsets: medidas.systemGestureInsets / escala,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
