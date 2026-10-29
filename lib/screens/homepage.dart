import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/imagen_remota.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/screens/camara.dart';
import 'package:guaurdados_oficial/screens/perfilperro.dart';
import 'package:guaurdados_oficial/screens/reportar_emergencia.dart';
import 'package:guaurdados_oficial/services/novedades_descartadas.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/app_colors.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/logo.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';
import 'foro.dart';
import 'package:guaurdados_oficial/screens/perfilusuario.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key, PerrosRepository? perrosRepository})
      : _repository = perrosRepository;

  final PerrosRepository? _repository;

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late final PerrosRepository repository = widget._repository ?? PerrosRepository();
  final uid = FirebaseAuth.instance.currentUser?.uid;
  late final NovedadesDescartadas _descartadas = NovedadesDescartadas(uid ?? '');
  late final Stream<List<Perro>> _perros = repository.observarPerros();
  late final Stream<List<Perro>> _novedadesPerros = repository.observarNovedadesSeguidos(uid ?? '');
  late final Stream<List<Map<String, dynamic>>> _novedadesForo = repository.observarPublicacionesForoSeguidos(uid ?? '');

  @override
  void initState() {
    super.initState();
    _descartadas.cargar().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;

    return Scaffold(
      backgroundColor: c.fondoCalido,
      appBar: AppBar(
        toolbarHeight: 76,
        backgroundColor: c.fondoCalido,
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            const NombreGUAUrdados(ancho: 154),
            const Spacer(),
            StreamBuilder<List<Perro>>(
              stream: _novedadesPerros,
              builder: (context, snapshotPerros) => StreamBuilder<List<Map<String, dynamic>>>(
                stream: _novedadesForo,
                builder: (context, snapshotForo) {
                  final totalNovedades = _armarNovedades(c, snapshotForo.data, _descartadas, uid).length;
                  return _Campana(
                    total: totalNovedades,
                    alTocar: () => mostrarHoja(
                      context,
                      builder: (_) => _HojaNovedades(
                        repository: repository,
                        uid: uid ?? '',
                        descartadas: _descartadas,
                        alDescartar: () => setState(() {}),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 9),
            ElevatedButton(
              onPressed: () => ReportarEmergencia.mostrar(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.emergencia,
                foregroundColor: c.sobreAcento,
                elevation: 3,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: Formas.squircle(20),
              ),
              child: const Text('Emergencia', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Perro>>(
        stream: _perros,
        builder: (context, snapshot) {
          if (snapshot.hasError) return _EstadoError(error: snapshot.error);

          final perros = snapshot.data == null ? null : ([...snapshot.data!]..sort((a, b) => _paraOrdenar(a.nombre).compareTo(_paraOrdenar(b.nombre))));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                child: Row(children: [
                  Expanded(
                    child: Text('Patitas seguidas', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700).display),
                  ),
                  const BotonForo(),
                ]),
              ),
              if (uid != null) _PerrosSeguidos(repository: repository, uid: uid!),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 5),
                child: Text(
                  'Todos los perritos',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700).display,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: perros == null
                      ? const _ListaEsqueleto()
                      : perros.isEmpty
                          ? const Center(child: Text('Aún no hay perros publicados.'))
                          : ListaTodosLosPerros(listaPerros: perros),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const _NavegacionInferior(),
    );
  }
}

class _PerrosSeguidos extends StatelessWidget {
  const _PerrosSeguidos({required this.repository, required this.uid});
  final PerrosRepository repository;
  final String uid;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Perro>>(
        stream: repository.observarPerrosSeguidos(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const _SeguidosEsqueleto();
          if (snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 6),
              child: _MensajeSinSeguidos(),
            );
          }
          final seguidos = [...snapshot.data!]..sort((a, b) {
            final porFecha = (b.actualizadoEn?.millisecondsSinceEpoch ?? 0).compareTo(a.actualizadoEn?.millisecondsSinceEpoch ?? 0);
            return porFecha != 0 ? porFecha : _paraOrdenar(a.nombre).compareTo(_paraOrdenar(b.nombre));
          });
          return ListaPerrosSeguidos(listaPerrosSeguidos: seguidos);
        },
      );
}

class _MensajeSinSeguidos extends StatelessWidget {
  const _MensajeSinSeguidos();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: Formas.fondo(context.colores.superficieSuave, 18),
    child: Row(
      children: [
        Icono(Iconos.pawPrint, size: 28, color: context.colores.acento),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Aún no sigues a ningún perrito', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('Conoce a nuestros perritos y sigue a tus favoritos.', style: TextStyle(fontSize: 11, color: context.colores.textoSecundario)),
            ],
          ),
        ),
      ],
    ),
  );
}

