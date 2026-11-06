import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/models/emergencia.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/models/publicacion_foro.dart';
import 'package:guaurdados_oficial/services/cuidados.dart';
import 'package:guaurdados_oficial/services/emergencias.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';
import 'package:guaurdados_oficial/services/perfiles_usuario_repository.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/avatar_usuario.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:guaurdados_oficial/widgets/estado_perro.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/hoja_comentarios.dart';
import 'package:guaurdados_oficial/widgets/reacciones.dart';
import 'package:guaurdados_oficial/services/permisos_usuario.dart';
import 'package:guaurdados_oficial/widgets/foto_perro.dart';
import 'package:guaurdados_oficial/widgets/tarjeta_emergencia.dart';

import 'nuevapublicacion.dart';
import 'package:guaurdados_oficial/screens/perfilperro.dart';
import 'package:guaurdados_oficial/screens/reportar_emergencia.dart';
import 'package:guaurdados_oficial/services/rutas.dart';

class Foro extends StatefulWidget {
  const Foro({super.key, this.idPerro, this.nombrePerro});

  final String? idPerro;
  final String? nombrePerro;

  static Route<void> ruta({String? idPerro, String? nombrePerro}) => MaterialPageRoute(
        settings: RouteSettings(name: 'foro/${idPerro ?? 'general'}'),
        builder: (_) => Foro(idPerro: idPerro, nombrePerro: nombrePerro),
      );

  @override
  State<Foro> createState() => _ForoState();
}

class _ForoState extends State<Foro> {
  late final Stream<List<PublicacionForo>> _publicaciones = ForoRepository().observarPublicaciones(idPerro: widget.idPerro);
  bool _revisando = false;

  String? get idPerro => widget.idPerro;
  String? get nombrePerro => widget.nombrePerro;

  @override
  void initState() {
    super.initState();
    Emergencias.escuchar();
  }

