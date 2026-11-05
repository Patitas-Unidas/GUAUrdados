import 'dart:async';

import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';

enum TipoAviso { info, exito, error }

void avisar(BuildContext context, String texto, {TipoAviso tipo = TipoAviso.info, IconData? icono, Color? color}) {
  if (estaEnHoja(context)) {
    _AvisoSobreHoja.mostrar(context, _Aviso(texto: texto, tipo: tipo, icono: icono, color: color), Duration(milliseconds: 2800 + texto.length * 30));
    return;
  }
  ScaffoldMessenger.of(context).avisar(texto, tipo: tipo, icono: icono, color: color);
}

class _AvisoSobreHoja extends StatefulWidget {
  const _AvisoSobreHoja({required this.aviso, required this.duracion, required this.alTerminar});
  final Widget aviso;
  final Duration duracion;
  final VoidCallback alTerminar;

  static OverlayEntry? _actual;

  static void mostrar(BuildContext context, Widget aviso, Duration duracion) {
    _actual?.remove();
    late final OverlayEntry entrada;
    entrada = OverlayEntry(
      builder: (_) => _AvisoSobreHoja(
        aviso: aviso,
        duracion: duracion,
        alTerminar: () {
          if (_actual == entrada) _actual = null;
          if (entrada.mounted) entrada.remove();
        },
      ),
    );
    _actual = entrada;
    Overlay.of(context).insert(entrada);
  }

  @override
  State<_AvisoSobreHoja> createState() => _AvisoSobreHojaState();
}

class _AvisoSobreHojaState extends State<_AvisoSobreHoja> with SingleTickerProviderStateMixin {
  late final _salida = AnimationController(vsync: this, duration: const Duration(milliseconds: 220), value: 1);
  Timer? _tiempo;

  @override
  void initState() {
    super.initState();
    _tiempo = Timer(widget.duracion, _cerrar);
  }

  Future<void> _cerrar() async {
    _tiempo?.cancel();
    if (!mounted) return;
    await _salida.reverse();
    widget.alTerminar();
  }

  @override
  void dispose() {
    _tiempo?.cancel();
    _salida.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned(
        top: MediaQuery.paddingOf(context).top + 10,
        left: 16,
        right: 16,
        child: FadeTransition(
          opacity: _salida,
          child: GestureDetector(
            onTap: _cerrar,
            onVerticalDragEnd: (_) => _cerrar(),
            child: Material(type: MaterialType.transparency, child: widget.aviso),
          ),
        ),
      );
}

extension Avisos on ScaffoldMessengerState {
  void avisar(String texto, {TipoAviso tipo = TipoAviso.info, IconData? icono, Color? color}) {
    hideCurrentSnackBar();
    showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      duration: Duration(milliseconds: 2800 + texto.length * 30),
      content: _Aviso(texto: texto, tipo: tipo, icono: icono, color: color),
    ));
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto, required this.tipo, this.icono, this.color});
  final String texto;
  final TipoAviso tipo;
  final IconData? icono;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final tono = color ??
        switch (tipo) {
          TipoAviso.info => c.secundario,
          TipoAviso.exito => c.exito,
          TipoAviso.error => c.emergencia,
        };
    final simbolo = icono ??
        switch (tipo) {
          TipoAviso.info => Iconos.info,
          TipoAviso.exito => Iconos.circleCheck,
          TipoAviso.error => Iconos.circleAlert,
        };
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutBack,
      builder: (context, t, hijo) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 36),
          child: Transform.scale(scale: .9 + .1 * t, child: hijo),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
        decoration: ShapeDecoration(
          color: Color.alphaBlend(tono.withValues(alpha: oscuro ? .24 : .13), c.superficie),
          shape: Formas.squircle(18, lado: BorderSide(color: tono.withValues(alpha: .5), width: 1.2)),
          shadows: const [BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, 6))],
        ),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: ShapeDecoration(color: tono, shape: Formas.squircle(11)),
            child: Center(child: Icono(simbolo, size: 20, color: Colors.white)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(texto, style: TextStyle(color: c.texto, fontSize: 14, fontWeight: FontWeight.w600, height: 1.3)),
          ),
        ]),
      ),
    );
  }
}
