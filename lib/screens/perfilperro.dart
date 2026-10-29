import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/imagen_remota.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/services/cuidados.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

import 'estadomedico.dart';
import 'foro.dart';
import 'registraralimentacion.dart';

/// Conserva el diseño de la plantilla, pero todos sus valores vienen desde
/// el documento correspondiente de Firestore.
class PerfilPerro extends StatelessWidget {
  const PerfilPerro({super.key, required this.idPerro, this.perroInicial, this.origenFoto, this.radioOrigen = 0, PerrosRepository? perrosRepository})
      : _repository = perrosRepository;

  final String idPerro;

  final Perro? perroInicial;

  final Rect? origenFoto;
  final double radioOrigen;
  final PerrosRepository? _repository;

  static Route<void> ruta(Perro perro, {Rect? origenFoto, double radioOrigen = 0}) => PageRouteBuilder<void>(
    transitionDuration: const Duration(milliseconds: 600),
    reverseTransitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, _, _) => PerfilPerro(idPerro: perro.id, perroInicial: perro, origenFoto: origenFoto, radioOrigen: radioOrigen),
    transitionsBuilder: (_, _, _, child) => child,
  );

  @override
  Widget build(BuildContext context) => StreamBuilder<Perro?>(
    stream: (_repository ?? PerrosRepository()).observarPerro(idPerro),
    initialData: perroInicial,
    builder: (context, snapshot) {
      if (snapshot.hasError) return Scaffold(body: Center(child: Text('No se pudo cargar el perro: ${snapshot.error}')));
      if (!snapshot.hasData) return const _PerfilEsqueleto();
      if (snapshot.data == null) return const Scaffold(body: Center(child: Text('Este perro ya no está disponible.')));
      return _PlantillaPerfil(perro: snapshot.data!, origenFoto: origenFoto, radioOrigen: radioOrigen);
    },
  );
}

const _altoImagen = 350.0;
const _radioHoja = 28.0;
const _arribaInicial = _altoImagen - _radioHoja;
const _elasticoAbajo = 24.0;
const _elasticoArriba = 48.0;

class _PlantillaPerfil extends StatefulWidget {
  const _PlantillaPerfil({required this.perro, this.origenFoto, this.radioOrigen = 0});
  final Perro perro;
  final Rect? origenFoto;
  final double radioOrigen;

  @override
  State<_PlantillaPerfil> createState() => _PlantillaPerfilState();
}

class _PlantillaPerfilState extends State<_PlantillaPerfil> with SingleTickerProviderStateMixin {
  late final AnimationController _subidaHoja = AnimationController.unbounded(vsync: this);
  double _recorrido = 0;
  final _contenido = GlobalKey();
  final _acciones = GlobalKey();

  void _arrastrar(DragUpdateDetails detalles) {
    _subidaHoja.stop();
    var delta = -detalles.delta.dy;
    final actual = _subidaHoja.value;
    if (actual < 0 && delta < 0) delta *= 1 - (-actual / _elasticoAbajo).clamp(0.0, 1.0);
    if (actual > _recorrido && delta > 0) delta *= 1 - ((actual - _recorrido) / _elasticoArriba).clamp(0.0, 1.0);
    _subidaHoja.value = actual + delta;
  }

  void _soltar(DragEndDetails detalles) {
    final velocidad = -detalles.velocity.pixelsPerSecond.dy;
    final actual = _subidaHoja.value;
    final abierta = velocidad.abs() > 600 ? velocidad > 0 : actual > _recorrido / 2;
    _irA(abierta ? _recorrido : 0, velocidad);
  }

  void _irA(double destino, double velocidad) {
    _subidaHoja.animateWith(SpringSimulation(
      SpringDescription.withDampingRatio(mass: 1, stiffness: 420, ratio: .9),
      _subidaHoja.value,
      destino,
      velocidad,
    ));
  }

  void _medirHoja() {
    if (!mounted) return;
    final contenido = _contenido.currentContext?.size?.height;
    final acciones = _acciones.currentContext?.size?.height;
    if (contenido == null || acciones == null) return;
    final medidas = MediaQuery.of(context);
    final maximo = (_arribaInicial - (medidas.padding.top + 64)).clamp(0.0, double.infinity);
    final necesario = _arribaInicial + contenido + 22 - (medidas.size.height - acciones);
    _recorrido = necesario.clamp(0.0, maximo);
    if (!_subidaHoja.isAnimating && _subidaHoja.value > _recorrido) _irA(_recorrido, 0);
  }
  final _animaciones = <CurvedAnimation>[];
  late final Animation<double> _fondo, _vuelo, _hoja, _detalles;
  late final Animation<Offset> _subida;
  bool _listo = false;

