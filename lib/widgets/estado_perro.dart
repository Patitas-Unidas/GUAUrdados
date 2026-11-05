import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/services/cuidados.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';

extension TonosEstado on ColoresApp {
  (Color fondo, Color texto) tono(Gravedad gravedad) => switch (gravedad) {
        Gravedad.bien => (exitoSuave, exitoTexto),
        Gravedad.neutro => (divisor, neutroTexto),
        Gravedad.revisar => (advertenciaSuave, advertenciaTexto),
        Gravedad.urgente => (emergenciaSuave, emergenciaTexto),
        Gravedad.adoptado => (adoptadoSuave, adoptadoTexto),
      };
}

class PildoraEstado extends StatelessWidget {
  const PildoraEstado(this.estado, {super.key, this.ancha = false});
  final EstadoPerro estado;
  final bool ancha;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final (fondo, texto) = c.tono(estado.gravedad);
    return DecoratedBox(
      decoration: Formas.fondo(c.superficie, 18),
      child: Container(
        width: ancha ? null : 86,
        padding: EdgeInsets.symmetric(horizontal: ancha ? 15 : 6, vertical: 7),
        decoration: Formas.fondo(fondo, 18),
        child: Text(estado.texto, maxLines: 1, textAlign: TextAlign.center, style: TextStyle(color: texto, fontSize: 11, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class ChipAviso extends StatelessWidget {
  const ChipAviso(this.aviso, {super.key});
  final Aviso aviso;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final (fondo, texto) = c.tono(aviso.gravedad);
    final icono = switch (aviso.gravedad) {
      Gravedad.bien => Iconos.circleCheck,
      Gravedad.neutro => Iconos.clock,
      Gravedad.revisar => Iconos.circleAlert,
      Gravedad.urgente => Iconos.triangleAlert,
      Gravedad.adoptado => Iconos.heart,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: Formas.fondo(fondo, 10),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icono(icono, size: 15, color: texto),
        const SizedBox(width: 5),
        Flexible(child: Text(aviso.texto, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: texto))),
      ]),
    );
  }
}
