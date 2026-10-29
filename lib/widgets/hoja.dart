import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';

Future<T?> mostrarHoja<T>(BuildContext context, {required WidgetBuilder builder}) =>
    Navigator.of(context).push<T>(_RutaHoja<T>(builder));

const _curvaEntrada = Cubic(.2, .9, .3, 1.06);
const _margenRebote = 48.0;

class _RutaHoja<T> extends PopupRoute<T> {
  _RutaHoja(this.builder);
  final WidgetBuilder builder;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Cerrar';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 450);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 260);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) =>
      _HojaArrastrable(child: builder(context));

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    final subida = animation.drive(
      Tween(begin: const Offset(0, 1), end: Offset.zero).chain(CurveTween(curve: _curvaEntrada)),
    );
    return Stack(children: [
      Positioned.fill(
        child: IgnorePointer(
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, _) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6 * animation.value, sigmaY: 6 * animation.value),
              child: ColoredBox(color: Colors.black.withValues(alpha: .25 * animation.value)),
            ),
          ),
        ),
      ),
      Align(alignment: Alignment.bottomCenter, child: SlideTransition(position: subida, child: child)),
    ]);
  }
}

class _HojaArrastrable extends StatefulWidget {
  const _HojaArrastrable({required this.child});
  final Widget child;

  @override
  State<_HojaArrastrable> createState() => _HojaArrastrableState();
}

class _HojaArrastrableState extends State<_HojaArrastrable> with SingleTickerProviderStateMixin {
  late final AnimationController _bajada = AnimationController.unbounded(vsync: this);

  @override
  void dispose() {
    _bajada.dispose();
    super.dispose();
  }

  void _arrastrar(DragUpdateDetails detalles) {
    _bajada.stop();
    final siguiente = _bajada.value + detalles.delta.dy;
    _bajada.value = siguiente < 0 ? _bajada.value + detalles.delta.dy / 4 : siguiente;
  }

  void _soltar(DragEndDetails detalles) {
    final velocidad = detalles.velocity.pixelsPerSecond.dy;
    if (_bajada.value > 120 || velocidad > 800) {
      Navigator.of(context).maybePop();
      return;
    }
    _bajada.animateWith(SpringSimulation(
      SpringDescription.withDampingRatio(mass: 1, stiffness: 500, ratio: .8),
      _bajada.value,
      0,
      velocidad,
    ));
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: AnimatedBuilder(
      animation: _bajada,
      builder: (context, hoja) => Transform.translate(offset: Offset(0, _bajada.value + _margenRebote), child: hoja),
      child: GestureDetector(
        onVerticalDragUpdate: _arrastrar,
        onVerticalDragEnd: _soltar,
        child: Material(
          type: MaterialType.transparency,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            widget.child,
            SizedBox(height: _margenRebote, width: double.infinity, child: ColoredBox(color: context.colores.fondo)),
          ]),
        ),
      ),
    ),
  );
}