class ListaPerrosSeguidos extends StatelessWidget {
  const ListaPerrosSeguidos({super.key, required this.listaPerrosSeguidos});
  final List<Perro> listaPerrosSeguidos;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 82,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
          scrollDirection: Axis.horizontal,
          itemCount: listaPerrosSeguidos.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => Aparicion(
            indice: index,
            child: Presionable(
              child: _TarjetaPerro(
                perro: listaPerrosSeguidos[index],
                compacta: true,
              ),
            ),
          ),
        ),
      );
}

class ListaTodosLosPerros extends StatelessWidget {
  const ListaTodosLosPerros({super.key, required this.listaPerros});
  final List<Perro> listaPerros;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        itemCount: listaPerros.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemBuilder: (context, index) => Aparicion(
          indice: index,
          child: Presionable(escala: .97, child: _TarjetaPerro(perro: listaPerros[index])),
        ),
      );
}

class _TarjetaPerro extends StatefulWidget {
  const _TarjetaPerro({required this.perro, this.compacta = false});
  final Perro perro;
  final bool compacta;

  @override
  State<_TarjetaPerro> createState() => _TarjetaPerroState();
}

class _TarjetaPerroState extends State<_TarjetaPerro> {
  final _claveFoto = GlobalKey();

  Perro get perro => widget.perro;
  bool get compacta => widget.compacta;

  void _abrirPerfil() {
    final caja = _claveFoto.currentContext?.findRenderObject() as RenderBox?;
    final origen = caja == null ? null : caja.localToGlobal(Offset.zero) & caja.size;
    Navigator.push(context, PerfilPerro.ruta(perro, origenFoto: origen, radioOrigen: compacta ? 20 : 10));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final contenido = compacta ? _contenidoCompacto() : _contenidoLista(c);
    final forma = Formas.squircle(compacta ? 16 : 18);
    return Material(
      color: c.superficieSuave,
      shape: forma,
      child: InkWell(
        customBorder: forma,
        onTap: _abrirPerfil,
        child: SizedBox(
          width: compacta ? 152 : double.infinity,
          height: compacta ? 64 : 88,
          child: Padding(
            padding: EdgeInsets.all(compacta ? 10 : 12),
            child: contenido,
          ),
        ),
      ),
    );
  }

