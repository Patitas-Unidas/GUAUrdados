import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/widgets/foto_perro.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

import 'perfilperro.dart';

class Camara extends StatefulWidget {
  const Camara({super.key});

  @override
  State<Camara> createState() => _CamaraState();
}

class _CamaraState extends State<Camara> {
  bool isReady = false;
  late List<CameraDescription> camaras;
  late CameraController _controller;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    try {
      camaras = await availableCameras();
      if (camaras.isEmpty) return;

      _controller = CameraController(
        camaras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller.initialize();
    } on CameraException catch (_) {
      debugPrint("Error al inicializar la cámara.");
    }

    if (!mounted) return;

    setState(() {
      isReady = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navegarADisplay(String imagePath) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DisplayPictureScreen(
          imagePath: imagePath,
        ),
      ),
    );
  }

  Future<void> _seleccionarDeGaleria() async {
    try {
      final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery);
      if (imagen != null && mounted) {
        await _navegarADisplay(imagen.path);
      }
    } catch (e) {
      debugPrint("Error al seleccionar de galería: $e");
    }
  }

  Future<void> _capturarFoto() async {
    try {
      final image = await _controller.takePicture();
      if (!mounted) return;
      await _navegarADisplay(image.path);
    } catch (e) {
      debugPrint("Error al capturar fotografía: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isReady || !_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .10,
                color: Colors.black,
              ),
              FittedBox(
                fit: BoxFit.fitWidth,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * .70,
                  child: CameraPreview(_controller),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * .20,
                color: Colors.black,
              ),
            ],
          ),
          const Positioned.fill(child: _Guia()),
          Padding(
            padding: const EdgeInsets.only(top: 35, left: 16),
            child: IconButton(
              tooltip: 'Volver',
              style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: .18)),
              icon: const Icono(Iconos.chevronLeft, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: "btn_galeria",
                  backgroundColor: Colors.black45,
                  foregroundColor: Colors.white,
                  onPressed: _seleccionarDeGaleria,
                  child: const Icon(Icons.photo_library),
                ),
                FloatingActionButton.large(
                  heroTag: "btn_captura",
                  shape: const CircleBorder(),
                  onPressed: _capturarFoto,
                  child: const Icon(Icons.camera_alt),
                ),
                const SizedBox(width: 56),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  const DisplayPictureScreen({super.key, required this.imagePath});
  final String imagePath;

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

sealed class _Resultado {
  const _Resultado();
}

class _Escaneando extends _Resultado {
  const _Escaneando();
}

class _Encontrado extends _Resultado {
  const _Encontrado(this.perro);
  final Map<String, dynamic> perro;
}

class _Dudoso extends _Resultado {
  const _Dudoso(this.candidatos);
  final List<Map<String, dynamic>> candidatos;
}

class _SinCoincidencia extends _Resultado {
  const _SinCoincidencia(this.mensaje);
  final String mensaje;
}

