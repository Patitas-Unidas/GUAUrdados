import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';

class NuevaPublicacion extends StatefulWidget {
  const NuevaPublicacion({super.key, this.IDPerro});
  final String? IDPerro;
  @override
  State<NuevaPublicacion> createState() => _NuevaPublicacionState();
}

class _NuevaPublicacionState extends State<NuevaPublicacion> {
  String? _perroSeleccionado;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfff9f0eb),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [
      Row(children: [IconButton.filledTonal(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)), const SizedBox(width: 8), const Text('Nueva publicación', style: TextStyle(fontSize: 20))]),
      const Divider(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(child: _SelectorPerro(idInicial: widget.IDPerro, seleccionado: _perroSeleccionado, alSeleccionar: (id) => setState(() => _perroSeleccionado = id))),
        const Card(child: Padding(padding: EdgeInsets.all(10), child: Icon(Icons.add_a_photo))),
      ]),
      const SizedBox(height: 5),
      const Expanded(child: Card(color: Colors.white, child: TextField(expands: true, maxLines: null, keyboardType: TextInputType.multiline, decoration: InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(15), hintText: 'Escribe aquí')))),
    ]))),
  );
}

class _SelectorPerro extends StatelessWidget {
  const _SelectorPerro({required this.idInicial, required this.seleccionado, required this.alSeleccionar});
  final String? idInicial, seleccionado;
  final ValueChanged<String?> alSeleccionar;
  @override
  Widget build(BuildContext context) => StreamBuilder<List<Perro>>(
    stream: PerrosRepository().observarPerros(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return const Card(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
      final perros = snapshot.data!;
      final id = idInicial ?? seleccionado;
      final perro = id == null
          ? null
          : perros.cast<Perro?>().firstWhere((p) => p!.id == id, orElse: () => null);
      if (idInicial != null && perro != null) return _EtiquetaPerro(perro: perro);
      return Card(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text('Foro  '),
        Expanded(child: DropdownButton<String>(isExpanded: true, value: seleccionado, hint: const Text('Escoja un perrito'), items: perros.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(), onChanged: alSeleccionar)),
      ])));
    },
  );
}
class _EtiquetaPerro extends StatelessWidget {
  const _EtiquetaPerro({required this.perro}); final Perro perro;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(10), child: Row(mainAxisSize: MainAxisSize.min, children: [CircleAvatar(radius: 18, backgroundImage: perro.fotoUrl.isNotEmpty ? NetworkImage(perro.fotoUrl) : perro.imagenAsset.isEmpty ? null : AssetImage('fotos/${perro.imagenAsset}'), onBackgroundImageError: (_, __) {}, child: perro.fotoUrl.isEmpty && perro.imagenAsset.isEmpty ? const Icon(Icons.pets) : null), const SizedBox(width: 8), Text('Foro de ${perro.nombre}')])));
}
