import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/services/moderacion.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/avatar_usuario.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';
import 'package:guaurdados_oficial/widgets/tarjeta_emergencia.dart';

class Reportes extends StatefulWidget {
  const Reportes({super.key});

  @override
  State<Reportes> createState() => _ReportesState();
}

class _ReportesState extends State<Reportes> {
  late final _pendientes = Moderacion.observarPendientes();

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
      appBar: AppBar(title: Text('Reportes', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700).display)),
      body: StreamBuilder<List<ReportesDeContenido>>(
        stream: _pendientes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _Vacio(icono: Iconos.wifiOff, titulo: 'No se pudieron cargar', texto: 'Revisa tu conexión e inténtalo de nuevo.');
          }
          if (!snapshot.hasData) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, _) => const BloqueEsqueleto(alto: 170, radio: 18),
            );
          }
          final grupos = snapshot.data!;
          if (grupos.isEmpty) {
            return const _Vacio(icono: Iconos.shieldCheck, titulo: 'No hay reportes pendientes', texto: 'Cuando alguien reporte una publicación o un comentario, aparecerá aquí.');
          }
          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + MediaQuery.paddingOf(context).bottom),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: grupos.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) => i == 0
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                    child: Text(
                      'Revisa cada reporte y elimina lo que no cumpla las reglas de convivencia. Quien publicó no sabe quién lo reportó.',
                      style: TextStyle(fontSize: 13.5, height: 1.4, color: c.textoSecundario),
                    ),
                  )
                : Aparicion(
                    indice: (i - 1).clamp(0, 8),
                    child: _TarjetaReporte(key: ValueKey(grupos[i - 1].contenido.ruta), grupo: grupos[i - 1]),
                  ),
          );
        },
      ),
    );
  }
}

class _TarjetaReporte extends StatefulWidget {
  const _TarjetaReporte({super.key, required this.grupo});

  final ReportesDeContenido grupo;

  @override
  State<_TarjetaReporte> createState() => _TarjetaReporteState();
}

class _TarjetaReporteState extends State<_TarjetaReporte> {
  bool _trabajando = false;

  Future<void> _resolver(bool eliminar) async {
    final c = context.colores;
    if (eliminar) {
      final confirmado = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('¿Eliminar ${widget.grupo.contenido.tipo.conEste}?'),
          content: const Text('Se borrará para todos y los reportes quedarán cerrados. Esta acción no se puede deshacer.'),
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
      if (confirmado != true || !mounted) return;
    }
    setState(() => _trabajando = true);
    HapticFeedback.lightImpact();
    try {
      await Moderacion.resolver(widget.grupo, eliminarContenido: eliminar);
      if (mounted) {
        avisar(context, eliminar ? (widget.grupo.contenido.tipo == TipoContenido.comentario ? 'Se eliminó el comentario.' : 'Se eliminó la publicación.') : 'Reporte descartado.', tipo: TipoAviso.exito, icono: eliminar ? Iconos.trash2 : Iconos.check);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _trabajando = false);
      avisar(context, 'No se pudo completar. Revisa tu conexión.', tipo: TipoAviso.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final grupo = widget.grupo;
    final contenido = grupo.contenido;
    final cantidad = grupo.reportes.length;
    final detalles = grupo.reportes.where((r) => r.detalle.isNotEmpty).toList();
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: Formas.fondo(c.superficie, 18, sombras: const [BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _Pildora(
            texto: contenido.tipo == TipoContenido.comentario ? 'Comentario' : 'Publicación',
            fondo: c.contenedor,
            color: c.textoSecundario,
          ),
          const SizedBox(width: 6),
          _Pildora(
            texto: cantidad == 1 ? '1 reporte' : '$cantidad reportes',
            fondo: c.emergenciaSuave,
            color: c.emergenciaTexto,
            icono: Iconos.flag,
          ),
          const Spacer(),
          Text(haceCuanto(grupo.ultimo), style: TextStyle(fontSize: 12.5, color: c.textoTenue)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          AvatarUsuario(uid: contenido.idAutor, fotoUrl: contenido.fotoAutor, nombre: contenido.nombreAutor, radio: 17),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              contenido.nombreAutor,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircle(14)),
          child: Text(
            contenido.texto.isEmpty ? 'Sin texto' : contenido.texto,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14.5, height: 1.4, color: contenido.texto.isEmpty ? c.textoTenue : c.texto),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final motivo in grupo.motivos) _Pildora(texto: motivo.texto, fondo: c.advertenciaSuave, color: c.advertenciaTexto),
        ]),
        for (final r in detalles) ...[
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: '${r.nombreReportante}: ', style: const TextStyle(fontWeight: FontWeight.w700)),
              TextSpan(text: r.detalle),
            ]),
            style: TextStyle(fontSize: 13.5, height: 1.4, color: c.textoSecundario),
          ),
        ],
        const SizedBox(height: 6),
        Text(
          'Reportado por ${grupo.reportes.map((r) => r.nombreReportante).toSet().join(', ')}',
          style: TextStyle(fontSize: 12.5, color: c.textoTenue),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _trabajando
              ? SizedBox(
                  key: const ValueKey('trabajando'),
                  height: 46,
                  child: Center(child: SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: c.acento))),
                )
              : Row(key: const ValueKey('acciones'), children: [
                  Expanded(
                    child: Presionable(
                      escala: .97,
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: () => _resolver(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: c.texto,
                            side: BorderSide(color: c.divisor),
                            shape: Formas.squircle(14),
                          ),
                          child: const Text('Descartar', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Presionable(
                      escala: .97,
                      child: SizedBox(
                        height: 46,
                        child: FilledButton.icon(
                          onPressed: () => _resolver(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: c.emergencia,
                            foregroundColor: c.sobreAcento,
                            shape: Formas.squircle(14),
                          ),
                          icon: const Icono(Iconos.trash2, size: 18),
                          label: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ]),
        ),
      ]),
    );
  }
}

class _Pildora extends StatelessWidget {
  const _Pildora({required this.texto, required this.fondo, required this.color, this.icono});

  final String texto;
  final Color fondo;
  final Color color;
  final IconData? icono;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: Formas.fondo(fondo, 9),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icono != null) ...[Icono(icono!, size: 13, color: color), const SizedBox(width: 4)],
      Text(texto, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ]),
  );
}

class _Vacio extends StatelessWidget {
  const _Vacio({required this.icono, required this.titulo, required this.texto});

  final IconData icono;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Aparicion(
            child: Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(color: c.contenedor, shape: Formas.squircle(20)),
              child: Center(child: Icono(icono, size: 30, color: c.textoSecundario)),
            ),
          ),
          const SizedBox(height: 14),
          Aparicion(indice: 1, child: Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700).display)),
          const SizedBox(height: 4),
          Aparicion(indice: 2, child: Text(texto, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: c.textoSecundario))),
        ]),
      ),
    );
  }
}
