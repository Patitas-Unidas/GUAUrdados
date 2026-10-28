import 'package:flutter/material.dart';
import '../widgets/imagen_remota.dart';

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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff9f0eb),
    appBar: AppBar(
      backgroundColor: const Color(0xfff9f0eb),
      elevation: 0,
      title: Text('Carnet de ${widget.nombrePerro}', style: const TextStyle(color: Color(0xff393330), fontSize: 19, fontWeight: FontWeight.w700)),
      iconTheme: const IconThemeData(color: Color(0xff393330)),
    ),
    body: Column(children: [
      Expanded(
        child: PageView.builder(
          itemCount: widget.imagenes.length,
          onPageChanged: (index) => setState(() => _paginaActual = index),
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: Colors.white,
                child: ImagenRemota(url: widget.imagenes[index], fit: BoxFit.contain, error: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.broken_image_outlined, size: 42), SizedBox(height: 8), Text('No se pudo cargar esta imagen')]))),
              ),
            ),
          ),
        ),
      ),
      if (widget.imagenes.length > 1) ...[
        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(widget.imagenes.length, (index) => AnimatedContainer(duration: const Duration(milliseconds: 180), margin: const EdgeInsets.all(4), width: index == _paginaActual ? 20 : 7, height: 7, decoration: BoxDecoration(color: index == _paginaActual ? const Color(0xffe85042) : const Color(0xffd5c6bf), borderRadius: BorderRadius.circular(10))))),
        const SizedBox(height: 20),
      ],
      Padding(padding: const EdgeInsets.only(bottom: 18), child: Text('${_paginaActual + 1} de ${widget.imagenes.length} · Desliza para ver el otro lado', style: const TextStyle(fontSize: 12, color: Color(0xff625a56)))),
    ]),
  );
}
