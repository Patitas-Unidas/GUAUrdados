import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/imagen_remota.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/services/permisos_usuario.dart';
import 'package:guaurdados_oficial/services/alimentaciones.dart';
import 'package:guaurdados_oficial/services/cuidados.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/apoyo_guau.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/widgets/estado_perro.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

import 'estadomedico.dart';
import 'foro.dart';
import 'registraralimentacion.dart';
import 'package:guaurdados_oficial/services/rutas.dart';

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

  static Route<void> rutaPorId(String idPerro) => MaterialPageRoute(
        settings: RouteSettings(name: 'perro/$idPerro'),
        builder: (_) => PerfilPerro(idPerro: idPerro),
      );

  static Route<void> ruta(Perro perro, {Rect? origenFoto, double radioOrigen = 0}) => PageRouteBuilder<void>(
    settings: RouteSettings(name: 'perro/${perro.id}'),
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

  void _alActualizar() => setState(() {});

  @override
  void initState() {
    super.initState();
    Alimentaciones.escuchar();
    Alimentaciones.recientes.addListener(_alActualizar);
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
    Alimentaciones.recientes.removeListener(_alActualizar);
    for (final a in _animaciones) {
      a.dispose();
    }
    _subidaHoja.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final perro = widget.perro;
    final vacunado = perro.vacunacion.toLowerCase().startsWith('vacunado');
    final sinVacunas = perro.vacunacion.trim().toLowerCase().startsWith('no');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final seguido = perro.esSeguidoPor(uid);
    final cuidados = Cuidados(perro, alimentaciones: Alimentaciones.de(perro.id));
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
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: oscuro ? Brightness.light : Brightness.dark,
          systemNavigationBarContrastEnforced: false,
        ),
        child: _Adopcion(perro: perro, ficha: Stack(children: [
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
                    child: Center(child: PildoraEstado(cuidados.estado, ancha: true)),
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
                      Text(_razaYEdad(perro), style: const TextStyle(fontSize: 16)),
                      Row(children: [
                        Icono(perro.adoptado ? Iconos.heart : Iconos.clock, size: 15, color: perro.adoptado ? c.adoptadoTexto : c.textoTenue),
                        const SizedBox(width: 3),
                        Text(
                          perro.adoptado
                              ? perro.adoptadoEn == null ? 'Ya tiene un hogar' : 'Adoptado el ${fecha(perro.adoptadoEn!)}'
                              : perro.actualizadoEn == null ? 'Sin actualizaciones aún' : 'Última actualización: ${_fechaRelativa(perro.actualizadoEn)}',
                          style: TextStyle(fontSize: 11, color: perro.adoptado ? c.adoptadoTexto : c.textoTenue, fontWeight: perro.adoptado ? FontWeight.w600 : null),
                        ),
                      ]),
                    ])),
                    if (!perro.adoptado || seguido)
                    _Seguir(
                      seguido: seguido,
                      habilitado: uid != null,
                      onTap: uid == null ? null : () => _cambiarSeguimiento(context, perro, uid, seguido),
                    ),
                  ]),
                  if (avisos.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(spacing: 6, runSpacing: 6, children: [for (final aviso in avisos) ChipAviso(aviso)]),
                  ],
                  const SizedBox(height: 15),
                  IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    if (!perro.adoptado) ...[
                    Expanded(child: _TarjetaDato(
                      icono: Iconos.utensils,
                      titulo: 'Última comida',
                      valor: cuidados.ultimaComidaEn != null ? hora(cuidados.ultimaComidaEn!) : tieneDato(perro.ultimaComida) ? perro.ultimaComida : '—',
                      subtitulo: cuidados.ultimaComidaEn != null ? 'hace ${duracion(cuidados.desdeUltimaComida!)}' : tieneDato(perro.ultimaComida) ? 'sin fecha' : 'sin registro',
                    )),
                    const SizedBox(width: 7),
                    ],
                    Expanded(child: _TarjetaDato(icono: Iconos.weight, titulo: 'Peso', valor: tieneDato(perro.peso) ? perro.peso : '—', subtitulo: tieneDato(perro.tamano) ? perro.tamano : 'sin registro')),
                    const SizedBox(width: 7),
                    Expanded(child: _TarjetaCaracter(caracter: perro.caracter)),
                  ])),
                  if (!perro.adoptado) ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    Builder(builder: (context) {
                      final (_, tono) = c.tono(vacunado ? Gravedad.bien : sinVacunas && cuidados.evaluado ? Gravedad.revisar : Gravedad.neutro);
                      return Expanded(
                        child: Row(children: [
                          Icono(vacunado ? Iconos.circleCheck : sinVacunas ? Iconos.circleAlert : Iconos.circleHelp, color: tono),
                          const SizedBox(width: 6),
                          Expanded(child: Text(tieneDato(perro.vacunacion) ? perro.vacunacion : 'Vacunas sin registrar', style: TextStyle(color: tono, fontSize: 20))),
                        ]),
                      );
                    }),
                  ]),
                  ],
                  const SizedBox(height: 8),
                  Text(perro.descripcion, style: TextStyle(fontSize: 15.5, height: 1.5, color: c.texto.withValues(alpha: .9))),
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
            top: margen.top + 14,
            left: 6,
            child: FadeTransition(
              opacity: _detalles,
              child: _IconoFlotante(icono: Iconos.chevronLeft, onTap: () => Navigator.pop(context)),
            ),
          ),
          Positioned(
            top: margen.top + 14,
            right: 6,
            child: FadeTransition(
              opacity: _detalles,
              child: _BotonEsquina(perro: perro),
            ),
          ),
        ])),
      ),
    );
  }
}

