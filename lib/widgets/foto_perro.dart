import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';

import 'esqueleto.dart';
import 'iconos.dart';
import 'imagen_remota.dart';

class FotoPerroRedonda extends StatelessWidget {
  const FotoPerroRedonda({super.key, required this.perro, required this.tamano});
  final Perro? perro;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final perro = this.perro;
    final vacio = ColoredBox(
      color: c.contenedor,
      child: Center(child: Icono(Iconos.pawPrint, size: tamano * .45, color: c.textoSecundario)),
    );
    final Widget imagen;
    if (perro != null && perro.fotoUrl.isNotEmpty) {
      imagen = ImagenRemota(url: perro.fotoUrl, fit: BoxFit.cover, alignment: perro.encuadre, cargando: const BloqueEsqueleto(circular: true), error: vacio);
    } else if (perro != null && perro.imagenAsset.isNotEmpty) {
      imagen = Image.asset('fotos/${perro.imagenAsset}', fit: BoxFit.cover, alignment: perro.encuadre, errorBuilder: (_, _, _) => vacio);
    } else {
      imagen = vacio;
    }
    return SizedBox(width: tamano, height: tamano, child: ClipOval(child: imagen));
  }
}