  CurvedAnimation _tramo(Animation<double> ruta, double desde, double hasta, Curve curva) {
    final a = CurvedAnimation(parent: ruta, curve: Interval(desde, hasta, curve: curva));
    _animaciones.add(a);
    return a;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_listo) return;
    _listo = true;
    final ruta = ModalRoute.of(context)?.animation ?? kAlwaysCompleteAnimation;
    _fondo = _tramo(ruta, 0, .35, Curves.easeOut);
    _vuelo = _tramo(ruta, 0, .85, Curves.easeInOutCubic);
    _hoja = _tramo(ruta, .2, 1, Curves.easeOutCubic);
    _detalles = _tramo(ruta, .6, 1, Curves.easeOut);
    _subida = Tween(begin: const Offset(0, 1), end: Offset.zero).animate(_hoja);
  }

  @override
  void dispose() {
    for (final a in _animaciones) {
      a.dispose();
    }
    _subidaHoja.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final perro = widget.perro;
    final sano = perro.estado.toLowerCase() == 'saludable';
    final vacunado = perro.vacunacion.toLowerCase().startsWith('vacunado');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final seguido = perro.esSeguidoPor(uid);
    final cuidados = Cuidados(perro);
    final avisos = cuidados.avisos;
    final c = context.colores;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final pantalla = MediaQuery.sizeOf(context).height;
    final ancho = MediaQuery.sizeOf(context).width;
    final margen = MediaQuery.paddingOf(context);

    final arribaMinimo = margen.top + 64;
    WidgetsBinding.instance.addPostFrameCallback((_) => _medirHoja());

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: c.fondo,
          systemNavigationBarIconBrightness: oscuro ? Brightness.light : Brightness.dark,
        ),
        child: Stack(children: [
          Positioned.fill(child: FadeTransition(opacity: _fondo, child: ColoredBox(color: c.fondo))),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _vuelo,
              builder: (context, _) {
                final t = _vuelo.value;
                final destino = Rect.fromLTWH(0, 0, ancho, _altoImagen + _radioHoja);
                final origen = widget.origenFoto;
                return Stack(children: [
                  Positioned.fromRect(
                    rect: origen == null ? destino : Rect.lerp(origen, destino, t)!,
                    child: Opacity(
                      opacity: origen == null ? _fondo.value : 1,
                      child: ClipRSuperellipse(
                        borderRadius: BorderRadius.circular(widget.radioOrigen * (1 - t)),
                        child: _Foto(perro: perro),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: _altoImagen + _radioHoja,
            child: Stack(fit: StackFit.expand, children: [
              FadeTransition(
                opacity: _detalles,
                child: Stack(fit: StackFit.expand, children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment(0, -.5),
                        colors: [Color(0x66000000), Color(0x00000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: _radioHoja + 50,
                    left: 0,
                    right: 0,
                    child: Center(child: _EtiquetaEstado(estado: perro.estado, sano: sano)),
                  ),
                ]),
              ),
            ]),
          ),
          Positioned(
            top: _arribaInicial,
            left: 0,
            right: 0,
            height: pantalla - arribaMinimo + 160,
            child: SlideTransition(
              position: _subida,
              child: AnimatedBuilder(
                animation: _subidaHoja,
                builder: (context, hoja) => Transform.translate(
                  offset: Offset(0, -_subidaHoja.value.clamp(-_elasticoAbajo, _recorrido + _elasticoArriba)),
                  child: hoja,
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: _arrastrar,
                  onVerticalDragEnd: _soltar,
                  child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: c.fondo,
                  shape: Formas.squircleArriba(_radioHoja),
                  shadows: const [BoxShadow(color: Color(0x26000000), blurRadius: 16, offset: Offset(0, -2))],
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(key: _contenido, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const _Agarre(),
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(perro.nombre, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800).display),
                      Text('${perro.raza} · ${perro.edad}', style: const TextStyle(fontSize: 16)),
                      Row(children: [
                        Icono(Iconos.clock, size: 15, color: c.textoTenue),
                        const SizedBox(width: 3),
                        Text('Última actualización: ${_fechaRelativa(perro.actualizadoEn)}.', style: TextStyle(fontSize: 11, color: c.textoTenue)),
                      ]),
                    ])),
                    _Seguir(
                      seguido: seguido,
                      habilitado: uid != null,
                      onTap: uid == null ? null : () => _cambiarSeguimiento(context, perro, uid, seguido),
                    ),
                  ]),
                  if (avisos.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(spacing: 6, runSpacing: 6, children: [for (final aviso in avisos) _ChipAviso(aviso: aviso)]),
                  ],
                  const SizedBox(height: 15),
                  Row(children: [
                    Expanded(child: _TarjetaDato(
                      icono: Iconos.utensils,
                      titulo: 'Última comida',
                      valor: perro.ultimaComidaEn == null ? perro.ultimaComida : hora(perro.ultimaComidaEn!),
                      subtitulo: perro.ultimaComidaEn == null ? 'sin registro de hora' : 'hace ${duracion(cuidados.desdeUltimaComida!)}',
                    )),
                    const SizedBox(width: 7),
                    Expanded(child: _TarjetaDato(icono: Iconos.weight, titulo: 'Peso', valor: perro.peso, subtitulo: perro.tamano)),
                    const SizedBox(width: 7),
                    Expanded(child: _TarjetaCaracter(caracter: perro.caracter)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icono(vacunado ? Iconos.circleCheck : Iconos.circleX, color: vacunado ? c.exitoTexto : c.emergenciaTexto),
                    const SizedBox(width: 6),
                    Expanded(child: Text(perro.vacunacion, style: TextStyle(color: vacunado ? c.exitoTexto : c.emergenciaTexto, fontSize: 20))),
                  ]),
                  const SizedBox(height: 8),
                  Text(perro.descripcion, style: const TextStyle(fontSize: 16, height: 1.35)),
                  ]),
                ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(position: _subida, child: KeyedSubtree(key: _acciones, child: _AccionesPerfil(perro: perro))),
          ),
          Positioned(
            top: margen.top + 4,
            left: 4,
            child: FadeTransition(
              opacity: _detalles,
              child: _IconoFlotante(icono: Iconos.chevronLeft, onTap: () => Navigator.pop(context)),
            ),
          ),
          Positioned(
            top: margen.top + 4,
            right: 4,
            child: FadeTransition(
              opacity: _detalles,
              child: _IconoFlotante(icono: Iconos.pencil, onTap: () => _mensaje(context, 'Editar perfil')),
            ),
          ),
        ]),
      ),
    );
  }
}

