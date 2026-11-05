import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guaurdados_oficial/models/emergencia.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/models/publicacion_foro.dart';
import 'package:guaurdados_oficial/screens/camara.dart';
import 'package:guaurdados_oficial/services/emergencias_repository.dart';
import 'package:guaurdados_oficial/services/notificaciones_service.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';
import 'package:guaurdados_oficial/services/gamificacion_service.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/app_colors.dart';
import 'package:guaurdados_oficial/theme/app_theme.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/widgets/imagen_remota.dart';
import 'package:guaurdados_oficial/widgets/avatar_usuario.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';
import 'package:guaurdados_oficial/widgets/selector_avatar.dart';
import 'package:guaurdados_oficial/widgets/tarjeta_emergencia.dart';

import 'configuracion.dart';
import 'foro.dart';
import 'iniciar_sesion.dart';
import 'perfilperro.dart';
import 'package:guaurdados_oficial/services/rutas.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({super.key});

  @override
  State<PerfilUsuario> createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser?.reload().catchError((_) {});
    WidgetsBinding.instance.addPostFrameCallback((_) => GamificacionService.evaluarSeguimientoYRacha(context));
  }

  @override
  Widget build(BuildContext context){
    final c = context.colores;
    return AppTheme.conBotonCamara(context, Scaffold(
      backgroundColor: c.fondo,
      bottomNavigationBar: const _BarraPerfilUsuario(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            initialData: FirebaseAuth.instance.currentUser,
            builder: (context, snapshot) {
              final usuario = snapshot.data;
              final nombre = usuario?.displayName;
              final tieneNombre = nombre != null && nombre.isNotEmpty;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: enCascada([
                  Center(child: _Avatar(uid: usuario?.uid, foto: usuario?.photoURL)),
                  const SizedBox(height: 14),
                  Text(
                    tieneNombre ? nombre : 'Nombre de usuario',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800).display,
                  ),
                  if (usuario?.email != null)
                    Text(usuario!.email!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.textoTenue)),
                  const SizedBox(height: 22),

                  if (usuario != null) _ResumenUsuario(uid: usuario.uid),

                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: c.divisor)),
                  _Opcion(
                    icono: Iconos.settings,
                    texto: 'Configuración',
                    alTocar: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Configuracion())),
                  ),
                  _Opcion(
                    icono: Iconos.logOut,
                    texto: 'Cerrar sesión',
                    color: c.emergencia,
                    alTocar: () => _cerrarSesion(context),
                  ),
                ]),
              );
            },
          ),
        ),
      ),
    ));
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      try {
        await NotificacionesService.desregistrar().timeout(const Duration(seconds: 3));
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const IniciarSesion()),
        (route) => false,
      );
    } catch (_) {
      if (context.mounted) {
        avisar(context, 'No se pudo cerrar la sesión. Revisa tu conexión.', tipo: TipoAviso.error);
      }
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.uid, this.foto});
  final String? uid;
  final String? foto;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Semantics(
      button: true,
      label: 'Cambiar foto de perfil',
      child: Presionable(
        child: GestureDetector(
          onTap: () => elegirFotoPerfil(context),
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              width: 104,
              height: 104,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: c.superficie,
                shape: BoxShape.circle,
                boxShadow: const [BoxShadow(color: Color(0x1f000000), blurRadius: 14, offset: Offset(0, 4))],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (hijo, animacion) => FadeTransition(
                  opacity: animacion,
                  child: ScaleTransition(scale: Tween(begin: .85, end: 1.0).animate(animacion), child: hijo),
                ),
                child: AvatarUsuario(key: ValueKey(foto), uid: uid, fotoUrl: foto, radio: 48),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 2,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: c.acento, shape: BoxShape.circle, border: Border.all(color: c.fondo, width: 3)),
                child: Icono(Iconos.pencil, size: 14, color: c.sobreAcento),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  const _Estadistica({required this.icono, required this.color, required this.valor, required this.etiqueta});
  final IconData icono;
  final Color color;
  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Semantics(
      label: '$etiqueta: $valor',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Icono(icono, color: color, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(valor, maxLines: 1, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800).display),
            ),
          ),
        ]),
        const SizedBox(height: 2),
        FittedBox(fit: BoxFit.scaleDown, child: Text(etiqueta, maxLines: 1, style: TextStyle(fontSize: 12, color: c.textoTenue))),
      ]),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 24, 2, 10),
    child: Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700).display),
  );
}

