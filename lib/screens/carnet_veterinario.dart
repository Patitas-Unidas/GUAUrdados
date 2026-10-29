import 'package:flutter/material.dart';
import '../widgets/imagen_remota.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/theme/app_colors.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';

class CarnetVeterinario extends StatefulWidget {
  const CarnetVeterinario({super.key, required this.nombrePerro, required this.imagenes});
  final String nombrePerro;
  final List<String> imagenes;

  @override
  State<CarnetVeterinario> createState() => _CarnetVeterinarioState();
}

class _CarnetVeterinarioState extends State<CarnetVeterinario> {
  var _paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
    backgroundColor: c.fondo,
    appBar: AppBar(
      backgroundColor: c.fondo,
      elevation: 0,
      title: Text('Carnet de ${widget.nombrePerro}', style: TextStyle(color: c.texto, fontSize: 19, fontWeight: FontWeight.w700).display),
      iconTheme: IconThemeData(color: c.texto),
    ),
    body: Column(children: [
      Expanded(
        child: PageView.builder(
          itemCount: widget.imagenes.length,
          onPageChanged: (index) => setState(() => _paginaActual = index),
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: ClipRSuperellipse(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: AppColors.blanco,
                child: ImagenRemota(url: widget.imagenes[index], fit: BoxFit.contain, cargando: const SizedBox.expand(child: BloqueEsqueleto(radio: 0)), error: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icono(Iconos.imageOff, size: 42), SizedBox(height: 8), Text('No se pudo cargar esta imagen')]))),
              ),
            ),
          ),
        ),
      ),
      if (widget.imagenes.length > 1) ...[
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(widget.imagenes.length, (index) => AnimatedContainer(duration: const Duration(milliseconds: 180), margin: const EdgeInsets.all(4), width: index == _paginaActual ? 20 : 7, height: 7, decoration: Formas.fondo(index == _paginaActual ? c.acento : c.divisor, 10)))),
        const SizedBox(height: 20),
      ],
      Padding(padding: const EdgeInsets.only(bottom: 18), child: Text('${_paginaActual + 1} de ${widget.imagenes.length} · Desliza para ver el otro lado', style: TextStyle(fontSize: 12, color: c.textoSecundario))),
    ]),
  );
  }
}
