import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/models/emergencia.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/screens/foro.dart';
import 'package:guaurdados_oficial/services/cuidados.dart';
import 'package:guaurdados_oficial/services/emergencias_repository.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/foto_perro.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

const tiposEmergencia = <String, IconData>{
  'Problema de salud': Iconos.heartPulse,
  'Pelea': Iconos.zap,
  'Peligro': Iconos.triangleAlert,
  'Otro': Iconos.circleHelp,
};

IconData iconoEmergencia(String tipo) => tiposEmergencia[tipo] ?? Iconos.triangleAlert;

String haceCuanto(DateTime? fecha) {
  if (fecha == null) return 'recién';
  final d = DateTime.now().difference(fecha);
  return d.inMinutes < 1 ? 'recién' : 'hace ${duracion(d)}';
}

extension TonosEmergencia on ColoresApp {
  Color colorEmergencia(EstadoEmergencia estado) => switch (estado) {
        EstadoEmergencia.enCurso => emergencia,
        EstadoEmergencia.resuelta => exitoTexto,
        EstadoEmergencia.veterinario => medico,
        EstadoEmergencia.falsaAlarma => neutroTexto,
      };
}

IconData iconoCierre(EstadoEmergencia estado) => switch (estado) {
      EstadoEmergencia.enCurso => Iconos.siren,
      EstadoEmergencia.resuelta => Iconos.circleCheck,
      EstadoEmergencia.veterinario => Iconos.stethoscope,
      EstadoEmergencia.falsaAlarma => Iconos.circleX,
    };

class TarjetaEmergencia extends StatelessWidget {
  const TarjetaEmergencia({super.key, required this.emergencia, this.idPerroForo, this.propia = false});

  final Emergencia emergencia;
  final String? idPerroForo;
  final bool propia;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final e = emergencia;
    final color = c.colorEmergencia(e.estado);
    final perros = [
      for (var i = 0; i < e.idsPerros.length; i++)
        if (e.idsPerros[i] != idPerroForo) (e.idsPerros[i], i < e.nombresPerros.length ? e.nombresPerros[i] : 'Perrito'),
    ];
    final autor = propia || e.nombreUsuario.isEmpty ? '' : ' por ${e.nombreUsuario}';
    final subtitulo = e.enCurso ? 'Reportada ${haceCuanto(e.creadoEn)}$autor' : 'Cerrada ${haceCuanto(e.cerradaEn)}$autor';