class _PerrosSeguidos extends StatelessWidget {
  const _PerrosSeguidos({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return StreamBuilder<List<Perro>>(
      stream: PerrosRepository().observarPerrosSeguidos(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: 96,
            child: Row(children: [
              for (var i = 0; i < 4; i++)
                const Padding(padding: EdgeInsets.only(right: 14), child: BloqueEsqueleto(ancho: 64, alto: 64, circular: true)),
            ]),
          );
        }
        final perros = snapshot.data!;
        if (perros.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: Formas.fondo(c.superficie, 16),
            child: Row(children: [
              Icono(Iconos.pawPrint, color: c.acento),
              const SizedBox(width: 10),
              Expanded(child: Text('Aún no sigues a ningún perrito. Toca "Seguir" en su perfil.', style: TextStyle(fontSize: 13, color: c.textoSecundario))),
            ]),
          );
        }
        return SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: perros.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) => Presionable(
              child: GestureDetector(
                onTap: () => abrir(context, PerfilPerro.ruta(perros[i])),
                child: SizedBox(
                  width: 68,
                  child: Column(children: [
                    _FotoCircular(perro: perros[i]),
                    const SizedBox(height: 6),
                    Text(perros[i].nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FotoCircular extends StatelessWidget {
  const _FotoCircular({required this.perro});
  final Perro perro;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final vacio = ColoredBox(color: c.contenedor, child: Icono(Iconos.pawPrint, color: c.textoTenue));
    final imagen = perro.fotoUrl.isNotEmpty
        ? ImagenRemota(url: perro.fotoUrl, fit: BoxFit.cover, alignment: perro.encuadre, cargando: const BloqueEsqueleto(circular: true), error: vacio)
        : perro.imagenAsset.isNotEmpty
            ? Image.asset('fotos/${perro.imagenAsset}', fit: BoxFit.cover, alignment: perro.encuadre, errorBuilder: (_, _, _) => vacio)
            : vacio;
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: c.acento, shape: BoxShape.circle),
      child: ClipOval(child: imagen),
    );
  }
}

class _Actividad extends StatelessWidget {
  const _Actividad({required this.icono, required this.color, required this.titulo, required this.cuando, required this.alTocar});
  final IconData icono;
  final Color color;
  final String titulo;
  final String cuando;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final forma = Formas.squircle(16);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Presionable(
        escala: .97,
        child: Material(
          color: c.superficie,
          shape: forma,
          child: InkWell(
            customBorder: forma,
            onTap: alTocar,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: Formas.fondo(color.withValues(alpha: .12), 12),
                  child: Icono(icono, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(cuando, style: TextStyle(fontSize: 12, color: c.textoTenue)),
                  ]),
                ),
                Icono(Iconos.chevronRight, color: c.textoTenue, size: 20),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResumenUsuario extends StatelessWidget {
  const _ResumenUsuario({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) => StreamBuilder<ResumenActividadForo>(
    stream: ForoRepository().observarResumenUsuario(uid),
    builder: (context, snapshot) {
      final c = context.colores;
      final resumen = snapshot.data;
      final recientes = resumen?.actividadReciente ?? const <PublicacionForo>[];
      final racha = resumen?.rachaDias;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        IntrinsicHeight(
          child: Row(children: [
          Expanded(
            child: _Estadistica(
              icono: Iconos.pawPrint,
              color: c.acento,
              valor: resumen?.perrosAyudados.toString() ?? '…',
              etiqueta: 'Perros ayudados',
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: c.divisor),
          Expanded(
            child: _Estadistica(
              icono: Iconos.notebookPen,
              color: c.exitoTexto,
              valor: resumen?.registros.toString() ?? '…',
              etiqueta: 'Registros',
            ),
          ),
          VerticalDivider(width: 1, thickness: 1, color: c.divisor),
          Expanded(
            child: _Estadistica(
              icono: Iconos.flame,
              color: c.emergencia,
              valor: racha == null ? '…' : '$racha ${racha == 1 ? 'día' : 'días'}',
              etiqueta: 'Racha activa',
            ),
          ),
          ]),
        ),
        _SeccionGamificacion(uid: uid),
        _MisEmergencias(uid: uid),
        const _TituloSeccion('Patitas que sigues'),
        _PerrosSeguidos(uid: uid),
        const _TituloSeccion('Actividad reciente'),
        if (snapshot.hasError)
          const _ActividadVacia(texto: 'No se pudo cargar tu actividad reciente.')
        else if (!snapshot.hasData)
          for (var i = 0; i < 3; i++)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: BloqueEsqueleto(alto: 64, radio: 16),
            )
        else if (recientes.isEmpty)
          const _ActividadVacia(texto: 'Todavía no tienes actividad registrada.')
        else
          ...recientes.map((publicacion) {
            final tipo = publicacion.tipoPublicacion;
            final esAlimentacion = tipo == 'alimentacion';
            final esMedico = tipo == 'estado_medico';
            final icono = esAlimentacion
                ? Iconos.utensils
                : esMedico
                    ? Iconos.stethoscope
                    : publicacion.esPerritoNuevo
                        ? Iconos.pawPrint
                        : Iconos.messageCircle;
            final color = esAlimentacion
                ? c.acento
                : esMedico
                    ? c.medico
                    : AppColors.azulAgua;
            final titulo = esAlimentacion
                ? 'Registraste alimentación para ${publicacion.nombrePerro}'
                : esMedico
                    ? 'Actualizaste el estado médico de ${publicacion.nombrePerro}'
                    : publicacion.esPerritoNuevo
                        ? 'Avisaste a GUAU de un perrito nuevo'
                        : 'Publicaste en el foro de ${publicacion.nombrePerro}';
            return _Actividad(
              icono: icono,
              color: color,
              titulo: titulo,
              cuando: _fechaActividad(publicacion.creadoEn),
              alTocar: () => abrir(
                context,
                publicacion.esPerritoNuevo ? Foro.ruta() : Foro.ruta(idPerro: publicacion.idPerro, nombrePerro: publicacion.nombrePerro),
              ),
            );
          }),
      ]);
    },
  );

  String _fechaActividad(DateTime? fecha) {
    if (fecha == null) return 'Recién';
    final diferencia = DateTime.now().difference(fecha);
    if (diferencia.inMinutes < 1) return 'Ahora';
    if (diferencia.inHours < 1) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inDays < 1) {
      final horas = diferencia.inHours;
      return 'Hace $horas ${horas == 1 ? 'hora' : 'horas'}';
    }
    final hora = '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    if (diferencia.inDays == 1) return 'Ayer, $hora';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')} · $hora';
  }
}

class _SeccionGamificacion extends StatefulWidget {
  const _SeccionGamificacion({required this.uid});
  final String uid;

  @override
  State<_SeccionGamificacion> createState() => _SeccionGamificacionState();
}

class _SeccionGamificacionState extends State<_SeccionGamificacion> {
  late final _usuario = GamificacionService.streamUsuario(widget.uid);
  late final _seguidos = PerrosRepository().observarPerrosSeguidos(widget.uid);
  late final _resumen = ForoRepository().observarResumenUsuario(widget.uid);

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return StreamBuilder(
      stream: _usuario,
      builder: (context, usuario) => StreamBuilder<List<Perro>>(
        stream: _seguidos,
        builder: (context, seguidos) => StreamBuilder<ResumenActividadForo>(
          stream: _resumen,
          builder: (context, resumen) {
            final datos = usuario.data?.data() ?? const <String, dynamic>{};
            final logros = (datos['logros'] as List<dynamic>?) ?? const [];
            final escaneados = (datos['perros_escaneados'] as List<dynamic>?) ?? const [];
            final avance = {
              GamificacionService.bronce.id: seguidos.data?.length ?? 0,
              GamificacionService.plata.id: escaneados.length,
              GamificacionService.oro.id: resumen.data?.rachaDias ?? 0,
            };
            final ganadas = GamificacionService.insignias.where((i) => logros.contains(i.id)).length;
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Expanded(child: _TituloSeccion('Insignias')),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, right: 2),
                  child: Text('$ganadas de ${GamificacionService.insignias.length}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.textoSecundario)),
                ),
              ]),
              Container(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 14),
                decoration: Formas.fondo(c.superficie, 20),
                child: IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final insignia in GamificacionService.insignias)
                    Expanded(
                      child: _MedallaItem(
                        insignia: insignia,
                        ganada: logros.contains(insignia.id),
                        avance: avance[insignia.id]!.clamp(0, insignia.objetivo),
                      ),
                    ),
                ])),
              ),
            ]);
          },
        ),
      ),
    );
  }
}

