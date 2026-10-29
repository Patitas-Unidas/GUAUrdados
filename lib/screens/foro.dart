import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/models/publicacion_foro.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';
import 'package:guaurdados_oficial/services/perfiles_usuario_repository.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/avatar_usuario.dart';

import 'nuevapublicacion.dart';
import 'package:guaurdados_oficial/screens/reportar_emergencia.dart';

class Foro extends StatelessWidget {
  const Foro({super.key, this.idPerro, this.nombrePerro});

  final String? idPerro;
  final String? nombrePerro;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final usuario = FirebaseAuth.instance.currentUser;
    final publicaciones = ForoRepository().observarPublicaciones(idPerro: idPerro);

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
                              '${snapshot.data?.length ?? 0} actualizaciones',
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
                  onPressed: usuario == null
                      ? null
                      : () async {
                          final publicada = await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => NuevaPublicacion(idPerro: idPerro),
                            ),
                          );
                          if (publicada == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Publicación agregada al foro.')),
                            );
                          }
                        },
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
                    return _EstadoForo(
                      icono: Iconos.messageCircle,
                      mensaje: 'Aún no hay publicaciones.',
                      detalle: 'Sé la primera persona en compartir una novedad.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) => Aparicion(
                      indice: index,
                      child: _TarjetaPublicacion(publicacion: items[index]),
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
  const _TarjetaPublicacion({required this.publicacion});

  final PublicacionForo publicacion;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final esAlimentacion = publicacion.tipoPublicacion == 'alimentacion';
    final esMedico = publicacion.tipoPublicacion == 'estado_medico';
    if (esAlimentacion || esMedico) {
      return _TarjetaActualizacion(publicacion: publicacion, esMedico: esMedico);
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
            Row(
              children: [
                AvatarUsuario(uid: publicacion.idUsuario, fotoUrl: foto, nombre: publicacion.nombreUsuario, radio: 21),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(publicacion.nombreUsuario, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(
                        '@${_usuario(publicacion.nombreUsuario)}  ·  ${_fechaRelativa(publicacion.creadoEn)}',
                        style: TextStyle(fontSize: 12, color: c.textoTenue),
                      ),
                    ],
                  ),
                ),
                Icono(Iconos.ellipsis, color: c.textoSecundario),
              ],
            ),
            const SizedBox(height: 11),
            Text(publicacion.descripcion, style: const TextStyle(fontSize: 15, height: 1.4)),
            const SizedBox(height: 14),
            Divider(height: 1, color: c.divisor),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icono(Iconos.heart, size: 20, color: c.textoTenue),
                  const SizedBox(width: 6),
                  Icono(Iconos.messageCircle, size: 19, color: c.textoTenue),
                  const Spacer(),
                  Icono(Iconos.smile, size: 20, color: c.textoTenue),
                ],
              ),
              ),
          ],
        ),
      ),
    );
  }

  String _usuario(String nombre) => nombre
      .toLowerCase()
      .replaceAll(RegExp(r'\s+'), '');

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
  const _TarjetaActualizacion({required this.publicacion, required this.esMedico});

  final PublicacionForo publicacion;
  final bool esMedico;

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
        : 'Se registró que ${publicacion.nombrePerro} recibió ${publicacion.cantidadComida ?? ''} de ${publicacion.tipoComida ?? 'alimento'} hoy a las ${_hora(publicacion.creadoEn)}.';

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

  String _hora(DateTime? fecha) {
    if (fecha == null) return 'ahora';
    return '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
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