  Future<void> _nuevaPublicacion() async {
    if (_revisando) return;
    _revisando = true;
    final permiso = await PermisosUsuario.puedePublicar();
    _revisando = false;
    if (!mounted) return;
    if (!permiso.puede) {
      await mostrarEsperaParaPublicar(context, permiso.desde);
      return;
    }
    final publicada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => NuevaPublicacion(idPerro: idPerro)),
    );
    if (publicada == true && mounted) {
      avisar(context, 'Publicación agregada al foro.', tipo: TipoAviso.exito, icono: Iconos.messageCircle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final usuario = FirebaseAuth.instance.currentUser;
    final publicaciones = _publicaciones;

    return Scaffold(
      backgroundColor: c.fondo,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 8),
              child: Row(
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: c.superficie,
                      foregroundColor: c.textoSecundario,
                    ),
                    icon: const Icono(Iconos.chevronLeft),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombrePerro == null ? 'Foros' : 'Foro de $nombrePerro',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700).display,
                        ),
                        if (nombrePerro == null)
                          Text('Novedades de la comunidad', style: TextStyle(color: c.textoTenue, fontSize: 12))
                        else
                          StreamBuilder<List<PublicacionForo>>(
                            stream: publicaciones,
                            builder: (context, snapshot) => Text(
                              '${snapshot.data?.length ?? 0} ${snapshot.data?.length == 1 ? 'actualización' : 'actualizaciones'}',
                              style: TextStyle(color: c.textoTenue, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (idPerro != null)
                    Presionable(
                      child: FilledButton(
                        onPressed: () => ReportarEmergencia.mostrar(
                          context,
                          idPerro: idPerro,
                          nombrePerro: nombrePerro,
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: c.emergencia,
                          foregroundColor: c.sobreAcento,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: Formas.squircle(20),
                        ),
                        child: const Text('Emergencia', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            if (idPerro != null) _SeguidoresForo(idPerro: idPerro!),
            if (idPerro != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(height: 1, color: c.divisor),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Presionable(
                escala: .97,
                child: SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: usuario == null ? null : _nuevaPublicacion,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.superficie,
                    foregroundColor: c.texto,
                    elevation: 1,
                    shape: Formas.squircle(14),
                  ),
                  icon: const Icono(Iconos.plus),
                  label: const Text('Nueva publicación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<PublicacionForo>>(
                stream: publicaciones,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    final error = snapshot.error?.toString().toLowerCase() ?? '';
                    final indiceEnConstruccion = error.contains('failed-precondition') &&
                        error.contains('index') &&
                        error.contains('not ready');
                    debugPrint('Error cargando publicaciones del foro: ${snapshot.error}');
                    return _EstadoForo(
                      icono: Iconos.messageCircle,
                      mensaje: 'No se pudieron cargar las publicaciones.',
                      detalle: indiceEnConstruccion
                          ? 'Firestore está preparando el índice. Vuelve a abrir el foro en un momento.'
                          : 'Revisa la conexión y la configuración de Firestore.',
                    );
                  }
                  if (!snapshot.hasData) {
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(15, 9, 15, 24),
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (_, _) => const BloqueEsqueleto(alto: 150, radio: 16),
                    );
                  }

                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return Column(children: [
                      _EmergenciasForo(idPerro: idPerro, padding: const EdgeInsets.fromLTRB(12, 4, 12, 0)),
                      Expanded(
                        child: _EstadoForo(
                          icono: Iconos.messageCircle,
                          mensaje: 'Aún no hay publicaciones.',
                          detalle: 'Sé la primera persona en compartir una novedad.',
                        ),
                      ),
                    ]);
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length + 1,
                    separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 0 : 4),
                    itemBuilder: (context, index) => index == 0
                        ? _EmergenciasForo(idPerro: idPerro)
                        : Aparicion(
                            indice: index - 1,
                            child: _TarjetaPublicacion(publicacion: items[index - 1], mostrarPerro: idPerro == null),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeguidoresForo extends StatelessWidget {
  const _SeguidoresForo({required this.idPerro});

  final String idPerro;

  @override
  Widget build(BuildContext context) => StreamBuilder<Perro?>(
    stream: PerrosRepository().observarPerro(idPerro),
    builder: (context, snapshot) {
      final ids = snapshot.data?.seguidores.where((id) => id.trim().isNotEmpty).toList() ?? const <String>[];
      if (ids.isEmpty) return const SizedBox(height: 10);
      final visibles = ids.take(10).toList();
      return StreamBuilder<Map<String, PerfilPublicoUsuario>>(
        stream: PerfilesUsuarioRepository().observar(visibles),
        builder: (context, perfilesSnapshot) {
          final perfiles = perfilesSnapshot.data ?? const <String, PerfilPublicoUsuario>{};
          return SizedBox(
            height: 68,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              scrollDirection: Axis.horizontal,
              itemCount: visibles.length + (ids.length > visibles.length ? 1 : 0),
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index >= visibles.length) {
                  return _ChipSeguidor(nombre: '+${ids.length - visibles.length} más');
                }
                final id = visibles[index];
                final perfil = perfiles[id];
                final nombre = perfil?.nombre ?? 'Usuario ${id.substring(0, id.length < 4 ? id.length : 4)}';
                return _ChipSeguidor(nombre: _nombreCorto(nombre), uid: id, fotoUrl: perfil?.fotoUrl);
              },
            ),
          );
        },
      );
    },
  );

  String _nombreCorto(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.length < 2) return partes.isEmpty ? 'Usuario' : partes.first;
    return '${partes.first} ${partes[1][0]}.';
  }
}

class _ChipSeguidor extends StatelessWidget {
  const _ChipSeguidor({required this.nombre, this.uid, this.fotoUrl});

  final String nombre;
  final String? uid;
  final String? fotoUrl;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
      decoration: Formas.fondo(
        c.superficie,
        24,
        sombras: const [BoxShadow(color: Color(0x16000000), blurRadius: 3, offset: Offset(0, 2))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        AvatarUsuario(uid: uid, fotoUrl: fotoUrl, nombre: nombre, radio: 13),
        const SizedBox(width: 7),
        Text(nombre, style: TextStyle(color: c.texto, fontSize: 12, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _TarjetaPublicacion extends StatelessWidget {
  const _TarjetaPublicacion({required this.publicacion, required this.mostrarPerro});

  final PublicacionForo publicacion;
  final bool mostrarPerro;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final esAlimentacion = publicacion.tipoPublicacion == 'alimentacion';
    final esMedico = publicacion.tipoPublicacion == 'estado_medico';
    if (esAlimentacion || esMedico) {
      return _TarjetaActualizacion(publicacion: publicacion, esMedico: esMedico, mostrarPerro: mostrarPerro);
    }
    final foto = publicacion.fotoUsuario;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      color: c.superficie,
      elevation: 2,
      shadowColor: const Color(0x1F000000),
      shape: Formas.squircle(16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (publicacion.esPerritoNuevo) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                decoration: ShapeDecoration(color: c.contenedor, shape: Formas.squircle(14)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icono(Iconos.pawPrint, size: 18, color: c.acento),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      publicacion.avisoRevisado ? 'Aviso de perrito nuevo · revisado por GUAU' : 'Perrito sin registrar · aviso para GUAU',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: c.texto),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
            ] else if (mostrarPerro) ...[
              _PerroDeLaPublicacion(publicacion: publicacion),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                AvatarUsuario(uid: publicacion.idUsuario, fotoUrl: foto, nombre: publicacion.nombreUsuario, radio: 21),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        publicacion.nombreUsuario,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(_fechaRelativa(publicacion.creadoEn), style: TextStyle(fontSize: 12.5, color: c.textoTenue)),
                    ],
                  ),
                ),
                _OpcionesPublicacion(publicacion: publicacion),
              ],
            ),
            const SizedBox(height: 11),
            Text(publicacion.descripcion, style: const TextStyle(fontSize: 15, height: 1.4)),
            if ((publicacion.ubicacion ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                Icono(Iconos.mapPin, size: 16, color: c.textoTenue),
                const SizedBox(width: 6),
                Expanded(child: Text(publicacion.ubicacion!, style: TextStyle(fontSize: 13, color: c.textoSecundario))),
              ]),
            ],
            if (publicacion.avisoRevisado) ...[
              const SizedBox(height: 12),
              _ResultadoAviso(publicacion: publicacion),
            ],
            if (publicacion.admiteReacciones)
              BarraReacciones(publicacion: publicacion, alComentar: () => abrirComentarios(context, publicacion))
            else
              const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  String _fechaRelativa(DateTime? fecha) {
    if (fecha == null) return 'recién publicada';
    final diferencia = DateTime.now().difference(fecha);
    if (diferencia.inMinutes < 1) return 'ahora';
    if (diferencia.inHours < 1) return 'hace ${diferencia.inMinutes} min';
    if (diferencia.inDays < 1) return 'hace ${diferencia.inHours} h';
    if (diferencia.inDays == 1) return 'ayer';
    if (diferencia.inDays < 7) return 'hace ${diferencia.inDays} días';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }
}

class _TarjetaActualizacion extends StatelessWidget {
  const _TarjetaActualizacion({required this.publicacion, required this.esMedico, required this.mostrarPerro});

  final PublicacionForo publicacion;
  final bool esMedico;
  final bool mostrarPerro;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final color = esMedico ? c.medico : c.acento;
    final icono = esMedico ? Iconos.stethoscope : Iconos.utensils;
    final titulo = esMedico
        ? '¡${publicacion.nombreUsuario} actualizó el estado médico!'
        : '¡${publicacion.nombreUsuario} registró una nueva alimentación!';
    final detalle = esMedico
        ? publicacion.procedimiento ?? publicacion.descripcion
        : 'Se registró que ${publicacion.nombrePerro} recibió ${publicacion.cantidadComida ?? ''} de ${publicacion.tipoComida ?? 'alimento'} ${_cuando(publicacion.creadoEn)}.';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
      color: color,
      elevation: 2,
      shadowColor: const Color(0x1F000000),
      shape: Formas.squircle(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icono(icono, color: c.sobreAcento, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (mostrarPerro) ...[
                  _PerroDeLaPublicacion(publicacion: publicacion, sobreColor: true),
                  const SizedBox(height: 10),
                ],
                Text(titulo, style: TextStyle(color: c.sobreAcento, fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 4),
                Text(detalle, style: TextStyle(color: c.sobreAcento, height: 1.35)),
                if (publicacion.descripcion.trim().isNotEmpty &&
                    (esMedico ? publicacion.descripcion != publicacion.procedimiento : true)) ...[
                  const SizedBox(height: 4),
                  Text(publicacion.descripcion, style: TextStyle(color: c.sobreAcento)),
                ],
                const SizedBox(height: 7),
                Text(_fecha(publicacion.creadoEn), style: TextStyle(color: c.sobreAcento.withValues(alpha: .82), fontSize: 12)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  String _fecha(DateTime? fecha) {
    if (fecha == null) return 'Recién actualizado';
    final diferencia = DateTime.now().difference(fecha);
    if (diferencia.inMinutes < 1) return 'Ahora';
    if (diferencia.inHours < 1) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inDays < 1) return 'Hace ${diferencia.inHours} h';
    if (diferencia.inDays == 1) return 'Hace 1 día';
    return 'Hace ${diferencia.inDays} días';
  }

  String _cuando(DateTime? fecha) {
    if (fecha == null) return 'recién';
    final hoy = DateUtils.dateOnly(DateTime.now());
    final dias = hoy.difference(DateUtils.dateOnly(fecha)).inDays;
    final dia = switch (dias) { 0 => 'hoy', 1 => 'ayer', _ => 'el ${fechaLarga(fecha)}' };
    return '$dia a las ${hora(fecha)}';
  }
}

class _EstadoForo extends StatelessWidget {
  const _EstadoForo({required this.icono, required this.mensaje, required this.detalle});

  final IconData icono;
  final String mensaje;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Aparicion(child: Icono(icono, size: 40, color: c.textoTenue)),
            const SizedBox(height: 12),
            Aparicion(indice: 1, child: Text(mensaje, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
            const SizedBox(height: 5),
            Aparicion(indice: 2, child: Text(detalle, textAlign: TextAlign.center, style: TextStyle(color: c.textoSecundario))),
          ],
        ),
      ),
    );
  }
}

Future<void> abrirComentarios(BuildContext context, PublicacionForo publicacion) async {
  final esAdmin = await PermisosUsuario.esAdmin();
  if (!context.mounted) return;
  final repositorio = ForoRepository();
  await mostrarComentarios(
    context,
    idAutor: publicacion.idUsuario,
    nombreAutor: publicacion.nombreUsuario,
    textoPublicacion: publicacion.descripcion,
    comentarios: repositorio.observarComentarios(publicacion),
    esAdmin: esAdmin,
    comentar: (texto) {
      final usuario = FirebaseAuth.instance.currentUser;
      if (usuario == null) return Future.value();
      return repositorio.comentar(publicacion, usuario, texto);
    },
    eliminar: (comentario) async {
      if (!await _confirmarEliminar(context, '¿Eliminar este comentario?')) return;
      try {
        await repositorio.eliminarComentario(publicacion, comentario);
      } catch (_) {
        if (context.mounted) avisar(context, 'No se pudo eliminar el comentario.', tipo: TipoAviso.error);
      }
    },
  );
}

Future<bool> _confirmarEliminar(BuildContext context, String titulo, {String texto = 'Esta acción no se puede deshacer.'}) async {
  final c = context.colores;
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titulo),
      content: Text(texto),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: c.emergencia),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );
  return confirmado == true;
}

