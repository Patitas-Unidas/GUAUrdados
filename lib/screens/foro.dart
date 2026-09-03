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
      backgroundColor: Color.fromRGBO(249, 240, 235, 1),
      body: Padding(
        padding: EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 20,),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Botón de regreso, nombre del foro, actualizaciones y botón de emergencia
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: Icon(Icons.arrow_back),
                        iconSize: 20,
                        color: Colors.grey,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (IDPerro == null) ...[
                              Text(
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
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            Text(
                              '4 actualizaciones',
                              style: TextStyle(
                                color: Color.fromRGBO(56, 54, 53, .5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Color.fromRGBO(255, 0, 55, 1),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Emergencia',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Segunda fila con usuarios suscritos
              Padding(
                padding: EdgeInsets.only(top: 15,),
                child: Row(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      color: Colors.white,
                      child: SizedBox(
                        width: 110,
                        height: 45,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              CircleAvatar(),
                              Text(users[0]),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      color: Colors.white,
                      child: SizedBox(
                        width: 120,
                        height: 45,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              CircleAvatar(),
                              Text(users[1]),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      color: Colors.white,
                      child: SizedBox(
                        width: 110,
                        height: 45,
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            children: [
                              CircleAvatar(),
                              Text(users[2]),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Linea horizontal
              Divider(
                height: 30,
                thickness: 1,
                color: Color.fromRGBO(56, 54, 53, .3),
              ),

              // Botón nueva publicación
              Card(
                margin: EdgeInsets.all(10),
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
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
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
              Publicacion(
                TipoPub: 'General',
                IDPerro: perros[int.parse(IDPerro!)][1],
                IDUsuario: ['María González', '@mariag'],
                TextoPub: 'Le di su desayuno hoy a las 7am, se lo comió todo muy rápido! Le noté la cola moviéndose sin parar :)',
              ),

              if (IDPerro != null || IDPerro!.isNotEmpty) ...[
                Publicacion(
                  TipoPub: 'Alimentación',
                  IDPerro: perros[int.parse(IDPerro!)][1],
                  IDUsuario: ['María González', '@mariag'],
                  comida: ['500 gr', 'croquetas'],
                  tiempo: ['hoy', '12:43'],
                ),

                Publicacion(
                  TipoPub: 'Estado Médico',
                  IDPerro: perros[int.parse(IDPerro!)][1], 
                  IDUsuario: ['Sofía Ramos', '@sofiar'],
                  procedimiento: 'desparasitación',
                  tiempo: ['hoy', '10:07'],
                ),
              ],
              

              Card(
                margin: EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
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
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 10,),
                      child: Flexible(
                        child: Text(
                          'Fuimos a dar una vuelta al patio. Estuvo jugando con unos estudiantes de primer año ¡La pasó muy bien!',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Image.asset('fotos/patiousm.jpg'),
                    Divider(
                      thickness: 1.1,
                    ),
                    BarraAcciones(
                      IDPublicacion: 'hola',
                      IDUsuario: ['Carlos Méndez', '@carlosm'],
                    ),
                  ],
                ),
              ),

              Card(
                margin: EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
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
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 20,),
                      child: Flexible(
                        child: Text(
                          'Revisé su zona de descanso y la encontré limpia. Le puse agua fresca. Sigue de buen humor hoy!',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1.1,
                    ),
                    BarraAcciones(
                      IDPublicacion: 'hola',
                      IDUsuario: ['Sofía Ramos', '@sofiar'],
                    ),
                  ],
                ),
              ),

              if (IDPerro != null || IDPerro!.isNotEmpty) ...[
                Publicacion(
                  TipoPub: 'Alimentación',
                  IDPerro: perros[int.parse(IDPerro!)][1],
                  IDUsuario: ['María González', '@mariag'],
                  comida: ['500 gr', 'croquetas'],
                  tiempo: ['ayer', '22:14'],
                ),
              ],

              Card(
                margin: EdgeInsets.all(10),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
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
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 20,),
                      child: Flexible(
                        child: Text(
                          'Cena registrada: 2 puñados de croquetas secas. Lo noté un poco menos activo que de costumbre al final del día, pero sin ningún síntoma preocupante. Lo dejo anotado por si acaso.',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      thickness: 1.1,
                    ),
                    BarraAcciones(
                      IDPublicacion: 'hola',
                      IDUsuario: ['Carlos Méndez', '@carlosm'],
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