import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/screens/foro.dart';
import 'package:guaurdados_oficial/screens/perfilperro.dart';

class ListadoPerros extends StatelessWidget{
  ListadoPerros({super.key});

  var perros = [
    ['0', 'Scooby', 'Hace 10 minutos', 'Saludable'],
    ['1', 'Bobby', 'Hace 1 hora', 'Necesita atención'],
    ['2', 'Ramón', 'Hace 15 minutos', 'Saludable'],
    ['3', 'Ramona', 'Hace 4 horas', 'Saludable'],
    ['4', 'Mora', 'Hace 6 horas', 'Necesita atención'],
    ['5', 'Tommy', 'Hace 10 minutos', 'Saludable'],
    ['6', 'Romeo', 'Hace 1 hora', 'Necesita atención'],
    ['7', 'Lobito', 'Hace 15 minutos', 'Saludable']
  ];
  var perrosSeguidos = [
    ['0', 'Scooby', 'Hace 10 minutos', 'Saludable'],
    ['1', 'Bobby', 'Hace 1 hora', 'Necesita atención'],
    ['2', 'Ramón', 'Hace 15 minutos', 'Saludable'],
    ['3', 'Ramona', 'Hace 4 horas', 'Saludable'],
    ['4', 'Mora', 'Hace 6 horas', 'Necesita atención']
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto "Patitas seguidas"
        Container(
          padding: EdgeInsets.only(left: 15),
          child: Text(
            'Patitas seguidas',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        // Llamado a ListaPerrosSeguidos
        ListaPerrosSeguidos(
          listaPerrosSeguidos: perrosSeguidos,
        ),
        // Llamado a BotonForo
        Padding(
          padding: EdgeInsets.only(left: 15, bottom: 20),
          child: BotonForo(),
        ),
        // Texto "Todos los perritos"
        Container(
          padding: EdgeInsets.only(left: 15),
          child: Text(
            'Todos los perritos',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        // Llamado a ListaTodosLosPerros
        Expanded(
          child: ListaTodosLosPerros(
            listaPerros: perros,
          ),
        ),
      ],
    );
  }
}

/// Clase con la lista de los perros seguidos
/// Crea una lista de cards scrolleable horizontalmente que sólo toma en cuenta a los perros seguidos
/// Si no hay perros seguidos, ésta clase y su título no se verán
class ListaPerrosSeguidos extends StatelessWidget {
  const ListaPerrosSeguidos({
    super.key,
    required this.listaPerrosSeguidos,
  });
  final List<List<String>> listaPerrosSeguidos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: SizedBox(
        height: 190,
        // Creador del listado de cards
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          // Le decimos que queremos que sea scrolleable horizontalmente
          scrollDirection: Axis.horizontal,
          // Toma en cuenta la cantidad de perros seguidos con la longitud de la listaPerrosSeguidos
          itemCount: listaPerrosSeguidos.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 160,
              child: Card(
                color: Color.fromRGBO(249, 240, 235, 1),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => PerfilPerro(
                          IDPerro: listaPerrosSeguidos[index][0],
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: AssetImage('fotos/${listaPerrosSeguidos[index][1]}.jpg'),
                        ),
                        Text(
                          listaPerrosSeguidos[index][1],
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (listaPerrosSeguidos[index][3] == 'Saludable') ...[
                          Text(
                            listaPerrosSeguidos[index][3],
                            style: TextStyle(
                              color: Color.fromRGBO(76, 175, 130, 1),
                            ),
                          ),
                        ]
                        else ...[
                          Text(
                            listaPerrosSeguidos[index][3],
                            style: TextStyle(
                              color: Color.fromRGBO(255, 149, 0, 1),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Clase con la lista de todos los perros
/// Crea una lista de cards scrolleable verticalmente que automáticamente considera a todos los perros
class ListaTodosLosPerros extends StatelessWidget {
  const ListaTodosLosPerros({
    super.key,
    required this.listaPerros,
  });
  final List<List<String>> listaPerros;

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.all(12),
      // Creador del listado de cards
      child: ListView.builder(
        // Toma en cuenta la cantidad de perros totales con la longitud de la listaPerros
        itemCount: listaPerros.length,
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: Column(
              children: <Widget>[
                Card(
                    color: Color.fromRGBO(249, 240, 235, 1),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => PerfilPerro(
                              IDPerro: listaPerros[index][0],
                            ),
                          ),
                        );
                      },
                      child:
                      SizedBox(
                        width: 400,
                        height: 80,
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius:28,
                                    backgroundImage: AssetImage('fotos/${listaPerros[index][1]}.jpg'),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          listaPerros[index][1],
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 15,
                                              color: Color.fromRGBO(56, 54, 53, 0.75),
                                            ),
                                            Text(
                                              listaPerros[index][2],
                                              style: TextStyle(
                                                  color: Color.fromRGBO(56, 54, 53, 0.75)
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  if (listaPerros[index][3] == 'Saludable') ...[
                                    Text(
                                      listaPerros[index][3],
                                      style: TextStyle(
                                        color: Color.fromRGBO(76, 175, 130, 1),
                                      ),
                                    ),
                                  ]
                                  else ...[
                                    Text(
                                      listaPerros[index][3],
                                      style: TextStyle(
                                        color: Color.fromRGBO(255, 149, 0, 1),
                                      ),
                                    ),
                                  ],
                                  Icon(Icons.arrow_right)
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Clase con el botón de foro principal
class BotonForo extends StatelessWidget {
  const BotonForo({super.key});

  @override
  Widget build(BuildContext context){
    return SizedBox(
      width: 380,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Color.fromRGBO(222, 79, 65, 1),
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (context) => Foro()
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
            Text(
              'Foros',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}