Future<void> mostrarEsperaParaPublicar(BuildContext context, DateTime? desde) => mostrarHoja<void>(
      context,
      builder: (context) {
        final c = context.colores;
        return Container(
          decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
          padding: EdgeInsets.fromLTRB(22, 10, 22, 18 + MediaQuery.paddingOf(context).bottom),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: Formas.fondo(c.divisor, 2)),
            Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(color: c.contenedor, shape: Formas.squircle(20)),
              child: Center(child: Icono(Iconos.hourglass, size: 30, color: c.acento)),
            ),
            const SizedBox(height: 14),
            Text('Pronto podrás publicar', textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800).display),
            const SizedBox(height: 8),
            Text(
              desde == null
                  ? 'Las cuentas nuevas pueden publicar en el foro después de 2 días.'
                  : 'Las cuentas nuevas pueden publicar en el foro después de 2 días. Podrás hacerlo desde el ${fechaLarga(desde)} a las ${hora(desde)}.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.45, color: c.textoSecundario),
            ),
            const SizedBox(height: 6),
            Text(
              'Mientras tanto puedes registrar comidas, reportar emergencias, reaccionar y comentar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, height: 1.4, color: c.textoTenue),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(backgroundColor: c.acento, foregroundColor: c.sobreAcento, shape: Formas.squircle(16)),
                child: const Text('Entendido', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ]),
        );
      },
    );