  Widget _contenidoCompacto() {
    final c = context.colores;
    final estado = perro.estadoResumen;
    final sinEstado = estado.toLowerCase() == 'sin estado';
    final saludable = estado.toLowerCase() == 'saludable';
    final color = sinEstado
        ? c.neutroTexto
        : saludable
            ? c.exitoTexto
            : c.advertenciaTexto;
    return Row(children: [
      _FotoPerro(key: _claveFoto, perro: perro, size: 40, circular: true),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(perro.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Row(children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(estado,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
              ),
            ]),
          ],
        ),
      ),
    ]);
  }

  Widget _contenidoLista(ColoresApp c) => Row(
        children: [
          _FotoPerro(key: _claveFoto, perro: perro, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(perro.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Row(children: [
                  Icono(Iconos.clock, size: 13, color: c.textoTenue),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(_fechaRelativa(perro.actualizadoEn),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: c.textoSecundario)),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _EtiquetaEstado(estado: perro.estadoResumen),
          Icono(Iconos.chevronRight, color: c.divisor),
        ],
      );
}

class _FotoPerro extends StatelessWidget {
  const _FotoPerro({super.key, required this.perro, required this.size, this.circular = false});
  final Perro perro;
  final double size;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final image = perro.fotoUrl.isNotEmpty
        ? ImagenRemota(url: perro.fotoUrl, fit: BoxFit.cover, alignment: perro.encuadre, cargando: BloqueEsqueleto(circular: circular, radio: 10), error: _sinImagen(c))
        : perro.imagenAsset.isNotEmpty
            ? Image.asset('fotos/${perro.imagenAsset}', fit: BoxFit.cover, alignment: perro.encuadre, errorBuilder: (_, _, _) => _sinImagen(c))
            : _sinImagen(c);
    return SizedBox(
      width: size,
      height: size,
      child: circular
          ? ClipOval(child: image)
          : ClipRSuperellipse(borderRadius: BorderRadius.circular(10), child: image),
    );
  }

  Widget _sinImagen(ColoresApp c) => ColoredBox(
        color: c.contenedor,
        child: Icono(Iconos.pawPrint, color: c.textoTenue),
      );
}

class _EtiquetaEstado extends StatelessWidget {
  const _EtiquetaEstado({required this.estado});
  final String estado;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final saludable = estado.toLowerCase() == 'saludable';
    final sinEstado = estado.toLowerCase() == 'sin estado';
    final color = sinEstado
        ? c.neutroTexto
        : saludable
            ? c.exitoTexto
            : c.advertenciaTexto;
    final fondo = sinEstado
        ? c.divisor
        : saludable
            ? c.exitoSuave
            : c.advertenciaSuave;
    final texto = saludable ? estado : estado == 'Sin estado' ? estado : 'Revisar';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: Formas.fondo(fondo, 18),
      child: Text(texto, maxLines: 1, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _SeguidosEsqueleto extends StatelessWidget {
  const _SeguidosEsqueleto();

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 82,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, _) => Container(
            width: 152,
            padding: const EdgeInsets.all(10),
            decoration: Formas.fondo(context.colores.superficieSuave, 16),
            child: const Row(children: [
              BloqueEsqueleto(ancho: 40, alto: 40, circular: true),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BloqueEsqueleto(ancho: 70, alto: 13),
                    SizedBox(height: 6),
                    BloqueEsqueleto(ancho: 50, alto: 10),
                  ],
                ),
              ),
            ]),
          ),
        ),
      );
}

class _ListaEsqueleto extends StatelessWidget {
  const _ListaEsqueleto();

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 6,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, _) => Container(
          height: 88,
          padding: const EdgeInsets.all(12),
          decoration: Formas.fondo(context.colores.superficieSuave, 18),
          child: const Row(children: [
            BloqueEsqueleto(ancho: 52, alto: 52, radio: 10),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BloqueEsqueleto(ancho: 110, alto: 16),
                  SizedBox(height: 8),
                  BloqueEsqueleto(ancho: 80, alto: 12),
                ],
              ),
            ),
            SizedBox(width: 8),
            BloqueEsqueleto(ancho: 72, alto: 28, radio: 14),
          ]),
        ),
      );
}

String _paraOrdenar(String nombre) {
  const tildes = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n~'};
  return nombre.toLowerCase().split('').map((letra) => tildes[letra] ?? letra).join();
}

String _fechaRelativa(dynamic timestamp) {
  if (timestamp == null) return 'Sin actualizaciones';
  final difference = DateTime.now().difference(timestamp.toDate());
  if (difference.inMinutes < 1) return 'Hace unos instantes';
  if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
  if (difference.inHours < 24) return 'Hace ${difference.inHours} h';
  return 'Hace ${difference.inDays} ${difference.inDays == 1 ? 'día' : 'días'}';
}

