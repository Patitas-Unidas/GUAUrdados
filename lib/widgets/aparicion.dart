import 'package:flutter/material.dart';

class Aparicion extends StatefulWidget {
  const Aparicion({super.key, required this.child, this.indice = 0});
  final Widget child;
  final int indice;

  @override
  State<Aparicion> createState() => _AparicionState();
}

const _maxEscalonados = 8;

List<Widget> enCascada(List<Widget> hijos) => [
  for (var i = 0; i < hijos.length; i++) Aparicion(indice: i, child: hijos[i]),
];

class _AparicionState extends State<Aparicion> with SingleTickerProviderStateMixin {
  late final AnimationController _entrada = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  late final Animation<double> _curva = CurvedAnimation(parent: _entrada, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    final retraso = widget.indice < _maxEscalonados ? widget.indice * 55 : 0;
    Future.delayed(Duration(milliseconds: retraso), () {
      if (mounted) _entrada.forward();
    });
  }

  @override
  void dispose() {
    _entrada.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curva,
    child: SlideTransition(
      position: Tween(begin: const Offset(0, .12), end: Offset.zero).animate(_curva),
      child: widget.child,
    ),
  );
}