class _OpcionesPublicacion extends StatelessWidget {
  const _OpcionesPublicacion({required this.publicacion});

  final PublicacionForo publicacion;

  Future<void> _abrir(BuildContext context) async {
    final eliminar = await mostrarHoja<bool>(
      context,
      builder: (context) {
        final c = context.colores;
        return Container(
          decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
          padding: EdgeInsets.fromLTRB(16, 10, 16, 14 + MediaQuery.paddingOf(context).bottom),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14), decoration: Formas.fondo(c.divisor, 2)),
            Material(
              color: c.superficie,
              shape: Formas.squircle(18),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: Icono(Iconos.trash2, color: c.emergenciaTexto),
                title: Text('Eliminar publicación', style: TextStyle(color: c.emergenciaTexto, fontWeight: FontWeight.w700)),
                onTap: () => Navigator.of(context).pop(true),
              ),
            ),
          ]),
        );
      },
    );
    if (eliminar != true || !context.mounted) return;
    if (!await _confirmarEliminar(context, '¿Eliminar esta publicación?', texto: 'Se borrará del foro junto con sus reacciones. Esta acción no se puede deshacer.')) return;
    try {
      await ForoRepository().eliminarPublicacion(publicacion);
      if (context.mounted) avisar(context, 'Publicación eliminada.', tipo: TipoAviso.exito, icono: Iconos.trash2);
    } catch (_) {
      if (context.mounted) avisar(context, 'No se pudo eliminar la publicación.', tipo: TipoAviso.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final propia = publicacion.idUsuario == FirebaseAuth.instance.currentUser?.uid;
    return FutureBuilder<bool>(
      future: propia ? Future.value(true) : PermisosUsuario.esAdmin(),
      builder: (context, permitido) => permitido.data == true
          ? IconButton(
              onPressed: () => _abrir(context),
              icon: Icono(Iconos.ellipsis, color: c.textoSecundario),
            )
          : const SizedBox(width: 8),
    );
  }
}