class _EstadoError extends StatelessWidget {
  const _EstadoError({this.error});
  final Object? error;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('No se pudieron cargar los perros.\n$error', textAlign: TextAlign.center)));
}

class BotonForo extends StatelessWidget {
  const BotonForo({super.key});
  @override
  Widget build(BuildContext context) => Presionable(
        child: SizedBox(
          height: 34,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: context.colores.acento,
              foregroundColor: context.colores.sobreAcento,
              shape: Formas.squircle(14),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              minimumSize: const Size(0, 34),
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Foro())),
            icon: const Icono(Iconos.messageCircle, size: 16),
            label: const Text('Foros', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ),
      );
}

class _NavegacionInferior extends StatelessWidget {
  const _NavegacionInferior();
  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return SizedBox(
        height: 86,
        child: Stack(clipBehavior: Clip.none, alignment: Alignment.topCenter, children: [
          Container(color: c.navegacion),
          Positioned(
            left: 0,
            right: 0,
            top: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  tooltip: 'Inicio',
                  onPressed: () {},
                  icon: Icono(Iconos.house, color: c.acento, size: 32),
                ),
                const SizedBox(width: 48),
                IconButton(
                  tooltip: 'Mi perfil',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PerfilUsuario()),
                  ),
                  icon: Icono(Iconos.user, color: c.textoSecundario, size: 31),
                ),
              ],
            ),
          ),
          Positioned(top: -20, child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Camara()),
              ),
              child: Container(width: 78, height: 78, decoration: BoxDecoration(color: c.acento, shape: BoxShape.circle), child: Icono(Iconos.camera, color: c.sobreAcento, size: 31)))),
        ]),
      );
  }
}

class _Campana extends StatefulWidget {
  const _Campana({required this.total, required this.alTocar});
  final int total;
  final VoidCallback alTocar;

  @override
  State<_Campana> createState() => _CampanaState();
}

class _CampanaState extends State<_Campana> with SingleTickerProviderStateMixin {
  late final AnimationController _meneo = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

  @override
  void didUpdateWidget(_Campana anterior) {
    super.didUpdateWidget(anterior);
    if (widget.total > anterior.total) _meneo.forward(from: 0);
  }

