import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/screens/perfilperro.dart'; // Verifica que esta ruta coincida con la tuya
import 'foro.dart';

/// Base de la página de inicio
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<StatefulWidget> createState() => HomepageBody();
}

/// Cuerpo de la página de inicio
class HomepageBody extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    // Variables auxiliares
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(238, 210, 195, 1),
        title: Image.asset(
          'fotos/Letras.png',
          width: 150,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.notifications),
              iconSize: 20,
              color: Colors.grey,
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(255, 0, 55, 1),
              ),
              onPressed: () {},
              child: const Text(
                'Emergencia',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),

      // Cuerpo de la página principal
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texto "Patitas seguidas"
          Container(
            padding: const EdgeInsets.only(left: 15, top: 15),
            child: const Text(
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
          const Padding(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 20),
            child: BotonForo(),
          ),
          // Texto "Todos los perritos"
          Container(
            padding: const EdgeInsets.only(left: 15),
            child: const Text(
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
      ),

      // Bottom navbar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '',
          ),
        ],
        currentIndex: 0,
        backgroundColor: const Color.fromRGBO(235, 185, 157, 1),
        selectedItemColor: const Color.fromRGBO(222, 79, 65, 1),
        iconSize: 40,
        selectedFontSize: 0,
      ),
    );
  }
}

/// Clase con la lista de los perros seguidos
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
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          scrollDirection: Axis.horizontal,
          itemCount: listaPerrosSeguidos.length,
          itemBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 160,
              child: Card(
                color: const Color.fromRGBO(249, 240, 235, 1),
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
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundImage: AssetImage('fotos/${listaPerrosSeguidos[index][1]}.jpg'),
                        ),
                        Text(
                          listaPerrosSeguidos[index][1],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (listaPerrosSeguidos[index][3] == 'Saludable') ...[
                          Text(
                            listaPerrosSeguidos[index][3],
                            style: const TextStyle(
                              color: Color.fromRGBO(76, 175, 130, 1),
                            ),
                          ),
                        ]
                        else ...[
                          Text(
                            listaPerrosSeguidos[index][3],
                            style: const TextStyle(
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
class ListaTodosLosPerros extends StatelessWidget {
  const ListaTodosLosPerros({
    super.key,
    required this.listaPerros,
  });
  final List<List<String>> listaPerros;

  @override
  Widget build(BuildContext context){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        itemCount: listaPerros.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0), // Separación entre tarjetas
            child: Card(
                color: const Color.fromRGBO(249, 240, 235, 1),
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
                  child: SizedBox(
                    width: double.infinity, // tomar todo lo ancho
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage: AssetImage('fotos/${listaPerros[index][1]}.jpg'),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listaPerros[index][1],
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            size: 15,
                                            color: Color.fromRGBO(56, 54, 53, 0.75),
                                          ),
                                          Expanded(
                                            child: Text(
                                              listaPerros[index][2],
                                              style: const TextStyle(
                                                  color: Color.fromRGBO(56, 54, 53, 0.75)
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              if (listaPerros[index][3] == 'Saludable') ...[
                                Text(
                                  listaPerros[index][3],
                                  style: const TextStyle(
                                    color: Color.fromRGBO(76, 175, 130, 1),
                                  ),
                                ),
                              ]
                              else ...[
                                Text(
                                  listaPerros[index][3],
                                  style: const TextStyle(
                                    color: Color.fromRGBO(255, 149, 0, 1),
                                  ),
                                ),
                              ],
                              const Icon(Icons.arrow_right)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
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
      width: double.infinity, // Se adaptA a cualquier pantalla
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: const Color.fromRGBO(222, 79, 65, 1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
                builder: (context) => const Foro()
            ),
          );
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
            ),
            SizedBox(width: 8),
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