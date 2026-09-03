import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/screens/componentesforo.dart';

class Comentarios extends StatelessWidget{
  const Comentarios({
    super.key,
    required this.IDComentario,
    required this.IDUsuario,
  });
  final List<String> IDComentario;
  final List<String> IDUsuario;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1000,
      color: Color.fromRGBO(249, 240, 235, 1),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton.filledTonal(
            icon: Icon(Icons.arrow_back),
            iconSize: 20,
            color: Colors.grey,
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Publicacion(
            TipoPub: 'General', 
            IDPerro: '1',
            IDUsuario: IDUsuario,
            TextoPub: IDComentario[0],
          ),
        ],
      ),
    );
  }
}