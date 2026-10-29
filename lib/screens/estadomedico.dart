import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/services/cuidados.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

import 'carnet_veterinario.dart';

const _sinRegistrar = 'Sin registrar';

class EstadoMedico extends StatelessWidget {
  const EstadoMedico({super.key, required this.perro, required this.actualizado});
  final Perro perro;
  final String actualizado;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final sano = perro.estado.toLowerCase() == 'saludable';
    final vacunado = perro.vacunacion.toLowerCase().startsWith('vacunado');
    final sinDatoVacuna = perro.vacunacion == 'Sin información';
    final esterilizado = perro.esterilizado;
    final alto = MediaQuery.sizeOf(context).height;
    final cuidados = Cuidados(perro);

    return Container(
      constraints: BoxConstraints(maxHeight: alto * .9),
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + MediaQuery.paddingOf(context).bottom),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(
            child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14), decoration: Formas.fondo(c.divisor, 2)),
          ),

          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: Formas.fondo(c.acento, 12),
              child: Icono(Iconos.heart, color: c.sobreAcento),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Estado médico', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800).display),
                Text('${perro.nombre} · Actualizado $actualizado', style: TextStyle(fontSize: 13, color: c.textoSecundario)),
              ]),
            ),
            Presionable(
              child: Material(
                color: _tinte(context, c.acento),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.pop(context),
                  icon: Icono(Iconos.x, color: c.acento),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),

          Aparicion(
            child: Row(children: [
              Expanded(
                child: _Resumen(
                  icono: Iconos.weight,
                  color: c.acento,
                  valor: perro.peso,
                  etiqueta: 'Peso actual',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Resumen(
                  icono: Iconos.scissors,
                  color: esterilizado == null ? c.textoTenue : c.exitoTexto,
                  valor: esterilizado == null ? _sinRegistrar : (esterilizado ? 'Sí' : 'No'),
                  etiqueta: 'Esterilizado',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Resumen(
                  icono: Iconos.shieldCheck,
                  color: sano ? c.exitoTexto : c.advertenciaTexto,
                  valor: perro.estado,
                  etiqueta: 'Salud general',
                ),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          Aparicion(
            indice: 1,
            child: _plazo(
              context,
              plazo: cuidados.vacunas,
              icono: Iconos.syringe,
              titulo: 'Vacunas',
              ultima: perro.ultimaVacunaEn,
              vacunado: sinDatoVacuna ? null : vacunado,
            ),
          ),
          const SizedBox(height: 10),
          Aparicion(
            indice: 2,
            child: _plazo(
              context,
              plazo: cuidados.desparasitacion,
              icono: Iconos.pill,
              titulo: 'Desparasitación',
              ultima: perro.ultimaDesparasitacionEn,
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
            child: Text(
              'CONDICIONES MÉDICAS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: .4, color: c.textoTenue),
            ),
          ),
          Aparicion(
            indice: 3,
            child: perro.condiciones.isEmpty
                ? _FilaSimple(icono: Iconos.circleCheck, texto: 'Sin condiciones médicas registradas')
                : _Condiciones(condiciones: perro.condiciones),
          ),

          if (perro.carnetUrls.isNotEmpty) ...[
            const SizedBox(height: 18),
            Aparicion(
              indice: 4,
              child: Presionable(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: c.medico,
                      foregroundColor: c.sobreAcento,
                      shape: Formas.squircle(14),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CarnetVeterinario(nombrePerro: perro.nombre, imagenes: perro.carnetUrls)),
                    ),
                    icon: const Icono(Iconos.idCard),
                    label: const Text('Ver carnet veterinario', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

Widget _plazo(
  BuildContext context, {
  required Plazo plazo,
  required IconData icono,
  required String titulo,
  required DateTime? ultima,
  bool? vacunado,
}) {
  final c = context.colores;
  final (estado, color, iconoEstado) = switch (plazo) {
    AlDia(:final vence) => ('Próxima: ${fecha(vence)}', c.exitoTexto, Iconos.circleCheck),
    PorVencer(:final dias) => (dias == 0 ? 'Vence hoy' : 'Vence en $dias ${dias == 1 ? 'día' : 'días'}', c.advertenciaTexto, Iconos.calendar),
    Vencido() => ('Vencida', c.emergenciaTexto, Iconos.circleAlert),
    SinDato() when vacunado == true => ('Al día', c.exitoTexto, Iconos.circleCheck),
    SinDato() when vacunado == false => ('Pendiente', c.emergenciaTexto, Iconos.circleAlert),
    SinDato() => (_sinRegistrar, c.textoTenue, Iconos.circleHelp),
  };
  return _Tratamiento(
    icono: icono,
    color: color,
    titulo: titulo,
    detalle: 'Última: ${ultima == null ? _sinRegistrar.toLowerCase() : fecha(ultima)}',
    estado: estado,
    iconoEstado: iconoEstado,
  );
}

Color _tinte(BuildContext context, Color color) =>
    color.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .2 : .12);

class _Resumen extends StatelessWidget {
  const _Resumen({required this.icono, required this.color, required this.valor, required this.etiqueta});
  final IconData icono;
  final Color color;
  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final sinDato = valor == _sinRegistrar || valor == 'Sin información';
    return Container(
      height: 104,
      padding: const EdgeInsets.all(12),
      decoration: Formas.fondo(_tinte(context, color), 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Icono(icono, size: 20, color: color),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              sinDato ? _sinRegistrar : valor,
              maxLines: 1,
              style: TextStyle(
                fontSize: sinDato ? 14 : 20,
                fontWeight: FontWeight.w800,
                color: sinDato ? context.colores.textoTenue : color == context.colores.acento ? null : color,
              ).display,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(etiqueta, maxLines: 1, style: TextStyle(fontSize: 12, color: context.colores.textoSecundario)),
          ),
        ]),
      ]),
    );
  }
}

class _Tratamiento extends StatelessWidget {
  const _Tratamiento({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.detalle,
    required this.estado,
    required this.iconoEstado,
  });
  final IconData icono;
  final Color color;
  final String titulo;
  final String detalle;
  final String estado;
  final IconData iconoEstado;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: Formas.fondo(_tinte(context, color), 18),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: Formas.fondo(_tinte(context, color), 12),
          child: Icono(icono, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(detalle, style: TextStyle(fontSize: 12, color: c.textoSecundario)),
          ]),
        ),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: Formas.fondo(_tinte(context, color), 8),
            child: Text(estado, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ),
          const SizedBox(height: 6),
          Icono(iconoEstado, size: 18, color: color),
        ]),
      ]),
    );
  }
}

class _Condiciones extends StatelessWidget {
  const _Condiciones({required this.condiciones});
  final List<String> condiciones;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: Formas.fondo(_tinte(context, c.advertencia), 18),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icono(Iconos.triangleAlert, color: c.advertenciaTexto),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('A tener en cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final condicion in condiciones)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: Formas.fondo(_tinte(context, c.advertencia), 10),
                  child: Text(condicion, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.advertenciaTexto)),
                ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _FilaSimple extends StatelessWidget {
  const _FilaSimple({required this.icono, required this.texto});
  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: Formas.fondo(context.colores.superficie, 14),
    child: Row(children: [
      Icono(icono, size: 20, color: context.colores.exitoTexto),
      const SizedBox(width: 10),
      Expanded(child: Text(texto, style: TextStyle(fontSize: 14, color: context.colores.textoSecundario))),
    ]),
  );
}
