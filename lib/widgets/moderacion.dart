import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/services/cuidados.dart';
import 'package:guaurdados_oficial/services/moderacion.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/avatar_usuario.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:guaurdados_oficial/widgets/campo.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

enum _Accion { reportar, bloquear, eliminar }

Future<void> mostrarOpcionesContenido(
  BuildContext context, {
  required ContenidoReportable contenido,
  required bool propio,
  required bool puedeEliminar,
  Future<void> Function()? eliminar,
}) async {
  final accion = await mostrarHoja<_Accion>(
    context,
    builder: (context) {
      final c = context.colores;
      final tipo = contenido.tipo.texto;
      final opciones = <Widget>[
        if (!propio) ...[
          _Opcion(
            icono: Iconos.flag,
            titulo: 'Reportar $tipo',
            subtitulo: 'Revisaremos si cumple las reglas de convivencia.',
            alTocar: () => Navigator.of(context).pop(_Accion.reportar),
          ),
          _Opcion(
            icono: Iconos.ban,
            titulo: 'Bloquear a ${contenido.nombreAutor}',
            subtitulo: 'Dejarás de ver sus publicaciones y comentarios.',
            alTocar: () => Navigator.of(context).pop(_Accion.bloquear),
          ),
        ],
        if (puedeEliminar && eliminar != null)
          _Opcion(
            icono: Iconos.trash2,
            titulo: 'Eliminar $tipo',
            color: c.emergenciaTexto,
            alTocar: () => Navigator.of(context).pop(_Accion.eliminar),
          ),
      ];
      return Container(
        decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
        padding: EdgeInsets.fromLTRB(16, 10, 16, 14 + MediaQuery.paddingOf(context).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const _Asa(),
          Material(
            color: c.superficie,
            shape: Formas.squircle(18),
            clipBehavior: Clip.antiAlias,
            child: Column(children: [
              for (var i = 0; i < opciones.length; i++) ...[
                if (i > 0) Divider(height: 1, indent: 56, color: c.divisor),
                opciones[i],
              ],
            ]),
          ),
        ]),
      );
    },
  );
  if (accion == null || !context.mounted) return;
  switch (accion) {
    case _Accion.reportar:
      await reportarContenido(context, contenido);
    case _Accion.bloquear:
      await bloquearUsuario(context, contenido.idAutor, contenido.nombreAutor, fotoUrl: contenido.fotoAutor);
    case _Accion.eliminar:
      await eliminar?.call();
  }
}

Future<void> reportarContenido(BuildContext context, ContenidoReportable contenido) =>
    mostrarHoja<void>(context, builder: (_) => _HojaReporte(contenido: contenido));

Future<bool> bloquearUsuario(BuildContext context, String uid, String nombre, {String? fotoUrl, bool cerrarHoja = false}) async {
  final c = context.colores;
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('¿Bloquear a $nombre?'),
      content: const Text(
        'No verás sus publicaciones ni sus comentarios, y no te llegarán avisos de su actividad en el foro. '
        'No se le avisará.\n\nPuedes deshacerlo en Configuración → Usuarios bloqueados.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: c.emergencia),
          child: const Text('Bloquear'),
        ),
      ],
    ),
  );
  if (confirmado != true || !context.mounted) return false;
  HapticFeedback.mediumImpact();
  final guardado = Moderacion.bloquear(uid, nombre, fotoUrl: fotoUrl);
  if (cerrarHoja) {
    final mensajero = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    mensajero.avisar('Bloqueaste a $nombre.', tipo: TipoAviso.exito, icono: Iconos.ban);
  } else {
    avisar(context, 'Bloqueaste a $nombre.', tipo: TipoAviso.exito, icono: Iconos.ban);
  }
  try {
    await guardado.timeout(const Duration(seconds: 15));
  } catch (_) {}
  return true;
}

Future<void> mostrarBloqueados(BuildContext context) => mostrarHoja<void>(context, builder: (_) => const _HojaBloqueados());

class _Asa extends StatelessWidget {
  const _Asa();

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 4,
    margin: const EdgeInsets.only(bottom: 14),
    decoration: Formas.fondo(context.colores.divisor, 2),
  );
}

class _Opcion extends StatelessWidget {
  const _Opcion({required this.icono, required this.titulo, required this.alTocar, this.subtitulo, this.color});

  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final Color? color;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return InkWell(
      onTap: alTocar,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Icono(icono, color: color ?? c.textoSecundario),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color ?? c.texto)),
                if (subtitulo != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitulo!, style: TextStyle(fontSize: 13, color: c.textoSecundario)),
                ],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class _HojaReporte extends StatefulWidget {
  const _HojaReporte({required this.contenido});

  final ContenidoReportable contenido;

  @override
  State<_HojaReporte> createState() => _HojaReporteState();
}

class _HojaReporteState extends State<_HojaReporte> {
  final _detalle = TextEditingController();
  MotivoReporte? _motivo;
  bool _enviando = false;
  ResultadoReporte? _resultado;

