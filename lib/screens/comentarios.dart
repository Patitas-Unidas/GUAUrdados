import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/screens/componentesforo.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';

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
    final c = context.colores;
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: ShapeDecoration(
        color: c.fondo,
        shape: Formas.squircleArriba(25),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton.filledTonal(
            icon: Icono(Iconos.chevronLeft),
            iconSize: 20,
            color: c.textoTenue,
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
            color: c.superficie,
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
                            Text('¡Qué bueno!')
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                    thickness: 1,
                    color: c.divisor,
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
                    color: c.divisor,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  margin: EdgeInsets.all(10),
                  color: c.superficie,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'Deja tu comentario aquí.'
                      ),
                    ),
                  ),
                ),
                Card(
                  margin: EdgeInsets.all(10),
                  color: c.superficie,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Icono(Iconos.send),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}