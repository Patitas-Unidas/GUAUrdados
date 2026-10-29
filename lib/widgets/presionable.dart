import 'package:flutter/material.dart';

class Presionable extends StatefulWidget {
  const Presionable({super.key, required this.child, this.escala = .96});
  final Widget child;
  final double escala;

  @override
  State<Presionable> createState() => _PresionableState();
}

class _PresionableState extends State<Presionable> {
  bool _presionado = false;

  void _cambiar(bool valor) {
    if (_presionado != valor) setState(() => _presionado = valor);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _cambiar(true),
    onPointerUp: (_) => _cambiar(false),
    onPointerCancel: (_) => _cambiar(false),
    child: AnimatedScale(
      scale: _presionado ? widget.escala : 1,
      duration: Duration(milliseconds: _presionado ? 110 : 380),
      curve: _presionado ? Curves.easeOut : Curves.easeOutBack,
      child: widget.child,
    ),
  );
}