class _PerfilEsqueleto extends StatelessWidget {
  const _PerfilEsqueleto();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colores.fondo,
    body: Stack(children: [
      const Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: _altoImagen + _radioHoja,
        child: BloqueEsqueleto(radio: 0),
      ),
      Positioned(
        top: MediaQuery.paddingOf(context).top + 4,
        left: 4,
        child: _IconoFlotante(icono: Iconos.chevronLeft, onTap: () => Navigator.pop(context)),
      ),
    ]),
  );
}

class _Agarre extends StatelessWidget {
  const _Agarre();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: Formas.fondo(context.colores.divisor, 2),
    ),
  );
}

ButtonStyle _estilo(Color color) => ElevatedButton.styleFrom(elevation: 0, backgroundColor: color, shape: Formas.squircle(10));

class _Foto extends StatelessWidget {
  const _Foto({required this.perro});
  final Perro perro;

  @override
  Widget build(BuildContext context) {
    final vacio = ColoredBox(color: context.colores.contenedor, child: const Center(child: Icono(Iconos.pawPrint, size: 80)));
    if (perro.fotoUrl.isNotEmpty) return ImagenRemota(url: perro.fotoUrl, fit: BoxFit.cover, alignment: perro.encuadre, error: vacio);
    if (perro.imagenAsset.isNotEmpty) return Image.asset('fotos/${perro.imagenAsset}', fit: BoxFit.cover, alignment: perro.encuadre, errorBuilder: (_, _, _) => vacio);
    return vacio;
  }
}

class _IconoFlotante extends StatelessWidget {
  const _IconoFlotante({required this.icono, required this.onTap});
  final IconData icono;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: context.colores.superficie, elevation: 2, shape: const CircleBorder(), child: IconButton(iconSize: 20, onPressed: onTap, icon: Icono(icono, color: context.colores.textoTenue)));
}