class _SinConexion extends _Resultado {
  const _SinConexion();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final String _apiUrl = "https://hangnail-frosty-gave.ngrok-free.dev/identificar";
  _Resultado _resultado = const _Escaneando();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _identificarPerro());
  }

  Future<void> _identificarPerro() async {
    setState(() => _resultado = const _Escaneando());
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', widget.imagePath));
      final response = await http.Response.fromStream(await request.send());
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() => _resultado = _interpretar(data));
    } catch (_) {
      if (mounted) setState(() => _resultado = const _SinConexion());
    }
  }

  _Resultado _interpretar(Map<String, dynamic> data) => switch (data['status']) {
        'MATCH' => _Encontrado(Map<String, dynamic>.from(data['perro'] as Map)),
        'AMBIGUOUS' => _Dudoso([
            for (final clave in ['candidato_1', 'candidato_2'])
              if (data[clave] is Map) Map<String, dynamic>.from(data[clave] as Map),
          ]),
        _ => _SinCoincidencia(data['mensaje'] as String? ?? 'No se encontró ningún registro que coincida.'),
      };

  void _irAlPerfil(String idPerro) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => PerfilPerro(idPerro: idPerro)));

  void _irABuscarManualmente() => Navigator.of(context).popUntil((ruta) => ruta.isFirst);

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final encontrado = _resultado is _Encontrado;
    final (color, icono, texto) = switch (_resultado) {
      _Escaneando() => (Color.lerp(c.acento, Colors.white, .3)!, Iconos.hourglass, 'Escaneando…'),
      _Encontrado() => (c.exito, Iconos.circleCheck, 'Perrito identificado'),
      _Dudoso() => (c.advertencia, Iconos.search, 'Coincidencia parcial'),
      _SinCoincidencia() => (c.emergencia, Iconos.searchX, 'No se encontró coincidencia'),
      _SinConexion() => (c.emergencia, Iconos.wifiOff, 'Sin conexión con el servidor'),
    };
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(builder: (context, medidas) {
        final lado = medidas.maxWidth * _ladoMarco;
        final marco = Rect.fromCenter(center: Offset(medidas.maxWidth / 2, medidas.maxHeight * .36), width: lado, height: lado);
        final arriba = MediaQuery.paddingOf(context).top;
        return Stack(children: [
          Positioned.fill(child: Image.file(File(widget.imagePath), fit: BoxFit.cover)),
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              color: encontrado ? const Color(0xff0b3d24).withValues(alpha: .45) : Colors.black.withValues(alpha: .12),
            ),
          ),
          Positioned.fromRect(rect: marco, child: _Visor(color: color, escaneando: _resultado is _Escaneando, encontrado: encontrado)),
          Positioned(
            top: arriba + 8,
            left: 12,
            child: IconButton(
              tooltip: 'Volver',
              style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: .35)),
              icon: const Icono(Iconos.chevronLeft, color: Colors.white, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: arriba + 64,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _PildoraEstado(key: ValueKey(texto), icono: icono, texto: texto, color: encontrado ? c.exito : null),
              ),
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _hoja(c)),
        ]);
      }),
    );
  }

  Widget _hoja(ColoresApp c) => Container(
        decoration: ShapeDecoration(
          color: c.fondo,
          shape: Formas.squircleArriba(28),
          shadows: const [BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, -2))],
        ),
        padding: EdgeInsets.fromLTRB(18, 10, 18, 16 + MediaQuery.paddingOf(context).bottom),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          alignment: Alignment.bottomCenter,
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(
              child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: Formas.fondo(c.divisor, 2)),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (hijo, animacion) => FadeTransition(
                opacity: animacion,
                child: SlideTransition(position: Tween(begin: const Offset(0, .08), end: Offset.zero).animate(animacion), child: hijo),
              ),
              child: KeyedSubtree(key: ValueKey(_resultado.runtimeType), child: _contenido(c)),
            ),
          ]),
        ),
      );

  Widget _contenido(ColoresApp c) => switch (_resultado) {
        _Escaneando() => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Identificando al perrito…', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: c.textoSecundario)),
            const SizedBox(height: 10),
            _Puntos(color: c.acento),
            const SizedBox(height: 22),
            Text('¿No lo reconoces?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.texto)),
            const SizedBox(height: 12),
            _BotonEscaneo(texto: 'Buscar manualmente', icono: Iconos.search, alTocar: _irABuscarManualmente),
          ]),
        _Encontrado(:final perro) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _TarjetaResultado(
              fondo: c.exito,
              titulo: 'Es ${perro['nombre'] ?? 'un perrito registrado'}',
              detalle: [perro['sexo'], if ((perro['coincidencia'] ?? '').toString().isNotEmpty) 'Similitud ${perro['coincidencia']}']
                  .whereType<String>()
                  .where((t) => t.isNotEmpty)
                  .join(' · '),
              colorDetalle: c.exitoTexto,
              inicio: _FotoResultado(id: perro['id'] as String? ?? '', color: c.exitoTexto),
            ),
            const SizedBox(height: 14),
            _BotonEscaneo(
              texto: 'Ver perfil de ${perro['nombre'] ?? 'este perrito'}',
              icono: Iconos.pawPrint,
              alTocar: () => _irAlPerfil(perro['id'] as String? ?? ''),
            ),
            _BotonTexto(texto: 'Tomar otra foto', alTocar: () => Navigator.pop(context)),
          ]),
        _Dudoso(:final candidatos) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Podría ser alguno de estos perritos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: c.texto)),
            const SizedBox(height: 4),
            Text('Toca el que corresponda para ver su perfil.', style: TextStyle(fontSize: 13, color: c.textoSecundario)),
            const SizedBox(height: 12),
            for (final candidato in candidatos) ...[
              _TarjetaResultado(
                fondo: c.superficie,
                titulo: candidato['nombre'] as String? ?? 'Perrito',
                detalle: [candidato['subtitulo'] ?? candidato['sexo'], if ((candidato['coincidencia'] ?? '').toString().isNotEmpty) 'Similitud ${candidato['coincidencia']}']
                    .whereType<String>()
                    .where((t) => t.isNotEmpty)
                    .join(' · '),
                colorDetalle: c.textoSecundario,
                inicio: _FotoResultado(id: candidato['id'] as String? ?? '', color: c.textoTenue),
                fin: Icono(Iconos.chevronRight, color: c.textoTenue),
                alTocar: () => _irAlPerfil(candidato['id'] as String? ?? ''),
              ),
              const SizedBox(height: 8),
            ],
            _BotonTexto(texto: 'Tomar otra foto', alTocar: () => Navigator.pop(context)),
          ]),
        _SinCoincidencia(:final mensaje) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _TarjetaResultado(
              fondo: c.emergencia,
              titulo: 'Sin coincidencias',
              colorTitulo: c.emergenciaTexto,
              detalle: mensaje,
              colorDetalle: c.textoSecundario,
              inicio: Icono(Iconos.searchX, color: c.emergenciaTexto, size: 22),
            ),
            const SizedBox(height: 10),
            _BotonEscaneo(texto: 'Reintentar con otra foto', icono: Iconos.camera, tonal: true, alTocar: () => Navigator.pop(context)),
            const SizedBox(height: 10),
            _BotonEscaneo(texto: 'Buscar manualmente', icono: Iconos.search, alTocar: _irABuscarManualmente),
          ]),
        _SinConexion() => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _TarjetaResultado(
              fondo: c.advertencia,
              titulo: 'No pudimos conectar con el servidor',
              colorTitulo: c.advertenciaTexto,
              detalle: 'Revisa tu conexión o inténtalo en un momento.',
              colorDetalle: c.textoSecundario,
              inicio: Icono(Iconos.wifiOff, color: c.advertenciaTexto, size: 22),
            ),
            const SizedBox(height: 10),
            _BotonEscaneo(texto: 'Reintentar', icono: Iconos.rotateCw, tonal: true, alTocar: _identificarPerro),
            const SizedBox(height: 10),
            _BotonEscaneo(texto: 'Buscar manualmente', icono: Iconos.search, alTocar: _irABuscarManualmente),
          ]),
      };
}