  @override
  void dispose() {
    _meneo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final hay = widget.total > 0;
    return Stack(clipBehavior: Clip.none, children: [
      Presionable(
        child: IconButton.filled(
          tooltip: 'Novedades',
          onPressed: widget.alTocar,
          style: IconButton.styleFrom(backgroundColor: c.superficie, foregroundColor: c.advertencia),
          icon: AnimatedBuilder(
            animation: _meneo,
            builder: (context, campana) {
              final t = _meneo.value;
              return Transform.rotate(
                angle: math.sin(t * math.pi * 6) * (1 - t) * .4,
                alignment: Alignment.topCenter,
                child: campana,
              );
            },
            child: const Icono(Iconos.bell),
          ),
        ),
      ),
      Positioned(
        top: -3,
        right: -3,
        child: AnimatedScale(
          scale: hay ? 1 : 0,
          duration: Duration(milliseconds: hay ? 420 : 220),
          curve: hay ? Curves.easeOutBack : Curves.easeIn,
          child: Container(
            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            alignment: Alignment.center,
            decoration: ShapeDecoration(color: c.emergencia, shape: const StadiumBorder()),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (numero, animacion) => ScaleTransition(scale: animacion, child: numero),
              child: Text(
                '${widget.total}',
                key: ValueKey(widget.total),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.sobreAcento),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _HojaNovedades extends StatefulWidget {
  const _HojaNovedades({required this.repository, required this.uid, required this.descartadas, required this.alDescartar});
  final PerrosRepository repository;
  final String uid;
  final NovedadesDescartadas descartadas;
  final VoidCallback alDescartar;

  @override
  State<_HojaNovedades> createState() => _HojaNovedadesState();
}

class _HojaNovedadesState extends State<_HojaNovedades> with SingleTickerProviderStateMixin {
  late final Stream<List<Perro>> _perros = widget.repository.observarNovedadesSeguidos(widget.uid);
  late final Stream<List<Map<String, dynamic>>> _foro = widget.repository.observarPublicacionesForoSeguidos(widget.uid);
  late final AnimationController _vaciado = AnimationController(vsync: this, duration: const Duration(milliseconds: 560));
  bool _vaciando = false;

  @override
  void dispose() {
    _vaciado.dispose();
    super.dispose();
  }

  void _descartar(_Novedad novedad) {
    HapticFeedback.lightImpact();
    widget.descartadas.descartar({novedad.clave: novedad.version});
    setState(() {});
    widget.alDescartar();
  }

  Future<void> _borrarTodo(List<_Novedad> novedades) async {
    HapticFeedback.mediumImpact();
    setState(() => _vaciando = true);
    await _vaciado.forward(from: 0);
    if (!mounted) return;
    widget.descartadas.descartar({for (final n in novedades) n.clave: n.version});
    setState(() => _vaciando = false);
    widget.alDescartar();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      height: MediaQuery.sizeOf(context).height * .6,
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + MediaQuery.paddingOf(context).bottom),
      child: StreamBuilder<List<Perro>>(
        stream: _perros,
        builder: (context, snapshotPerros) => StreamBuilder<List<Map<String, dynamic>>>(
          stream: _foro,
          builder: (context, snapshotForo) {
            final cargando = !snapshotForo.hasData;
            final novedades = _armarNovedades(c, snapshotForo.data, widget.descartadas, widget.uid);
            final hay = !cargando && novedades.isNotEmpty;

            final Widget contenido;
            if (cargando) {
              contenido = ListView.separated(
                key: const ValueKey('cargando'),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, _) => const BloqueEsqueleto(alto: 64, radio: 16),
              );
            } else if (!hay) {
              contenido = Center(
                key: const ValueKey('vacio'),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Aparicion(child: Icono(Iconos.pawPrint, size: 44, color: c.acento)),
                  const SizedBox(height: 10),
                  Aparicion(
                    indice: 1,
                    child: Text('¡Estás al día con tus perritos!', textAlign: TextAlign.center, style: TextStyle(color: c.textoSecundario)),
                  ),
                ]),
              );
            } else {
              contenido = ListView.separated(
                key: const ValueKey('lista'),
                physics: const BouncingScrollPhysics(),
                itemCount: novedades.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) => _tarjeta(c, novedades[index], index, novedades.length),
              );
            }

            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Center(
                child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: Formas.fondo(c.divisor, 2)),
              ),
              SizedBox(
                height: 44,
                child: Row(children: [
                  Expanded(
                    child: Text('Novedades recientes', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800).display),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (boton, animacion) => FadeTransition(
                      opacity: animacion,
                      child: ScaleTransition(scale: animacion, child: boton),
                    ),
                    child: hay && !_vaciando
                        ? TextButton.icon(
                            key: const ValueKey('borrar'),
                            onPressed: () => _borrarTodo(novedades),
                            icon: Icono(Iconos.trash2, size: 16, color: c.acento),
                            label: Text('Borrar todo', style: TextStyle(color: c.acento, fontWeight: FontWeight.w600)),
                          )
                        : const SizedBox.shrink(),
                  ),
                ]),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: hay
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text('Desliza una novedad hacia un lado para descartarla.', style: TextStyle(fontSize: 12, color: c.textoTenue)),
                      )
                    : const SizedBox(width: double.infinity),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (hijo, animacion) => FadeTransition(
                    opacity: animacion,
                    child: ScaleTransition(scale: Tween(begin: .92, end: 1.0).animate(animacion), child: hijo),
                  ),
                  child: contenido,
                ),
              ),
            ]);
          },
        ),
      ),
    );
  }

  Widget _tarjeta(ColoresApp c, _Novedad n, int index, int total) {
    Widget fondo(Alignment lado) => Container(
      alignment: lado,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: Formas.fondo(c.emergencia.withValues(alpha: .14), 16),
      child: Icono(Iconos.trash2, size: 20, color: c.emergencia),
    );

    Widget tarjeta = Dismissible(
      key: ValueKey(n.clave),
      onDismissed: (_) => _descartar(n),
      background: fondo(Alignment.centerLeft),
      secondaryBackground: fondo(Alignment.centerRight),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: Formas.fondo(c.superficie, 16),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: Formas.fondo(n.color.withValues(alpha: .12), 12),
            child: Icono(n.icono, size: 20, color: n.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n.titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(n.detalle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.textoSecundario)),
            ]),
          ),
        ]),
      ),
    );

    if (_vaciando) {
      final inicio = total <= 1 ? 0.0 : index / (total - 1) * .45;
      final salida = _vaciado.drive(CurveTween(curve: Interval(inicio, inicio + .55, curve: Curves.easeInCubic)));
      tarjeta = AnimatedBuilder(
        animation: salida,
        builder: (context, hijo) => Opacity(
          opacity: 1 - salida.value,
          child: Transform.translate(offset: Offset(salida.value * 140, 0), child: hijo),
        ),
        child: tarjeta,
      );
    }

    return Aparicion(indice: index, child: tarjeta);
  }
}