    return Semantics(
      container: true,
      label: 'Emergencia ${e.estado.texto.toLowerCase()}: ${e.tipo}',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color: Color.alphaBlend(color.withValues(alpha: e.enCurso ? .08 : .06), c.superficie),
          shape: Formas.squircle(18, lado: BorderSide(color: color.withValues(alpha: e.enCurso ? .35 : .22))),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: Formas.fondo(color.withValues(alpha: .14), 12),
              child: Icono(iconoEmergencia(e.tipo), size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.tipo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 1),
                Text(subtitulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: c.textoSecundario)),
              ]),
            ),
            const SizedBox(width: 8),
            PildoraEmergencia(e.estado),
          ]),
          if (e.idsPerros.isEmpty && idPerroForo == null) ...[
            const SizedBox(height: 10),
            const _ChipPerro(),
          ] else if (perros.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
              if (idPerroForo != null) Text('Junto a', style: TextStyle(fontSize: 12, color: c.textoSecundario)),
              for (final (id, nombre) in perros) _ChipPerro(id: id, nombre: nombre),
            ]),
          ],
          if (e.ubicacion.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 1), child: Icono(Iconos.mapPin, size: 15, color: c.textoTenue)),
              const SizedBox(width: 6),
              Expanded(child: Text(e.ubicacion, style: TextStyle(fontSize: 13, color: c.texto))),
            ]),
          ],
          if (!e.enCurso && e.nota.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text('"${e.nota}"', style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: c.textoSecundario)),
          ],
          if (propia && e.enCurso) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: Presionable(
                escala: .97,
                child: FilledButton.icon(
                  onPressed: () => cerrarEmergencia(context, e),
                  style: FilledButton.styleFrom(
                    backgroundColor: c.emergencia,
                    foregroundColor: c.sobreAcento,
                    shape: Formas.squircle(14),
                  ),
                  icon: Icono(Iconos.circleCheck, size: 18, color: c.sobreAcento),
                  label: const Text('Cerrar emergencia', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

class PildoraEmergencia extends StatelessWidget {
  const PildoraEmergencia(this.estado, {super.key});
  final EstadoEmergencia estado;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    if (estado == EstadoEmergencia.enCurso) {
      return Container(
        padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
        decoration: Formas.fondo(c.emergencia, 12),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _Pulso(color: c.sobreAcento),
          const SizedBox(width: 6),
          Text('En curso', style: TextStyle(color: c.sobreAcento, fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      );
    }
    final color = c.colorEmergencia(estado);
    final texto = estado == EstadoEmergencia.veterinario ? c.texto : color;
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 5, 9, 5),
      decoration: Formas.fondo(color.withValues(alpha: .15), 12),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icono(iconoCierre(estado), size: 13, color: color),
        const SizedBox(width: 4),
        Text(estado == EstadoEmergencia.veterinario ? 'Veterinario' : estado.texto, style: TextStyle(color: texto, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _Pulso extends StatefulWidget {
  const _Pulso({required this.color});
  final Color color;

  @override
  State<_Pulso> createState() => _PulsoState();
}

class _PulsoState extends State<_Pulso> with SingleTickerProviderStateMixin {
  late final AnimationController _ciclo = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _ciclo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final punto = Container(width: 7, height: 7, decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle));
    if (MediaQuery.disableAnimationsOf(context)) return punto;
    return SizedBox(
      width: 7,
      height: 7,
      child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        AnimatedBuilder(
          animation: _ciclo,
          builder: (context, _) {
            final t = Curves.easeOut.transform(_ciclo.value);
            return Transform.scale(
              scale: 1 + t * 1.6,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: widget.color.withValues(alpha: .55 * (1 - t)), shape: BoxShape.circle),
              ),
            );
          },
        ),
        punto,
      ]),
    );
  }
}

class _ChipPerro extends StatelessWidget {
  const _ChipPerro({this.id, this.nombre});
  final String? id;
  final String? nombre;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final id = this.id;
    final forma = Formas.squircle(14, lado: BorderSide(color: c.divisor));
    final contenido = Padding(
      padding: EdgeInsets.fromLTRB(4, 4, id == null ? 10 : 6, 4),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (id == null)
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: c.contenedor, shape: BoxShape.circle),
            child: Icono(Iconos.pawPrint, size: 13, color: c.textoTenue),
          )
        else
          StreamBuilder<Perro?>(
            stream: PerrosRepository().observarPerro(id),
            builder: (context, snapshot) => FotoPerroRedonda(perro: snapshot.data, tamano: 22),
          ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            nombre ?? 'Perrito sin identificar',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: c.texto),
          ),
        ),
        if (id != null) ...[
          const SizedBox(width: 2),
          Icono(Iconos.chevronRight, size: 15, color: c.textoTenue),
        ],
      ]),
    );
    if (id == null) return DecoratedBox(decoration: ShapeDecoration(color: c.superficie, shape: forma), child: contenido);
    return Presionable(
      escala: .95,
      child: Material(
        color: c.superficie,
        shape: forma,
        child: InkWell(
          customBorder: forma,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Foro(idPerro: id, nombrePerro: nombre))),
          child: contenido,
        ),
      ),
    );
  }
}

Future<void> cerrarEmergencia(BuildContext context, Emergencia emergencia) =>
    mostrarHoja<void>(context, builder: (_) => _HojaCerrar(emergencia: emergencia));

List<(EstadoEmergencia, String)> _opcionesCierre(bool varios) => [
      (EstadoEmergencia.resuelta, varios ? 'Los perritos ya están bien' : 'El perrito ya está bien'),
      (EstadoEmergencia.veterinario, varios ? 'Los llevaron o los atenderá un veterinario' : 'Lo llevaron o lo atenderá un veterinario'),
      (EstadoEmergencia.falsaAlarma, 'No era una emergencia'),
    ];