const _ladoMarco = .8;

class _Guia extends StatelessWidget {
  const _Guia();

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, medidas) {
        final lado = medidas.maxWidth * _ladoMarco;
        final marco = Rect.fromCenter(center: Offset(medidas.maxWidth / 2, medidas.maxHeight * .45), width: lado, height: lado);
        return Stack(children: [
          Positioned.fromRect(
            rect: marco,
            child: const CustomPaint(painter: _Escaner(color: Colors.white, avance: null, relleno: false)),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: medidas.maxHeight - marco.top + 14,
            child: const Center(
              child: _PildoraEstado(
                icono: Iconos.scanFace,
                texto: 'Centra la carita completa del perrito',
                detalle: 'De frente y con buena luz',
              ),
            ),
          ),
        ]);
      });
}

class _PildoraEstado extends StatelessWidget {
  const _PildoraEstado({super.key, required this.icono, required this.texto, this.detalle, this.color});
  final IconData icono;
  final String texto;
  final String? detalle;
  final Color? color;

  @override
  Widget build(BuildContext context) => ClipRSuperellipse(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            color: color ?? Colors.black.withValues(alpha: .55),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icono(icono, color: Colors.white, size: detalle == null ? 16 : 22),
              SizedBox(width: detalle == null ? 7 : 10),
              Flexible(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text(texto, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  if (detalle != null) Text(detalle!, style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 12)),
                ]),
              ),
            ]),
          ),
        ),
      );
}

