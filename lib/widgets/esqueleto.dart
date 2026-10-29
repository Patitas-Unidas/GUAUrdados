import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';

const _duracionBrillo = 1300;
final _reloj = Stopwatch()..start();

class BloqueEsqueleto extends StatefulWidget {
  const BloqueEsqueleto({super.key, this.ancho, this.alto, this.radio = 8, this.circular = false});

  final double? ancho;
  final double? alto;
  final double radio;
  final bool circular;

  @override
  State<BloqueEsqueleto> createState() => _BloqueEsqueletoState();
}

class _BloqueEsqueletoState extends State<BloqueEsqueleto> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((_) => setState(() {}))..start();

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = (_reloj.elapsedMilliseconds % _duracionBrillo) / _duracionBrillo;
    return SizedBox(
      width: widget.ancho,
      height: widget.alto,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: widget.circular ? const CircleBorder() : Formas.squircle(widget.radio),
          gradient: LinearGradient(
            colors: [c.esqueleto, c.esqueletoBrillo, c.esqueleto],
            stops: const [.3, .5, .7],
            transform: _Deslizar(t),
          ),
        ),
      ),
    );
  }
}

class _Deslizar extends GradientTransform {
  const _Deslizar(this.t);
  final double t;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (2 * t - 1), 0, 0);
}
