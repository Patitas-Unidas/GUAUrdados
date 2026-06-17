import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
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
        children: [
          Text('Todos los perritos'),
          Expanded(
              child: ListaTodosLosPerros(
                  listaPerros: perros
              ),
          ),
        ],
      ),
    );
  }
}


class ListaTodosLosPerros extends StatelessWidget {
  const ListaTodosLosPerros({
    super.key,
    required this.listaPerros,
  });

 final List<List<String>> listaPerros;

  @override
  Widget build(BuildContext context){
    return Container(
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
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
                          children: [
                            Text(listaPerros[index][0]),
                            Text(listaPerros[index][1]),
                          ],
                        ),
                        Text(listaPerros[index][2]),
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
