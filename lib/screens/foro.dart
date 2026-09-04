import 'package:flutter/material.dart';
import 'nuevapublicacion.dart';
import 'componentesforo.dart';

class Foro extends StatelessWidget {
  const Foro({
    super.key,
    this.IDPerro,
  });
  final String? IDPerro;

  @override
  Widget build(BuildContext context) {
    var perros = [
      ['0', 'Scooby'],
      ['1', 'Bobby'],
      ['2', 'Ramón'],
      ['3', 'Ramona'],
      ['4', 'Mora'],
      ['5', 'Tommy'],
      ['6', 'Romeo'],
      ['7', 'Lobito']
    ];
    var users = ['María G.', 'Carlos M.', 'Sofía R.'];

    return Scaffold(
      backgroundColor: const Color.fromRGBO(249, 240, 235, 1),
      body: Padding(
        padding: const EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 20,),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Botón de regreso, nombre del foro, actualizaciones y botón de emergencia
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.arrow_back),
                          iconSize: 20,
                          color: Colors.grey,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (IDPerro == null) ...[
                                  const Text(
                                    'Foro',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ]
                                else ...[
                                  Text(
                                    'Foro de ${perros[int.parse(IDPerro!)][1]}',
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis, // Corta con "..." si el nombre es muy largo
                                  ),
                                ],
                                const Text(
                                  '4 actualizaciones',
                                  style: TextStyle(
                                    color: Color.fromRGBO(56, 54, 53, .5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: TextButton.styleFrom(
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
                ],
              ),


              Padding(
                padding: const EdgeInsets.only(top: 15,),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // Row se ajuste al cont
                            children: [
                              const CircleAvatar(radius: 16),
                              const SizedBox(width: 8),
                              Text(users[0]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4), // Separación entre tarjetas
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(radius: 16),
                              const SizedBox(width: 8),
                              Text(users[1]),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(radius: 16),
                              const SizedBox(width: 8),
                              Text(users[2]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Linea horizontal
              const Divider(
                height: 30,
                thickness: 1,
                color: Color.fromRGBO(56, 54, 53, .3),
              ),

              // Botón nueva publicación
              Card(
                margin: const EdgeInsets.all(10),
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (context) => NuevaPublicacion(
                            IDPerro: IDPerro,
                          )
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 8),
                        Text(
                          "Nueva publicación",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Publicaciones
              if (IDPerro != null) ...[
                Publicacion(
                  TipoPub: 'General',
                  TextoPub: 'Le di su desayuno hoy a las 7am, se lo comió todo muy rápido! Le noté la cola moviéndose sin parar :)',
                  IDPerro: perros[int.parse(IDPerro!)][1],
                ),
              ],
              if (IDPerro != null) ...[
                Publicacion(
                  TipoPub: 'Alimentación',
                  IDPerro: perros[int.parse(IDPerro!)][1],
                  users: users,
                  comida: const ['500 gr', 'croquetas'],
                  tiempo: const ['hoy', '12:43'],
                ),

                Publicacion(
                  TipoPub: 'Estado Médico',
                  IDPerro: perros[int.parse(IDPerro!)][1],
                  users: users,
                  procedimiento: 'desparasitación',
                  tiempo: const ['hoy', '10:07'],
                ),
              ],


              Card(
                margin: const EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(),
                              Padding(
                                padding: EdgeInsets.only(left: 10,),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Carlos Méndez',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '@carlosm   Hace 3 horas',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromRGBO(56, 54, 53, .5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.more_horiz),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 10,),

                      child: Text(
                        'Fuimos a dar una vuelta al patio. Estuvo jugando con unos estudiantes de primer año ¡La pasó muy bien!',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Image.asset('fotos/patiousm.jpg'),
                    const Divider(
                      thickness: 1.1,
                    ),
                    const BarraAcciones(
                      IDPublicacion: 'hola',
                    ),
                  ],
                ),
              ),

              Card(
                margin: const EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(),
                              Padding(
                                padding: EdgeInsets.only(left: 10,),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Sofía Ramos',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '@sofiar   Hace 5 horas',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromRGBO(56, 54, 53, .5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.more_horiz),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 20,),
                      // Se quitó el Flexible de aquí
                      child: Text(
                        'Revisé su zona de descanso y la encontré limpia. Le puse agua fresca. Sigue de buen humor hoy!',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 1.1,
                    ),
                    const BarraAcciones(
                      IDPublicacion: 'hola',
                    ),
                  ],
                ),
              ),

              if (IDPerro != null) ...[
                Publicacion(
                  TipoPub: 'Alimentación',
                  IDPerro: perros[int.parse(IDPerro!)][1],
                  users: users,
                  comida: const ['500 gr', 'croquetas'],
                  tiempo: const ['ayer', '22:14'],
                ),
              ],

              Card(
                margin: const EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(),
                              Padding(
                                padding: EdgeInsets.only(left: 10,),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Carlos Méndez',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '@carlosm   Ayer, 21:37',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromRGBO(56, 54, 53, .5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.more_horiz),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 20,),
                      // Se quitó el Flexible de aquí
                      child: Text(
                        'Cena registrada: 2 puñados de croquetas secas. Lo noté un poco menos activo que de costumbre al final del día, pero sin ningún síntoma preocupante. Lo dejo anotado por si acaso.',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Divider(
                      thickness: 1.1,
                    ),
                    const BarraAcciones(
                      IDPublicacion: 'hola',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}