class _ResultadoAviso extends StatelessWidget {
  const _ResultadoAviso({required this.publicacion});

  final PublicacionForo publicacion;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final registrado = publicacion.resultadoAviso == ResultadoAviso.registrado;
    final (fondo, texto) = c.tono(registrado ? Gravedad.bien : Gravedad.neutro);
    final idPerro = publicacion.idPerroAviso ?? '';
    final nota = publicacion.notaGuau ?? '';
    final forma = Formas.squircle(14);
    return StreamBuilder<Perro?>(
      stream: idPerro.isEmpty ? const Stream.empty() : PerrosRepository().observarPerro(idPerro),
      builder: (context, snapshot) {
        final perro = snapshot.data;
        final titulo = switch ((registrado, perro?.nombre)) {
          (true, final String nombre) => 'GUAU lo registró como $nombre',
          (true, _) => 'GUAU registró a este perrito',
          (false, final String nombre) => 'Ya estaba registrado: es $nombre',
          (false, _) => 'Este perrito ya estaba registrado',
        };
        return Presionable(
          escala: .97,
          child: Material(
            color: Color.alphaBlend(fondo, c.superficie),
            shape: forma,
            child: InkWell(
              customBorder: forma,
              onTap: perro == null ? null : () => abrir(context, PerfilPerro.rutaPorId(perro.id)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
                child: Row(children: [
                  if (perro != null)
                    FotoPerroRedonda(perro: perro, tamano: 38)
                  else
                    SizedBox.square(
                      dimension: 38,
                      child: Center(child: Icono(registrado ? Iconos.circleCheck : Iconos.info, size: 22, color: texto)),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(titulo, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: texto)),
                      if (nota.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text('GUAU: $nota', style: TextStyle(fontSize: 13, height: 1.35, color: c.textoSecundario)),
                      ],
                    ]),
                  ),
                  if (perro != null) ...[
                    const SizedBox(width: 6),
                    Icono(Iconos.chevronRight, size: 18, color: texto),
                  ],
                ]),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PerroDeLaPublicacion extends StatelessWidget {
  const _PerroDeLaPublicacion({required this.publicacion, this.sobreColor = false});

  final PublicacionForo publicacion;
  final bool sobreColor;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final texto = sobreColor ? c.sobreAcento : c.textoSecundario;
    final forma = Formas.squircle(14);
    return Presionable(
      escala: .95,
      child: Material(
        color: sobreColor ? c.sobreAcento.withValues(alpha: .18) : c.fondo,
        shape: forma,
        child: InkWell(
          customBorder: forma,
          onTap: publicacion.idPerro.isEmpty
              ? null
              : () => abrir(context, Foro.ruta(idPerro: publicacion.idPerro, nombrePerro: publicacion.nombrePerro)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              StreamBuilder<Perro?>(
                stream: publicacion.idPerro.isEmpty ? const Stream.empty() : PerrosRepository().observarPerro(publicacion.idPerro),
                builder: (context, snapshot) => FotoPerroRedonda(perro: snapshot.data, tamano: 24),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  'Foro de ${publicacion.nombrePerro}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: texto),
                ),
              ),
              const SizedBox(width: 2),
              Icono(Iconos.chevronRight, size: 15, color: texto),
            ]),
          ),
        ),
      ),
    );
  }
}

class _EmergenciasForo extends StatelessWidget {
  const _EmergenciasForo({required this.idPerro, this.padding = EdgeInsets.zero});

  final String? idPerro;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<Emergencia>>(
    valueListenable: Emergencias.recientes,
    builder: (context, _, _) {
      final c = context.colores;
      final lista = Emergencias.enForo(idPerro: idPerro);
      final activas = lista.where((e) => e.enCurso).length;
      return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: lista.isEmpty
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: padding,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
                    child: Row(children: [
                      Icono(Iconos.siren, size: 16, color: c.emergencia),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          lista.length == 1 ? 'Emergencia' : 'Emergencias',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (activas > 0)
                        Text(
                          '$activas en curso',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.emergenciaTexto),
                        ),
                    ]),
                  ),
                  for (final (i, e) in lista.indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Aparicion(
                        indice: i,
                        child: TarjetaEmergencia(key: ValueKey(e.id), emergencia: e, idPerroForo: idPerro),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
                    child: Divider(height: 1, color: c.divisor),
                  ),
                ]),
              ),
      );
    },
  );
}
