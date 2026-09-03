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
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: new BoxDecoration(
        color: Color.fromRGBO(249, 240, 235, 1),
        borderRadius: new BorderRadius.only(
          topLeft: const Radius.circular(25.0),
          topRight: const Radius.circular(25.0),
        ),
      ),
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
          Card(
            margin: EdgeInsets.all(10),
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Carlos Méndez',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text('Que bueno!')
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                    thickness: 1,
                    color: Color.fromRGBO(56, 54, 53, .3),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sofía Ramos',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text('Acuérdate de hacer el registro oficial :)')
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                    thickness: 1,
                    color: Color.fromRGBO(56, 54, 53, .3),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 15,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Simón Fuentes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text('Que no se atore no más xd')
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ) 
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Card(
              margin: EdgeInsets.all(10),
              color: Colors.white,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  hintText: 'Deja tu comentario aquí.' 
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}