class _Visor extends StatefulWidget {
  const _Visor({required this.color, required this.escaneando, required this.encontrado});
  final Color color;
  final bool escaneando;
  final bool encontrado;

  @override
  State<_Visor> createState() => _VisorState();
}

class _VisorState extends State<_Visor> with TickerProviderStateMixin {
  late final _laser = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));
  late final _recorrido = CurvedAnimation(parent: _laser, curve: Curves.easeInOutSine);
  late final _exito = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  late final _aparicion = CurvedAnimation(parent: _exito, curve: Curves.easeOutBack);

  @override
  void initState() {
    super.initState();
    _sincronizar();
  }

  @override
  void didUpdateWidget(_Visor anterior) {
    super.didUpdateWidget(anterior);
    _sincronizar();
  }

  void _sincronizar() {
    widget.escaneando ? _laser.repeat(reverse: true) : _laser.stop();
    widget.encontrado ? _exito.forward() : _exito.reverse();
  }

  @override
  void dispose() {
    _recorrido.dispose();
    _aparicion.dispose();
    _laser.dispose();
    _exito.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<Color?>(
        tween: ColorTween(end: widget.color),
        duration: const Duration(milliseconds: 350),
        builder: (context, color, _) => AnimatedBuilder(
          animation: Listenable.merge([_recorrido, _aparicion]),
          builder: (context, _) => Stack(alignment: Alignment.center, children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _Escaner(
                  color: color ?? widget.color,
                  avance: widget.escaneando ? _recorrido.value : null,
                  relleno: widget.escaneando,
                ),
              ),
            ),
            if (_exito.value > 0)
              Transform.scale(
                scale: _aparicion.value,
                child: Opacity(
                  opacity: _exito.value.clamp(0.0, 1.0),
                  child: FractionallySizedBox(
                    widthFactor: .82,
                    heightFactor: .82,
                    child: DecoratedBox(
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: widget.color, width: 3)),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color.withValues(alpha: .25), border: Border.all(color: widget.color, width: 2)),
                          child: Icono(Iconos.check, color: widget.color, size: 24),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      );
}

class _Escaner extends CustomPainter {
  const _Escaner({required this.color, required this.avance, required this.relleno});
  final Color color;
  final double? avance;
  final bool relleno;

  @override
  void paint(Canvas canvas, Size size) {
    final caja = Offset.zero & size;
    if (relleno) {
      canvas.drawPath(Formas.squircle(18).getOuterPath(caja), Paint()..color = Colors.white.withValues(alpha: .10));
      canvas.drawPath(
        Formas.squircle(18).getOuterPath(caja.deflate(1)),
        Paint()
          ..color = color.withValues(alpha: .35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }

    const largo = 40.0;
    const radio = 16.0;
    final esquina = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    for (final (x, y) in const [(0.0, 0.0), (1.0, 0.0), (0.0, 1.0), (1.0, 1.0)]) {
      final px = x * size.width;
      final py = y * size.height;
      final sx = x == 0 ? 1.0 : -1.0;
      final sy = y == 0 ? 1.0 : -1.0;
      canvas.drawPath(
        Path()
          ..moveTo(px, py + sy * largo)
          ..lineTo(px, py + sy * radio)
          ..quadraticBezierTo(px, py, px + sx * radio, py)
          ..lineTo(px + sx * largo, py),
        esquina,
      );
    }

    final avance = this.avance;
    if (avance == null) return;
    final y = 12 + (size.height - 24) * avance;
    final linea = Rect.fromLTWH(10, y - 1.25, size.width - 20, 2.5);
    final estela = Rect.fromLTWH(10, y - 24, size.width - 20, 24);
    final degradado = LinearGradient(colors: [color.withValues(alpha: 0), color, color.withValues(alpha: 0)]);
    canvas.saveLayer(estela, Paint());
    canvas.drawRect(
      estela,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [color.withValues(alpha: .3), color.withValues(alpha: 0)],
        ).createShader(estela),
    );
    canvas.drawRect(
      estela,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = const LinearGradient(colors: [Color(0x00000000), Color(0xFF000000), Color(0x00000000)]).createShader(estela),
    );
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(linea.inflate(4), const Radius.circular(6)),
      Paint()
        ..shader = degradado.createShader(linea)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(RRect.fromRectAndRadius(linea, const Radius.circular(2)), Paint()..shader = degradado.createShader(linea));
  }

  @override
  bool shouldRepaint(_Escaner anterior) => anterior.color != color || anterior.avance != avance || anterior.relleno != relleno;
}

class _Puntos extends StatefulWidget {
  const _Puntos({required this.color});
  final Color color;

  @override
  State<_Puntos> createState() => _PuntosState();
}

class _PuntosState extends State<_Puntos> with SingleTickerProviderStateMixin {
  late final _ciclo = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ciclo,
        builder: (context, _) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var i = 0; i < 3; i++)
            Builder(builder: (context) {
              final fase = (_ciclo.value - i * .18) % 1;
              final pulso = fase < .5 ? Curves.easeInOut.transform(1 - (fase * 2 - .5).abs() * 2) : 0.0;
              return Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                transform: Matrix4.translationValues(0, -4 * pulso, 0),
                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color.withValues(alpha: .35 + .65 * pulso)),
              );
            }),
        ]),
      );
}