class _MedallaItem extends StatelessWidget {
  const _MedallaItem({required this.insignia, required this.ganada, required this.avance});
  final Insignia insignia;
  final bool ganada;
  final int avance;

  static const _apagada = ColorFilter.matrix([
    .53, .43, .04, 0, 0,
    .13, .83, .04, 0, 0,
    .13, .43, .44, 0, 0,
    0, 0, 0, .55, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final medalla = Image.asset(insignia.imagen, width: 64, height: 64);
    return Column(children: [
      ganada ? medalla : ColorFiltered(colorFilter: _apagada, child: medalla),
      const SizedBox(height: 8),
      Text(insignia.nombre, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ganada ? c.texto : c.textoSecundario)),
      const SizedBox(height: 2),
      Text(insignia.meta, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, height: 1.25, color: c.textoTenue)),
      const Spacer(),
      const SizedBox(height: 8),
      if (ganada)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: Formas.fondo(c.exitoSuave, 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icono(Iconos.check, size: 13, color: c.exitoTexto),
            const SizedBox(width: 4),
            Text('Lograda', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.exitoTexto)),
          ]),
        )
      else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(children: [
            ClipRSuperellipse(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: avance / insignia.objetivo),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, valor, _) => LinearProgressIndicator(value: valor, minHeight: 6, color: c.acento, backgroundColor: c.contenedor),
              ),
            ),
            const SizedBox(height: 4),
            Text('$avance de ${insignia.objetivo}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.textoSecundario)),
          ]),
        ),
    ]);
  }
}

