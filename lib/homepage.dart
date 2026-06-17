import 'package:flutter/material.dart';

/// Base de la página de inicio
class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    // Variable auxiliar mientras no se tiene la base de datos
    var perros = [
      ['Princesa', 'Hace 10 minutos', 'Saludable'],
      ['Nube', 'Hace 1 hora', 'Necesita atención'],
      ['Goldie', 'Hace 15 minutos', 'Saludable'],
      ['Manchas', 'Hace 4 horas', 'Saludable'],
      ['Rocky', 'Hace 6 horas', 'Necesita atención']
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('GUAUrdados'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ListaPerrosSeguidos(
                listaPerrosSeguidos: perros,
          ),
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
          Expanded(
              child: ListaTodosLosPerros(
                  listaPerros: perros,
              ),
          ),
        ],
      ),
    );
  }
}


/// Módulo con la lista de los perros seguidos
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
        height: 110,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          scrollDirection: Axis.horizontal,
          itemCount: listaPerrosSeguidos.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 100,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  children: [
                    Text('Image'),
                    Text(listaPerrosSeguidos[index][0])
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


/// Módulo con la lista de todos los perros
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
      child: ListView.builder(
        itemCount: listaPerros.length,
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: Column(
              children: <Widget>[
                Card(
                  child: SizedBox(
                    width: 400,
                    height: 80,
                    child: Row(
                      children: [
                        Text('Imagen'),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listaPerros[index][0],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            Text(listaPerros[index][1]),
                          ],
                        ),
                        Text(
                          listaPerros[index][2],
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