class _EtiquetaEstado extends StatelessWidget {
  const _EtiquetaEstado({required this.estado, required this.sano});
  final String estado;
  final bool sano;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7), decoration: Formas.fondo(context.colores.superficie, 18), child: Text(estado, style: TextStyle(fontSize: 11, color: sano ? context.colores.exitoTexto : context.colores.advertenciaTexto)));
}

class _ChipAviso extends StatelessWidget {
  const _ChipAviso({required this.aviso});
  final Aviso aviso;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final urgente = aviso.gravedad == Gravedad.urgente;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: Formas.fondo(urgente ? c.emergenciaSuave : c.advertenciaSuave, 10),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icono(urgente ? Iconos.circleAlert : Iconos.clock, size: 15, color: urgente ? c.emergenciaTexto : c.advertenciaTexto),
        const SizedBox(width: 5),
        Text(aviso.texto, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: urgente ? c.emergenciaTexto : c.advertenciaTexto)),
      ]),
    );
  }
}

/// Acciones fuera del área desplazable: siempre quedan ancladas abajo.
class _AccionesPerfil extends StatelessWidget {
  const _AccionesPerfil({required this.perro});
  final Perro perro;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
    color: c.fondo,
    padding: EdgeInsets.fromLTRB(12, 8, 12, 16 + MediaQuery.paddingOf(context).bottom),
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: Icono(Iconos.clock, size: 15, color: c.textoTenue)),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Próxima alimentación sugerida: '),
                TextSpan(text: Cuidados(perro).textoProximaComida, style: TextStyle(fontWeight: FontWeight.w700, color: c.texto)),
              ]),
              style: TextStyle(fontSize: 13, color: c.textoSecundario),
            ),
          ),
        ]),
      ),
      Presionable(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: _estilo(c.acento),
            onPressed: () => mostrarHoja<void>(
              context,
              builder: (_) => RegistrarAlimentacion(perro: perro),
            ),
            icon: Icono(Iconos.utensils, color: c.sobreAcento, size: 28),
            label: Text('Registrar alimentación', style: TextStyle(color: c.sobreAcento, fontSize: 20)),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: Presionable(
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                style: _estilo(c.medico),
                onPressed: () => mostrarHoja<void>(
                  context,
                  builder: (_) => EstadoMedico(perro: perro, actualizado: _fechaRelativa(perro.actualizadoEn)),
                ),
                icon: Icono(Iconos.stethoscope, color: c.sobreAcento, size: 26),
                label: FittedBox(fit: BoxFit.scaleDown, child: Text('Estado médico', style: TextStyle(color: c.sobreAcento, fontSize: 17))),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Presionable(
            child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              style: _estilo(c.tonal),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Foro(IDPerro: perro.id, nombrePerro: perro.nombre)),
              ),
              icon: Icono(Iconos.messageCircle, color: c.sobreTonal, size: 28),
              label: Text('Foro', style: TextStyle(color: c.sobreTonal, fontSize: 20)),
            ),
          ),
          ),
        ),
      ]),
    ]),
  );
  }
}

class _Seguir extends StatefulWidget {
  const _Seguir({required this.seguido, required this.habilitado, this.onTap});
  final bool seguido;
  final bool habilitado;
  final Future<void> Function()? onTap;

  @override
  State<_Seguir> createState() => _SeguirState();
}