class _Adopcion extends StatefulWidget {
  const _Adopcion({required this.perro, required this.ficha});
  final Perro perro;
  final Widget ficha;

  @override
  State<_Adopcion> createState() => _AdopcionState();
}

class _AdopcionState extends State<_Adopcion> {
  bool _verFicha = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.perro.adoptado) return widget.ficha;
    final c = context.colores;
    final perro = widget.perro;
    final cubierta = !_verFicha;
    return Stack(children: [
      TweenAnimationBuilder<double>(
        tween: Tween(end: cubierta ? 14 : 0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        builder: (context, blur, ficha) => ImageFiltered(
          enabled: blur > .1,
          imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: IgnorePointer(ignoring: cubierta, child: ficha),
        ),
        child: widget.ficha,
      ),
      IgnorePointer(
        ignoring: !cubierta,
        child: AnimatedOpacity(
          opacity: cubierta ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: ColoredBox(
            color: c.velo.withValues(alpha: .35),
            child: SafeArea(
              child: Stack(children: [
                Positioned(
                  top: 14,
                  left: 6,
                  child: _IconoFlotante(icono: Iconos.chevronLeft, onTap: () => Navigator.pop(context)),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Aparicion(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
                        decoration: ShapeDecoration(
                          color: c.fondo,
                          shape: Formas.squircle(28),
                          shadows: const [BoxShadow(color: Color(0x40000000), blurRadius: 30, offset: Offset(0, 10))],
                        ),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: ShapeDecoration(color: c.adoptadoSuave, shape: Formas.squircle(20)),
                            child: Center(child: Icono(Iconos.heart, size: 34, color: c.adoptadoTexto)),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '¡${perro.nombre} ya tiene un hogar!',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800).display,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${perro.adoptadoEn == null ? 'Encontró una familia' : 'Encontró una familia el ${fechaLarga(perro.adoptadoEn!)}'} y ya no vive en la sede. Su ficha queda guardada como recuerdo.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, height: 1.4, color: c.textoSecundario),
                          ),
                          const SizedBox(height: 18),
                          Presionable(
                            child: SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton(
                                onPressed: () => Navigator.pop(context),
                                style: FilledButton.styleFrom(backgroundColor: c.acento, foregroundColor: c.sobreAcento, shape: Formas.squircle(16)),
                                child: const Text('Volver', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _verFicha = true),
                            child: Text('Ver su ficha de todos modos', style: TextStyle(color: c.textoSecundario, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    ]);
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
        top: MediaQuery.paddingOf(context).top + 14,
        left: 6,
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

/// Acciones fuera del área desplazable: siempre quedan ancladas abajo.
class _AccionesPerfil extends StatelessWidget {
  const _AccionesPerfil({required this.perro});
  final Perro perro;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final cuidados = Cuidados(perro, alimentaciones: Alimentaciones.de(perro.id));
    return Container(
    color: c.fondo,
    padding: EdgeInsets.fromLTRB(12, 8, 12, 16 + MediaQuery.paddingOf(context).bottom),
    child: Column(children: [
      if (cuidados.ultimaComidaEn != null && !perro.adoptado)
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 1), child: Icono(Iconos.clock, size: 15, color: c.textoTenue)),
          const SizedBox(width: 6),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Próxima alimentación sugerida: '),
                TextSpan(text: cuidados.textoProximaComida, style: TextStyle(fontWeight: FontWeight.w700, color: c.texto)),
              ]),
              style: TextStyle(fontSize: 13, color: c.textoSecundario),
            ),
          ),
        ]),
      ),
      if (perro.adoptado)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: Formas.fondo(c.adoptadoSuave, 16),
          child: Row(children: [
            Icono(Iconos.heart, color: c.adoptadoTexto, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${perro.nombre} ya tiene un hogar. Esta ficha es solo un recuerdo.',
                style: TextStyle(color: c.adoptadoTexto, fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
        )
      else
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
      if (!perro.adoptado) ...[
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
                  builder: (_) => EstadoMedico(perro: perro, actualizado: perro.actualizadoEn == null ? null : _fechaRelativa(perro.actualizadoEn)),
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
              onPressed: () => abrir(context, Foro.ruta(idPerro: perro.id, nombrePerro: perro.nombre)),
              icon: Icono(Iconos.messageCircle, color: c.sobreTonal, size: 28),
              label: Text('Foro', style: TextStyle(color: c.sobreTonal, fontSize: 20)),
            ),
          ),
          ),
        ),
      ]),
      ],
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
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 110),
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
    final sinDato = !tieneDato(caracter);
    final c = context.colores;
    final (fondo, color) = c.tono(amable ? Gravedad.bien : sinDato ? Gravedad.neutro : Gravedad.revisar);
    return Card(color: fondo, elevation: 0, child: ConstrainedBox(constraints: const BoxConstraints(minHeight: 110), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icono(amable ? Iconos.heart : sinDato ? Iconos.circleHelp : Iconos.triangleAlert, size: 50, color: color), Text(sinDato ? 'Carácter\nsin registrar' : caracter, maxLines: sinDato ? 2 : 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: sinDato ? 13 : 16, height: 1.2, fontWeight: FontWeight.w500, color: color))])));
  }
}