const _antiguedadMaxima = Duration(days: 7);

List<_Novedad> _armarNovedades(ColoresApp c, List<Map<String, dynamic>>? foro, NovedadesDescartadas descartadas, String? uid) {
  final limite = DateTime.now().subtract(_antiguedadMaxima);
  final novedades = <_Novedad>[];
  for (final f in foro ?? <Map<String, dynamic>>[]) {
    if (uid != null && f['idUsuario'] == uid) continue;
    final crudo = f['fecha'];
    final fecha = crudo is Timestamp ? crudo.toDate() : null;
    if (fecha != null && fecha.isBefore(limite)) continue;
    final clave = 'foro_${f['id']}';
    final version = fecha?.millisecondsSinceEpoch ?? 0;
    if (descartadas.estaDescartada(clave, version)) continue;
    final tipo = f['tipoPublicacion'];
    final usuario = f['nombreUsuario'] ?? 'Alguien';
    final perro = f['nombrePerro'];
    final comentario = '${f['comentario'] ?? ''}'.trim();
    final cuando = fecha == null ? 'Recién' : _fechaRelativa(Timestamp.fromDate(fecha));
    novedades.add(_Novedad(
      clave: clave,
      version: version,
      fecha: fecha,
      icono: tipo == 'alimentacion' ? Iconos.utensils : tipo == 'estado_medico' ? Iconos.stethoscope : Iconos.messageCircle,
      color: tipo == 'alimentacion' ? c.acento : tipo == 'estado_medico' ? c.medico : AppColors.azulAgua,
      titulo: tipo == 'alimentacion'
          ? '$usuario registró alimentación para $perro'
          : tipo == 'estado_medico'
              ? '$usuario actualizó el estado médico de $perro'
              : '$usuario publicó en el foro de $perro',
      detalle: comentario.isEmpty || tipo == 'alimentacion' ? cuando : '"$comentario" · $cuando',
    ));
  }
  novedades.sort((a, b) => b.version.compareTo(a.version));
  return novedades;
}

class _Novedad {
  const _Novedad({required this.clave, required this.version, this.fecha, required this.icono, required this.color, required this.titulo, required this.detalle});
  final String clave;
  final int version;
  final DateTime? fecha;
  final IconData icono;
  final Color color;
  final String titulo;
  final String detalle;
}