  @override
  void dispose() {
    _detalle.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final motivo = _motivo;
    if (motivo == null || _enviando) return;
    FocusScope.of(context).unfocus();
    setState(() => _enviando = true);
    final resultado = await Moderacion.reportar(widget.contenido, motivo, detalle: _detalle.text);
    if (!mounted) return;
    if (resultado == ResultadoReporte.error) {
      setState(() => _enviando = false);
      avisar(context, 'No se pudo enviar el reporte. Revisa tu conexión.', tipo: TipoAviso.error);
      return;
    }
    HapticFeedback.lightImpact();
    setState(() {
      _enviando = false;
      _resultado = resultado;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final medidas = MediaQuery.of(context);
    return Container(
      constraints: BoxConstraints(maxHeight: medidas.size.height - medidas.viewInsets.bottom - medidas.padding.top - 40),
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      padding: EdgeInsets.only(bottom: medidas.viewInsets.bottom),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: Alignment.bottomCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          child: _resultado == null ? _formulario(context) : _gracias(context, _resultado!),
        ),
      ),
    );
  }

  Widget _formulario(BuildContext context) {
    final c = context.colores;
    final contenido = widget.contenido;
    final abajo = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      key: const ValueKey('formulario'),
      padding: EdgeInsets.fromLTRB(18, 10, 18, 16 + (MediaQuery.viewInsetsOf(context).bottom > 0 ? 0 : abajo)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        const Center(child: _Asa()),
        Text('Reportar ${contenido.tipo.texto}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800).display),
        const SizedBox(height: 4),
        Text(
          '¿Por qué no cumple las reglas? ${contenido.nombreAutor} no sabrá quién hizo el reporte.',
          style: TextStyle(fontSize: 14, height: 1.4, color: c.textoSecundario),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          decoration: ShapeDecoration(color: c.contenedor, shape: Formas.squircle(14)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            AvatarUsuario(uid: contenido.idAutor, fotoUrl: contenido.fotoAutor, nombre: contenido.nombreAutor, radio: 14),
            const SizedBox(width: 9),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '${contenido.nombreAutor}: ', style: TextStyle(fontWeight: FontWeight.w700, color: c.texto)),
                  TextSpan(text: contenido.texto),
                ]),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.5, height: 1.4, color: c.textoSecundario),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        for (final (i, motivo) in MotivoReporte.values.indexed)
          Aparicion(
            indice: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: _OpcionMotivo(
                texto: motivo.texto,
                elegido: _motivo == motivo,
                alTocar: () {
                  HapticFeedback.selectionClick();
                  setState(() => _motivo = motivo);
                },
              ),
            ),
          ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: _motivo == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: TextField(
                    controller: _detalle,
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 300,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: decoracionCampo(
                      context,
                      pista: _motivo == MotivoReporte.otro ? 'Cuéntanos qué pasa' : 'Cuéntanos más (opcional)',
                      radio: 16,
                      borde: true,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 10),
        Presionable(
          escala: .97,
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _motivo == null || _enviando ? null : _enviar,
              style: FilledButton.styleFrom(
                backgroundColor: c.acento,
                foregroundColor: c.sobreAcento,
                disabledBackgroundColor: c.contenedor,
                disabledForegroundColor: c.textoTenue,
                shape: Formas.squircle(16),
              ),
              child: _enviando
                  ? SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: c.sobreAcento))
                  : const Text('Enviar reporte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _gracias(BuildContext context, ResultadoReporte resultado) {
    final c = context.colores;
    final contenido = widget.contenido;
    final repetido = resultado == ResultadoReporte.repetido;
    final titulo = repetido ? 'Ya lo habías reportado' : 'Gracias por avisar';
    final texto = switch (resultado) {
      ResultadoReporte.repetido => 'Tenemos tu reporte de ${contenido.tipo.conEste} y lo estamos revisando.',
      ResultadoReporte.pendiente => 'Hay poca señal. Tu reporte se enviará apenas vuelva la conexión y lo revisaremos.',
      _ => 'Revisaremos ${contenido.tipo.conEste} y ${contenido.tipo.pronombre} eliminaremos si no cumple las reglas de convivencia.',
    };
    return Padding(
      key: const ValueKey('gracias'),
      padding: EdgeInsets.fromLTRB(22, 10, 22, 18 + MediaQuery.paddingOf(context).bottom),
      child: ValueListenableBuilder<Map<String, UsuarioBloqueado>>(
        valueListenable: Moderacion.bloqueados,
        builder: (context, bloqueados, _) {
          final yaBloqueado = bloqueados.containsKey(contenido.idAutor);
          return Column(mainAxisSize: MainAxisSize.min, children: [
            const _Asa(),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: .6, end: 1),
              duration: const Duration(milliseconds: 520),
              curve: Curves.elasticOut,
              builder: (context, escala, child) => Transform.scale(scale: escala, child: child),
              child: Container(
                width: 68,
                height: 68,
                decoration: ShapeDecoration(color: c.exitoSuave, shape: Formas.squircle(22)),
                child: Center(child: Icono(Iconos.shieldCheck, size: 32, color: c.exitoTexto)),
              ),
            ),
            const SizedBox(height: 14),
            Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800).display),
            const SizedBox(height: 8),
            Text(texto, textAlign: TextAlign.center, style: TextStyle(fontSize: 15, height: 1.45, color: c.textoSecundario)),
            const SizedBox(height: 20),
            if (!yaBloqueado) ...[
              Presionable(
                escala: .97,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () => bloquearUsuario(
                      context,
                      contenido.idAutor,
                      contenido.nombreAutor,
                      fotoUrl: contenido.fotoAutor,
                      cerrarHoja: true,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: c.emergenciaTexto,
                      side: BorderSide(color: c.divisor),
                      shape: Formas.squircle(16),
                    ),
                    icon: const Icono(Iconos.ban, size: 20),
                    label: Text('Bloquear también a ${contenido.nombreAutor}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Presionable(
              escala: .97,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(backgroundColor: c.acento, foregroundColor: c.sobreAcento, shape: Formas.squircle(16)),
                  child: const Text('Listo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _OpcionMotivo extends StatelessWidget {
  const _OpcionMotivo({required this.texto, required this.elegido, required this.alTocar});

  final String texto;
  final bool elegido;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final forma = Formas.squircle(16, lado: BorderSide(color: elegido ? c.acento : c.divisor, width: elegido ? 1.6 : 1));
    return Semantics(
      button: true,
      selected: elegido,
      child: Presionable(
        escala: .98,
        child: Material(
          color: elegido ? Color.alphaBlend(c.acento.withValues(alpha: .1), c.superficie) : c.superficie,
          shape: forma,
          child: InkWell(
            customBorder: forma,
            onTap: alTocar,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      texto,
                      style: TextStyle(fontSize: 15, fontWeight: elegido ? FontWeight.w700 : FontWeight.w500, color: c.texto),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: ShapeDecoration(
                      color: elegido ? c.acento : Colors.transparent,
                      shape: CircleBorder(side: BorderSide(color: elegido ? c.acento : c.textoTenue, width: 1.6)),
                    ),
                    child: elegido ? Center(child: Icono(Iconos.check, size: 14, color: c.sobreAcento)) : null,
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HojaBloqueados extends StatelessWidget {
  const _HojaBloqueados();

  Future<void> _desbloquear(BuildContext context, UsuarioBloqueado usuario) async {
    HapticFeedback.lightImpact();
    try {
      await Moderacion.desbloquear(usuario.uid).timeout(const Duration(seconds: 15));
      if (context.mounted) avisar(context, 'Desbloqueaste a ${usuario.nombre}.', tipo: TipoAviso.exito);
    } catch (_) {
      if (context.mounted) avisar(context, 'No se pudo desbloquear. Revisa tu conexión.', tipo: TipoAviso.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final medidas = MediaQuery.of(context);
    return Container(
      constraints: BoxConstraints(minHeight: medidas.size.height * .4, maxHeight: medidas.size.height * .75),
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 14 + medidas.padding.bottom),
      child: ValueListenableBuilder<Map<String, UsuarioBloqueado>>(
        valueListenable: Moderacion.bloqueados,
        builder: (context, bloqueados, _) {
          final lista = bloqueados.values.toList()
            ..sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));
          return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Center(child: _Asa()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('Usuarios bloqueados', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800).display),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'No ves sus publicaciones ni sus comentarios. No saben que los bloqueaste.',
                style: TextStyle(fontSize: 14, height: 1.4, color: c.textoSecundario),
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: lista.isEmpty
                    ? Padding(
                        key: const ValueKey('vacio'),
                        padding: const EdgeInsets.symmetric(vertical: 28),
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: ShapeDecoration(color: c.contenedor, shape: Formas.squircle(20)),
                            child: Center(child: Icono(Iconos.userX, size: 30, color: c.textoSecundario)),
                          ),
                          const SizedBox(height: 12),
                          Text('No has bloqueado a nadie', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700).display),
                          const SizedBox(height: 4),
                          Text(
                            'Puedes bloquear a alguien desde el menú ⋯ de sus publicaciones o comentarios.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: c.textoSecundario),
                          ),
                        ]),
                      )
                    : Material(
                        key: const ValueKey('lista'),
                        color: c.superficie,
                        shape: Formas.squircle(18),
                        clipBehavior: Clip.antiAlias,
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: lista.length,
                          separatorBuilder: (_, _) => Divider(height: 1, indent: 64, color: c.divisor),
                          itemBuilder: (context, i) {
                            final usuario = lista[i];
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                              child: Row(children: [
                                AvatarUsuario(uid: usuario.uid, fotoUrl: usuario.fotoUrl, nombre: usuario.nombre, radio: 19),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(
                                      usuario.nombre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
                                    ),
                                    if (usuario.en != null)
                                      Text('Desde el ${fechaLarga(usuario.en!)}', style: TextStyle(fontSize: 12.5, color: c.textoTenue)),
                                  ]),
                                ),
                                const SizedBox(width: 8),
                                Presionable(
                                  child: FilledButton(
                                    onPressed: () => _desbloquear(context, usuario),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: c.contenedor,
                                      foregroundColor: c.texto,
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      minimumSize: const Size(0, 38),
                                      shape: Formas.squircle(12),
                                    ),
                                    child: const Text('Desbloquear', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ]),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
