import 'package:flutter/material.dart';

/// Base de la página de inicio
class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    // Variables auxiliares mientras no se tiene la base de datos
    var perros = [
      ['Princesa', 'Hace 10 minutos', 'Saludable'],
      ['Nube', 'Hace 1 hora', 'Necesita atención'],
      ['Goldie', 'Hace 15 minutos', 'Saludable'],
      ['Manchas', 'Hace 4 horas', 'Saludable'],
      ['Rocky', 'Hace 6 horas', 'Necesita atención'],
      ['Minnie', 'Hace 10 minutos', 'Saludable'],
      ['Bebé', 'Hace 1 hora', 'Necesita atención'],
      ['Spot', 'Hace 15 minutos', 'Saludable'],
      ['Walter', 'Hace 4 horas', 'Saludable'],
      ['Sir', 'Hace 6 horas', 'Necesita atención']
    ];
    var perrosSeguidos = [
      ['Princesa', 'Hace 10 minutos', 'Saludable'],
      ['Nube', 'Hace 1 hora', 'Necesita atención'],
      ['Goldie', 'Hace 15 minutos', 'Saludable'],
      ['Manchas', 'Hace 4 horas', 'Saludable'],
      ['Rocky', 'Hace 6 horas', 'Necesita atención']
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(238,210,195,1),
        title: Text(
          'GUAUrdados',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 28,
            color: Color.fromRGBO(56, 54, 53, 1),
          ),
        ),
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
                listaPerrosSeguidos: perrosSeguidos,
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
        height: 130,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          scrollDirection: Axis.horizontal,
          itemCount: listaPerrosSeguidos.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 120,
              child: Card(
                color: Color.fromRGBO(249, 240, 235, 1),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: InkWell(
                  splashColor: Colors.white,
                  onTap: () {},
                  child: Column(
                    children: [
                      Text('Imagen'),
                      Text(
                        listaPerrosSeguidos[index][0],
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
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
                  color: Color.fromRGBO(249, 240, 235, 1),
                  child: InkWell(
                    splashColor: Colors.white,
                    onTap: () {},
                    child: SizedBox(
                      width: 400,
                      height: 80,
                      child: Row(
                        children: [
                          Text('Imagen'),
                          Padding(
                            padding: EdgeInsets.only(top: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listaPerros[index][0],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(listaPerros[index][1]),
                              ],
                            ),
                          ),
                          Text(
                            listaPerros[index][2],
                            textAlign: TextAlign.right,
                          ),
                        ],
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