class _HojaCerrar extends StatefulWidget {
  const _HojaCerrar({required this.emergencia});
  final Emergencia emergencia;

  @override
  State<_HojaCerrar> createState() => _HojaCerrarState();
}

class _HojaCerrarState extends State<_HojaCerrar> {
  final _nota = TextEditingController();
  EstadoEmergencia? _estado;
  bool _enviando = false;

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  Future<void> _cerrar() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _enviando = true);
    try {
      await EmergenciasRepository()
          .cerrar(widget.emergencia.id, estado: _estado!, nota: _nota.text)
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Emergencia cerrada. La comunidad verá cómo terminó.')));
    } on TimeoutException {
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Hay poca señal. El cierre se enviará apenas vuelva la conexión.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviando = false);
      messenger.showSnackBar(const SnackBar(content: Text('No se pudo cerrar la emergencia. Inténtalo de nuevo.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final e = widget.emergencia;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .9),
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + MediaQuery.paddingOf(context).bottom + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Center(child: Container(width: 36, height: 4, decoration: Formas.fondo(c.divisor, 2))),
          const SizedBox(height: 14),
          Text('¿Cómo terminó?', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800).display),
          const SizedBox(height: 2),
          Text(
            '${e.tipo} · ${e.nombres}. Quienes siguen ${e.idsPerros.length > 1 ? 'a estos perritos' : 'al perrito'} verán el cierre.',
            style: TextStyle(fontSize: 12, color: c.textoSecundario),
          ),
          const SizedBox(height: 16),
          for (final (estado, descripcion) in _opcionesCierre(e.idsPerros.length > 1))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _OpcionCierre(
                estado: estado,
                descripcion: descripcion,
                seleccionada: _estado == estado,
                alTocar: _enviando ? null : () => setState(() => _estado = estado),
              ),
            ),
          const SizedBox(height: 8),
          Container(
            decoration: ShapeDecoration(color: c.superficie, shape: Formas.squircle(14, lado: BorderSide(color: c.divisor))),
            child: TextField(
              controller: _nota,
              enabled: !_enviando,
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              decoration: InputDecoration(
                hintText: 'Cuéntale a la comunidad qué pasó (opcional)',
                hintStyle: TextStyle(color: c.textoTenue),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: Presionable(
              child: FilledButton(
                onPressed: _estado == null || _enviando ? null : _cerrar,
                style: FilledButton.styleFrom(
                  backgroundColor: c.acento,
                  foregroundColor: c.sobreAcento,
                  disabledBackgroundColor: c.acento.withValues(alpha: .35),
                  disabledForegroundColor: c.sobreAcento,
                  shape: Formas.squircle(16),
                ),
                child: _enviando
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: c.sobreAcento))
                    : const Text('Cerrar emergencia', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: _enviando ? null : () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: c.textoSecundario, fontWeight: FontWeight.w600)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _OpcionCierre extends StatelessWidget {
  const _OpcionCierre({required this.estado, required this.descripcion, required this.seleccionada, required this.alTocar});
  final EstadoEmergencia estado;
  final String descripcion;
  final bool seleccionada;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final color = c.colorEmergencia(estado);
    final forma = Formas.squircle(16, lado: BorderSide(color: seleccionada ? color : c.divisor, width: seleccionada ? 1.5 : 1));
    return Semantics(
      selected: seleccionada,
      child: Presionable(
        escala: .98,
        child: Material(
          color: seleccionada ? Color.alphaBlend(color.withValues(alpha: .08), c.superficie) : c.superficie,
          shape: forma,
          child: InkWell(
            customBorder: forma,
            onTap: alTocar,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: Formas.fondo(color.withValues(alpha: .14), 12),
                  child: Icono(iconoCierre(estado), size: 20, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(estado.texto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(descripcion, style: TextStyle(fontSize: 12, color: c.textoSecundario)),
                  ]),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (hijo, animacion) => ScaleTransition(scale: animacion, child: hijo),
                  child: seleccionada
                      ? Container(
                          key: const ValueKey(true),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          child: Icono(Iconos.check, size: 14, color: c.sobreAcento),
                        )
                      : Container(
                          key: const ValueKey(false),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c.divisor, width: 1.5)),
                        ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
