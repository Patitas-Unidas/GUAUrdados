import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/theme/app_colors.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

class InsigniaGanada extends StatefulWidget {
  const InsigniaGanada({
    super.key,
    required this.nivel,
    required this.imagen,
    required this.titulo,
    required this.descripcion,
    this.fotoSorpresa,
  });

  final int nivel;
  final String imagen;
  final String titulo;
  final String descripcion;
  final String? fotoSorpresa;

  @override
  State<InsigniaGanada> createState() => _InsigniaGanadaState();
}

class _InsigniaGanadaState extends State<InsigniaGanada> with TickerProviderStateMixin {
  late final _entrada = AnimationController(vsync: this, duration: Duration(milliseconds: const [1300, 1700, 2600][widget.nivel]))..forward();
  late final _giro = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat();
  late final _sorpresa = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  bool _mostrarSorpresa = false;

  Color get _tono => const [AppColors.bronceMedalla, AppColors.plataMedalla, AppColors.oroMedalla][widget.nivel];

  Color get _resplandor => const [AppColors.bronceResplandor, AppColors.plataResplandor, AppColors.oroResplandor][widget.nivel];

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();
    if (widget.nivel == 2) Future.delayed(const Duration(milliseconds: 450), HapticFeedback.heavyImpact);
    if (widget.fotoSorpresa != null) {
      _entrada.addStatusListener((estado) {
        if (estado != AnimationStatus.completed || !mounted) return;
        Future.delayed(const Duration(milliseconds: 350), () {
          if (!mounted) return;
          setState(() => _mostrarSorpresa = true);
          HapticFeedback.lightImpact();
          _sorpresa.forward();
        });
      });
    }
  }

  @override
  void dispose() {
    _entrada.dispose();
    _giro.dispose();
    _sorpresa.dispose();
    super.dispose();
  }

  Animation<double> _tramo(AnimationController c, double desde, double hasta, [Curve curva = Curves.easeOutCubic]) =>
      CurvedAnimation(parent: c, curve: Interval(desde, hasta, curve: curva));

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final claro = Theme.of(context).brightness == Brightness.light;
    final luz = claro ? _resplandor : _tono;
    final medalla = _tramo(_entrada, 0, .55, Curves.elasticOut);
    final aura = _tramo(_entrada, .1, .6);
    final brillo = _tramo(_entrada, .45, .8, Curves.easeInOut);
    final festejo = _tramo(_entrada, .2, 1, Curves.linear);
    final textos = _tramo(_entrada, .45, .8);
    final botones = widget.fotoSorpresa == null ? _tramo(_entrada, .7, 1) : _tramo(_sorpresa, .75, 1);
    final lado = const [130.0, 140.0, 150.0][widget.nivel];

    return Dialog(
      backgroundColor: c.fondo,
      surfaceTintColor: Colors.transparent,
      shape: Formas.squircle(28),
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        if (widget.nivel == 2)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: festejo,
                builder: (context, _) => CustomPaint(painter: _Confeti(festejo.value, [AppColors.oroMedalla, c.acento, AppColors.tierra, c.exito])),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              height: lado + 50,
              child: AnimatedBuilder(
                animation: Listenable.merge([_entrada, _giro]),
                builder: (context, _) => Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
                  Opacity(
                    opacity: aura.value,
                    child: Container(
                      width: lado * (1.6 + .3 * widget.nivel),
                      height: lado * (1.6 + .3 * widget.nivel),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [luz.withValues(alpha: claro ? .7 : .45), luz.withValues(alpha: 0)], stops: const [.3, 1]),
                      ),
                    ),
                  ),
                  if (widget.nivel >= 1)
                    Opacity(
                      opacity: aura.value * (widget.nivel == 2 ? .9 : claro ? .8 : .55),
                      child: CustomPaint(
                        size: Size.square(lado * (widget.nivel == 2 ? 2.1 : 1.7)),
                        painter: _Rayos(giro: _giro.value * 2 * math.pi, color: luz, cantidad: widget.nivel == 2 ? 16 : 10),
                      ),
                    ),
                  Transform.rotate(
                    angle: (1 - medalla.value) * -.6,
                    child: Transform.scale(
                      scale: medalla.value,
                      child: SizedBox.square(
                        dimension: lado,
                        child: Stack(fit: StackFit.expand, children: [
                          Image.asset(widget.imagen),
                          if (widget.nivel >= 1)
                            ShaderMask(
                              blendMode: BlendMode.srcATop,
                              shaderCallback: (rect) => LinearGradient(
                                begin: const Alignment(-1, -1),
                                end: const Alignment(1, 1),
                                stops: [brillo.value - .2, brillo.value, brillo.value + .2].map((s) => s.clamp(0.0, 1.0)).toList(),
                                colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: .75), Colors.white.withValues(alpha: 0)],
                              ).createShader(rect),
                              child: Image.asset(widget.imagen),
                            ),
                        ]),
                      ),
                    ),
                  ),
                  if (widget.nivel >= 1)
                    CustomPaint(
                      size: Size.square(lado * 1.5),
                      painter: _Destellos(festejo.value, claro ? luz : Colors.white, widget.nivel == 2 ? 10 : 6),
                    ),
                ]),
              ),
            ),
            FadeTransition(
              opacity: textos,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, .3), end: Offset.zero).animate(textos),
                child: Column(children: [
                  Text(widget.titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800).display),
                  const SizedBox(height: 8),
                  Text(widget.descripcion, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.4, color: c.textoSecundario)),
                ]),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOutCubic,
              child: _mostrarSorpresa ? _Sorpresa(foto: widget.fotoSorpresa!, animacion: _sorpresa) : const SizedBox(width: double.infinity),
            ),
            const SizedBox(height: 18),
            FadeTransition(
              opacity: botones,
              child: IgnorePointer(
                ignoring: widget.fotoSorpresa != null && !_mostrarSorpresa,
                child: Column(children: [
                  Presionable(
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pop(context, widget.fotoSorpresa != null),
                        style: FilledButton.styleFrom(backgroundColor: c.acento, foregroundColor: c.sobreAcento, shape: Formas.squircle(16)),
                        icon: Icono(widget.fotoSorpresa != null ? Iconos.check : Iconos.pawPrint, color: c.sobreAcento, size: 20),
                        label: Text(
                          widget.fotoSorpresa != null ? 'Usar esta foto de perfil' : '¡Genial!',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  if (widget.fotoSorpresa != null)
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Ahora no', style: TextStyle(color: c.textoSecundario, fontWeight: FontWeight.w600)),
                    ),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _Sorpresa extends StatelessWidget {
  const _Sorpresa({required this.foto, required this.animacion});
  final String foto;
  final AnimationController animacion;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final linea = CurvedAnimation(parent: animacion, curve: const Interval(0, .3, curve: Curves.easeOut));
    final foto = CurvedAnimation(parent: animacion, curve: const Interval(.15, .7, curve: Curves.easeOutBack));
    final nitidez = CurvedAnimation(parent: animacion, curve: const Interval(.15, .65, curve: Curves.easeOut));
    final halo = CurvedAnimation(parent: animacion, curve: const Interval(.45, 1, curve: Curves.easeOut));
    final textos = CurvedAnimation(parent: animacion, curve: const Interval(.55, .9, curve: Curves.easeOut));
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: AnimatedBuilder(
        animation: animacion,
        builder: (context, _) => Column(children: [
          Opacity(
            opacity: linea.value,
            child: Row(children: [
              Expanded(child: Divider(color: c.divisor)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text('¡Y hay una sorpresa!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.acento)),
              ),
              Expanded(child: Divider(color: c.divisor)),
            ]),
          ),
          const SizedBox(height: 16),
          Stack(alignment: Alignment.center, children: [
            Opacity(
              opacity: halo.value == 0 ? 0 : (1 - halo.value) * .8,
              child: Container(
                width: 104 + 46 * halo.value,
                height: 104 + 46 * halo.value,
                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.oroMedalla, width: 3)),
              ),
            ),
            Transform.scale(
              scale: .4 + .6 * foto.value,
              child: Opacity(
                opacity: foto.value.clamp(0.0, 1.0),
                child: ImageFiltered(
                  enabled: nitidez.value < 1,
                  imageFilter: ui.ImageFilter.blur(sigmaX: 14 * (1 - nitidez.value), sigmaY: 14 * (1 - nitidez.value)),
                  child: Container(
                    width: 104,
                    height: 104,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.fondoAvatar,
                      border: Border.all(color: AppColors.oroMedalla.withValues(alpha: .8), width: 2.5),
                      boxShadow: [BoxShadow(color: AppColors.oroMedalla.withValues(alpha: .35), blurRadius: 22)],
                    ),
                    child: ClipOval(child: Image.asset('fotos/${this.foto}', fit: BoxFit.cover)),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Opacity(
            opacity: textos.value,
            child: Column(children: [
              const Text('Desbloqueaste una foto de perfil secreta', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Un homenaje a Godzilla, perrito leyenda de la sede.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.35, color: c.textoSecundario),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Rayos extends CustomPainter {
  const _Rayos({required this.giro, required this.color, required this.cantidad});
  final double giro;
  final Color color;
  final int cantidad;

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = size.width / 2;
    final pintura = Paint()
      ..shader = RadialGradient(colors: [color.withValues(alpha: .55), color.withValues(alpha: 0)])
          .createShader(Rect.fromCircle(center: centro, radius: radio));
    final ancho = math.pi / cantidad * .55;
    for (var i = 0; i < cantidad; i++) {
      final angulo = giro + i * 2 * math.pi / cantidad;
      canvas.drawPath(
        Path()
          ..moveTo(centro.dx, centro.dy)
          ..lineTo(centro.dx + radio * math.cos(angulo - ancho), centro.dy + radio * math.sin(angulo - ancho))
          ..lineTo(centro.dx + radio * math.cos(angulo + ancho), centro.dy + radio * math.sin(angulo + ancho))
          ..close(),
        pintura,
      );
    }
  }

  @override
  bool shouldRepaint(_Rayos anterior) => anterior.giro != giro || anterior.color != color;
}

class _Destellos extends CustomPainter {
  const _Destellos(this.t, this.color, this.cantidad);
  final double t;
  final Color color;
  final int cantidad;

  @override
  void paint(Canvas canvas, Size size) {
    final azar = math.Random(7);
    final centro = size.center(Offset.zero);
    for (var i = 0; i < cantidad; i++) {
      final inicio = .25 + azar.nextDouble() * .45;
      final vida = ((t - inicio) / .3).clamp(0.0, 1.0);
      if (vida <= 0 || vida >= 1) continue;
      final angulo = azar.nextDouble() * 2 * math.pi;
      final distancia = size.width * (.3 + azar.nextDouble() * .2);
      final punto = centro + Offset(math.cos(angulo), math.sin(angulo)) * distancia;
      final escala = math.sin(vida * math.pi) * (5 + azar.nextDouble() * 5);
      final pintura = Paint()..color = color.withValues(alpha: math.sin(vida * math.pi));
      canvas.drawPath(
        Path()
          ..moveTo(punto.dx, punto.dy - escala)
          ..quadraticBezierTo(punto.dx, punto.dy, punto.dx + escala, punto.dy)
          ..quadraticBezierTo(punto.dx, punto.dy, punto.dx, punto.dy + escala)
          ..quadraticBezierTo(punto.dx, punto.dy, punto.dx - escala, punto.dy)
          ..quadraticBezierTo(punto.dx, punto.dy, punto.dx, punto.dy - escala),
        pintura,
      );
    }
  }

  @override
  bool shouldRepaint(_Destellos anterior) => anterior.t != t;
}

class _Confeti extends CustomPainter {
  const _Confeti(this.t, this.colores);
  final double t;
  final List<Color> colores;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final azar = math.Random(3);
    final origen = Offset(size.width / 2, size.height * .2);
    for (var i = 0; i < 46; i++) {
      final angulo = -math.pi / 2 + (azar.nextDouble() - .5) * math.pi * 1.3;
      final velocidad = size.height * (.55 + azar.nextDouble() * .55);
      final giro = azar.nextDouble() * 12;
      final color = colores[i % colores.length];
      final x = origen.dx + math.cos(angulo) * velocidad * t;
      final y = origen.dy + math.sin(angulo) * velocidad * t + size.height * 1.1 * t * t;
      final opacidad = (1 - ((t - .7) / .3).clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(giro * t * 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 7, height: 11), const Radius.circular(2)),
        Paint()..color = color.withValues(alpha: opacidad),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Confeti anterior) => anterior.t != t;
}