String _razaYEdad(Perro perro) {
  final datos = [perro.raza, perro.edad].where(tieneDato);
  return datos.isEmpty ? 'Raza y edad sin registrar' : datos.join(' · ');
}

String _fechaRelativa(dynamic timestamp) {
  if (timestamp == null) return 'sin registro';
  final diferencia = DateTime.now().difference(timestamp.toDate());
  if (diferencia.inMinutes < 60) return 'hace ${diferencia.inMinutes} min';
  if (diferencia.inHours < 24) return 'hace ${diferencia.inHours} h';
  return 'hace ${diferencia.inDays} ${diferencia.inDays == 1 ? 'día' : 'días'}';
}

class _BotonEsquina extends StatelessWidget {
  const _BotonEsquina({required this.perro});
  final Perro perro;

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: PermisosUsuario.esAdmin(),
        builder: (context, admin) {
          if (admin.data == true) {
            return _IconoFlotante(
              icono: Iconos.pencil,
              onTap: () => avisar(context, 'Por ahora la ficha se edita desde la base de datos de Firebase.', icono: Iconos.pencil),
            );
          }
          if (perro.adoptado || !admin.hasData) return const SizedBox.shrink();
          final c = context.colores;
          return Presionable(
            child: Material(
              color: Color.alphaBlend(c.adoptadoSuave, c.superficie),
              elevation: 2,
              shape: StadiumBorder(side: BorderSide(color: c.adoptadoTexto.withValues(alpha: .25))),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => mostrarAdopcion(context, nombrePerro: perro.nombre),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icono(Iconos.heart, size: 18, color: c.adoptadoTexto),
                    const SizedBox(width: 6),
                    Text('Adoptar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.adoptadoTexto)),
                  ]),
                ),
              ),
            ),
          );
        },
      );
}

Future<void> _cambiarSeguimiento(BuildContext context, Perro perro, String uid, bool seguido) async {
  try {
    await PerrosRepository().actualizarSeguimiento(idPerro: perro.id, uid: uid, seguir: !seguido);
    if (!context.mounted) return;
    avisar(
      context,
      seguido
          ? 'Dejaste de seguir a ${perro.nombre}. Ya no te llegarán sus novedades.'
          : 'Ahora sigues a ${perro.nombre}. Te avisaremos en la campana si tiene una emergencia o si lleva mucho sin comer o sin agua.',
      icono: Iconos.pawPrint,
      color: seguido ? null : context.colores.acento,
    );
  } catch (_) {
    if (context.mounted) avisar(context, 'No se pudo actualizar el seguimiento. Revisa tu conexión.', tipo: TipoAviso.error);
  }
}