class _SeguirState extends State<_Seguir> with SingleTickerProviderStateMixin {
  late final AnimationController _pisadas = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    value: widget.seguido ? 1 : 0,
  );
  late bool _seguido = widget.seguido;

  @override
  void didUpdateWidget(_Seguir anterior) {
    super.didUpdateWidget(anterior);
    if (widget.seguido != anterior.seguido && widget.seguido != _seguido) {
      _seguido = widget.seguido;
      _pisadas.value = _seguido ? 1 : 0;
    }
  }

  @override
  void dispose() {
    _pisadas.dispose();
    super.dispose();
  }

  Future<void> _tocar() async {
    setState(() => _seguido = !_seguido);
    if (_seguido) {
      _pisadas.forward(from: 0);
    } else {
      _pisadas.animateBack(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
    await widget.onTap?.call();
    if (mounted && widget.seguido != _seguido) {
      setState(() => _seguido = widget.seguido);
      _pisadas.animateTo(_seguido ? 1 : 0, duration: const Duration(milliseconds: 250));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Material(
      color: c.superficie,
      shape: Formas.squircle(10),
      child: InkWell(
        onTap: widget.habilitado && widget.onTap != null ? _tocar : null,
        customBorder: Formas.squircle(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(children: [
            const SizedBox(width: 56),
            SizedBox(
              width: 44,
              height: 38,
              child: AnimatedBuilder(
                animation: _pisadas,
                builder: (context, _) => Stack(children: [
                  _Pata(t: _pisadas.value, desde: .25, izquierda: 0, arriba: 14, grises: c.textoTenue, color: c.acento),
                  _Pata(t: _pisadas.value, desde: .5, izquierda: 20, arriba: 0, grises: c.textoTenue, color: c.acento),
                ]),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                _seguido ? 'Seguido' : 'Seguir',
                key: ValueKey(_seguido),
                style: TextStyle(fontSize: 13, fontWeight: _seguido ? FontWeight.w700 : FontWeight.w400, color: _seguido ? c.acento : c.textoTenue),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Pata extends StatelessWidget {
  const _Pata({required this.t, required this.desde, required this.izquierda, required this.arriba, required this.grises, required this.color});
  final double t;
  final double desde;
  final double izquierda;
  final double arriba;
  final Color grises;
  final Color color;

  static const _tamano = 22.0;
  static const _giro = -.35;

  @override
  Widget build(BuildContext context) {
    final salida = Curves.easeIn.transform((t / .2).clamp(0.0, 1.0));
    final pisada = Curves.easeOutBack.transform(((t - desde) / .4).clamp(0.0, 1.0));
    final aparece = ((t - desde) / .12).clamp(0.0, 1.0);
    return Positioned(
      left: izquierda,
      top: arriba,
      child: Stack(alignment: Alignment.center, children: [
        Opacity(
          opacity: 1 - salida,
          child: Transform.scale(
            scale: 1 - .4 * salida,
            child: Transform.rotate(angle: _giro, child: Icono(Iconos.pawPrint, size: _tamano, color: grises)),
          ),
        ),
        Opacity(
          opacity: aparece,
          child: Transform.scale(
            scale: 1.8 - .8 * pisada,
            child: Transform.rotate(angle: _giro + .3 * (1 - pisada), child: Icono(Iconos.pawPrintRelleno, size: _tamano, color: color)),
          ),
        ),
      ]),
    );
  }
}

class _TarjetaDato extends StatelessWidget {
  const _TarjetaDato({required this.icono, required this.titulo, required this.valor, required this.subtitulo});
  final IconData icono;
  final String titulo;
  final String valor;
  final String subtitulo;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: context.colores.superficie,
    child: SizedBox(
      height: 110,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icono(icono, size: 27),
            Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            Text(valor, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600).display),
            Text(subtitulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: context.colores.textoTenue)),
          ],
        ),
      ),
    ),
  );
}

class _TarjetaCaracter extends StatelessWidget {
  const _TarjetaCaracter({required this.caracter});
  final String caracter;
  @override
  Widget build(BuildContext context) {
    final amable = caracter.toLowerCase().contains('cariñ') || caracter.toLowerCase().contains('amigable');
    final c = context.colores;
    final color = amable ? c.exitoTexto : c.advertenciaTexto;
    return Card(color: amable ? c.exitoSuave : c.advertenciaSuave, elevation: 0, child: SizedBox(height: 110, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icono(amable ? Iconos.heart : Iconos.triangleAlert, size: 50, color: color), Text(caracter, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color))])));
  }
}

String _fechaRelativa(dynamic timestamp) {
  if (timestamp == null) return 'sin registro';
  final diferencia = DateTime.now().difference(timestamp.toDate());
  if (diferencia.inMinutes < 60) return 'hace ${diferencia.inMinutes} min';
  if (diferencia.inHours < 24) return 'hace ${diferencia.inHours} h';
  return 'hace ${diferencia.inDays} ${diferencia.inDays == 1 ? 'día' : 'días'}';
}

void _mensaje(BuildContext context, String texto) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$texto estará disponible próximamente.')));

Future<void> _cambiarSeguimiento(BuildContext context, Perro perro, String uid, bool seguido) async {
  try {
    await PerrosRepository().actualizarSeguimiento(idPerro: perro.id, uid: uid, seguir: !seguido);
  } catch (_) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo actualizar el seguimiento.')));
  }
}