class _TarjetaResultado extends StatelessWidget {
  const _TarjetaResultado({
    required this.fondo,
    required this.titulo,
    required this.detalle,
    required this.colorDetalle,
    required this.inicio,
    this.colorTitulo,
    this.fin,
    this.alTocar,
  });
  final Color fondo;
  final String titulo;
  final String detalle;
  final Color colorDetalle;
  final Color? colorTitulo;
  final Widget inicio;
  final Widget? fin;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final contenido = Padding(
      padding: const EdgeInsets.all(14),
      child: Row(children: [
        inicio,
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colorTitulo ?? c.texto)),
            if (detalle.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(detalle, style: TextStyle(fontSize: 12.5, color: colorDetalle, fontWeight: FontWeight.w500)),
            ],
          ]),
        ),
        ?fin,
      ]),
    );
    final tinte = alTocar == null;
    final forma = Formas.squircle(18, lado: BorderSide(color: tinte ? fondo.withValues(alpha: .28) : c.divisor));
    return Presionable(
      escala: tinte ? 1 : .97,
      child: Material(
        color: tinte ? Color.alphaBlend(fondo.withValues(alpha: .1), c.superficie) : fondo,
        shape: forma,
        child: tinte ? contenido : InkWell(customBorder: forma, onTap: alTocar, child: contenido),
      ),
    );
  }
}

class _FotoResultado extends StatelessWidget {
  const _FotoResultado({required this.id, required this.color});
  final String id;
  final Color color;

  @override
  Widget build(BuildContext context) => id.isEmpty
      ? Icono(Iconos.circleCheck, color: color, size: 26)
      : StreamBuilder<Perro?>(
          stream: PerrosRepository().observarPerro(id),
          builder: (context, snapshot) => FotoPerroRedonda(perro: snapshot.data, tamano: 48),
        );
}

class _BotonEscaneo extends StatelessWidget {
  const _BotonEscaneo({required this.texto, required this.icono, required this.alTocar, this.tonal = false});
  final String texto;
  final IconData icono;
  final VoidCallback alTocar;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final frente = tonal ? c.acento : c.sobreAcento;
    return Presionable(
      child: SizedBox(
        height: 52,
        child: FilledButton.icon(
          onPressed: alTocar,
          style: FilledButton.styleFrom(
            backgroundColor: tonal ? c.acento.withValues(alpha: .12) : c.acento,
            foregroundColor: frente,
            shape: Formas.squircle(16),
          ),
          icon: Icono(icono, color: frente, size: 20),
          label: Text(texto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

class _BotonTexto extends StatelessWidget {
  const _BotonTexto({required this.texto, required this.alTocar});
  final String texto;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6),
        child: TextButton(
          onPressed: alTocar,
          style: TextButton.styleFrom(foregroundColor: context.colores.textoSecundario, minimumSize: const Size.fromHeight(44)),
          child: Text(texto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      );
}
