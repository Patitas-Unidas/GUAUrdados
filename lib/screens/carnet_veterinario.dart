import 'package:flutter/material.dart';
import '../widgets/imagen_remota.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/theme/app_colors.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';

class CarnetVeterinario extends StatefulWidget {
  const CarnetVeterinario({super.key, required this.nombrePerro, required this.imagenes});
  final String nombrePerro;
  final List<String> imagenes;

  @override
  State<CarnetVeterinario> createState() => _CarnetVeterinarioState();
}

class _CarnetVeterinarioState extends State<CarnetVeterinario> {
  var _paginaActual = 0;
  var _ampliado = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
    backgroundColor: c.fondo,
    appBar: AppBar(
      backgroundColor: c.fondo,
      elevation: 0,
      title: Text('Carnet de ${widget.nombrePerro}', style: TextStyle(color: c.texto, fontSize: 19, fontWeight: FontWeight.w700).display),
      iconTheme: IconThemeData(color: c.texto),
    ),
    body: Column(children: [
      Expanded(
        child: PageView.builder(
          itemCount: widget.imagenes.length,
          physics: _ampliado ? const NeverScrollableScrollPhysics() : null,
          onPageChanged: (index) => setState(() => _paginaActual = index),
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: ClipRSuperellipse(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: AppColors.blanco,
                child: _PaginaCarnet(
                  url: widget.imagenes[index],
                  alCambiarZoom: (ampliado) {
                    if (ampliado != _ampliado) setState(() => _ampliado = ampliado);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
      if (widget.imagenes.length > 1) ...[
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(widget.imagenes.length, (index) => AnimatedContainer(duration: const Duration(milliseconds: 180), margin: const EdgeInsets.all(4), width: index == _paginaActual ? 20 : 7, height: 7, decoration: Formas.fondo(index == _paginaActual ? c.acento : c.divisor, 10)))),
        const SizedBox(height: 20),
      ],
      Padding(padding: const EdgeInsets.only(bottom: 18), child: Text(widget.imagenes.length > 1 ? '${_paginaActual + 1} de ${widget.imagenes.length} · Desliza para ver el otro lado · Toca dos veces para acercar' : 'Pellizca o toca dos veces para acercar', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: c.textoSecundario))),
    ]),
  );
  }
}

class _PaginaCarnet extends StatefulWidget {
  const _PaginaCarnet({required this.url, required this.alCambiarZoom});
  final String url;
  final ValueChanged<bool> alCambiarZoom;

  @override
  State<_PaginaCarnet> createState() => _PaginaCarnetState();
}

class _PaginaCarnetState extends State<_PaginaCarnet> with SingleTickerProviderStateMixin {
  static const _zoomDobleToque = 2.2;
  final _transformacion = TransformationController();
  late final _animacion = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
  late final _curva = CurvedAnimation(parent: _animacion, curve: Curves.easeOutCubic);
  Animation<Matrix4>? _tramo;
  Offset _toque = Offset.zero;
  bool _ampliado = false;

  @override
  void initState() {
    super.initState();
    _transformacion.addListener(_revisarZoom);
    _animacion.addListener(() {
      if (_tramo != null) _transformacion.value = _tramo!.value;
    });
  }

  @override
  void dispose() {
    _curva.dispose();
    _animacion.dispose();
    _transformacion.dispose();
    super.dispose();
  }

  void _revisarZoom() {
    final ampliado = _transformacion.value.getMaxScaleOnAxis() > 1.01;
    if (ampliado == _ampliado) return;
    _ampliado = ampliado;
    widget.alCambiarZoom(ampliado);
  }

  void _alternarZoom() {
    final destino = _ampliado
        ? Matrix4.identity()
        : (Matrix4.diagonal3Values(_zoomDobleToque, _zoomDobleToque, 1)
          ..setTranslationRaw(-_toque.dx * (_zoomDobleToque - 1), -_toque.dy * (_zoomDobleToque - 1), 0));
    _tramo = Matrix4Tween(begin: _transformacion.value, end: destino).animate(_curva);
    _animacion.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onDoubleTapDown: (detalles) => _toque = detalles.localPosition,
        onDoubleTap: _alternarZoom,
        child: InteractiveViewer(
          transformationController: _transformacion,
          minScale: 1,
          maxScale: 3,
          child: ImagenRemota(
            url: widget.url,
            fit: BoxFit.contain,
            cargando: const SizedBox.expand(child: BloqueEsqueleto(radio: 0)),
            error: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icono(Iconos.imageOff, size: 42), SizedBox(height: 8), Text('No se pudo cargar esta imagen')])),
          ),
        ),
      );
}