class _ActividadVacia extends StatelessWidget {
  const _ActividadVacia({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(texto, style: TextStyle(color: context.colores.textoTenue, fontSize: 13)),
    ),
  );
}

class _Opcion extends StatelessWidget {
  const _Opcion({required this.icono, required this.texto, required this.alTocar, this.color});
  final IconData icono;
  final String texto;
  final VoidCallback alTocar;
  final Color? color;

  @override
  Widget build(BuildContext context) => InkWell(
    customBorder: Formas.squircle(12),
    onTap: alTocar,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(children: [
        Icono(icono, size: 24, color: color ?? context.colores.textoSecundario),
        const SizedBox(width: 12),
        Text(texto, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color)),
      ]),
    ),
  );
}

class _BarraPerfilUsuario extends StatelessWidget {
  const _BarraPerfilUsuario();

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return SizedBox(
    height: (62 + MediaQuery.paddingOf(context).bottom).clamp(86.0, double.infinity),
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(color: c.navegacion),
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                tooltip: 'Inicio',
                onPressed: () => Navigator.pop(context),
                icon: Icono(Iconos.house, color: c.textoSecundario, size: 31),
              ),
              const SizedBox(width: 48),
              Icono(Iconos.user, color: c.acento, size: 31),
            ],
          ),
        ),
        Positioned(
          top: -20,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Camara()),
              ),
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(color: c.acento, shape: BoxShape.circle),
              child: Icono(Iconos.camera, color: c.sobreAcento, size: 31),
            ),
          ),
        ),
      ],
    ),
  );
  }
}

class _MisEmergencias extends StatefulWidget {
  const _MisEmergencias({required this.uid});
  final String uid;

  @override
  State<_MisEmergencias> createState() => _MisEmergenciasState();
}

class _MisEmergenciasState extends State<_MisEmergencias> {
  late final Stream<List<Emergencia>> _emergencias = EmergenciasRepository().observarDeUsuario(widget.uid);

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Emergencia>>(
    stream: _emergencias,
    builder: (context, snapshot) {
      final todas = snapshot.data ?? const <Emergencia>[];
      final visibles = [...todas.where((e) => e.enCurso), ...todas.where((e) => !e.enCurso).take(3)];
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: visibles.isEmpty
            ? const SizedBox(width: double.infinity)
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const _TituloSeccion('Tus emergencias'),
                for (final e in visibles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: TarjetaEmergencia(key: ValueKey(e.id), emergencia: e, propia: true),
                  ),
              ]),
      );
    },
  );
}
