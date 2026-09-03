import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/screens/nuevapublicacion.dart';

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
                TextoPub: 'Le di su desayuno hoy a las 7am, se lo comió todo muy rápido! Le noté la cola moviéndose sin parar :)',
              ),

              if (IDPerro != null) ...[
                ActualizacionComida(
                  IDPerro: perros[int.parse(IDPerro!)][1],
                  users: users,
                  comida: ['500 gr', 'croquetas'],
                  tiempo: ['hoy', '12:43'],
                ),

                ActualizacionEstadoMedico(
                  IDPerro: perros[int.parse(IDPerro!)][1], 
                  users: users, 
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
                    ),
                  ],
                ),
              ),

              if (IDPerro != null) ...[
                ActualizacionComida(
                  IDPerro: perros[int.parse(IDPerro!)][1],
                  users: users,
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

class ActualizacionComida extends StatelessWidget {
  const ActualizacionComida({
    super.key,
    required this.IDPerro,
    required this.users,
    required this.comida,
    required this.tiempo,
  });
  final String IDPerro;
  final List<String> users;
  final List<String> comida;
  final List<String> tiempo;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      color: Color.fromRGBO(222, 79, 65, 1),
      child: Padding(
        padding: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.flatware,
              color: Colors.white,
              size: 40,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡${users[0]} a registrado una nueva alimentación!',
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ), 
                  Padding(
                    padding: EdgeInsets.all(1),
                    child:  Expanded( 
                      child: Text(
                        'Se ha registrado que $IDPerro ha recibido ${comida[0]} de ${comida[1]} ${tiempo[0]} a las ${tiempo[1]}.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActualizacionEstadoMedico extends StatelessWidget {
  const ActualizacionEstadoMedico({
    super.key,
    required this.IDPerro,
    required this.users,
    required this.procedimiento,
    required this.tiempo,
  });
  final String IDPerro;
  final List<String> users;
  final String procedimiento;
  final List<String> tiempo;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      color: Color.fromRGBO(31, 179, 156, 1),
      child: Padding(
        padding: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              color: Colors.white,
              size: 40,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡${users[2]} ha actualizado el estado médico!',
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ), 
                  Padding(
                    padding: EdgeInsets.all(1),
                    child:  Expanded( 
                      child: Text(
                        'Se ha registrado que $IDPerro ha recibido el siguiente procedimiento ${tiempo[0]} a las ${tiempo[1]}: $procedimiento.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Publicacion extends StatelessWidget {
  const Publicacion({
    super.key,
    required this.TextoPub,
    this.ImagenPub,
  });
  final String TextoPub;
  final String? ImagenPub;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BarraUsuario(
            IDUsuario: 'hola',
          ),
          Padding(
            padding: EdgeInsets.only(left: 15, right: 15, bottom: 20,),
            child: Flexible(
              child: Text(
                TextoPub,
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
          ),
        ],
      ),
    );
  }
}

class BarraUsuario extends StatelessWidget {
  const BarraUsuario({
    super.key,
    required this.IDUsuario,
  });
  final String IDUsuario;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      'María González',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '@mariag   Hace 2 horas',
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
            child: InkWell(
              onTap: () {},
              child: Icon(Icons.more_horiz),
            ),
          ),
        ],
      ),
    );
  }
}

class BarraAcciones extends StatelessWidget {
  const BarraAcciones({
    super.key,
    required this.IDPublicacion,
  });
  final String IDPublicacion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 25, right: 25, bottom: 10,),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: Icon(
                          Icons.favorite_border,
                          color: Color.fromRGBO(56, 54, 53, .5),
                          size: 20,
                        ),
                      ),
                      Text(
                        '14',
                        style: TextStyle(
                          color: Color.fromRGBO(56, 54, 53, .5),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        color: Color.fromRGBO(56, 54, 53, .5),
                        size: 19,
                      ),
                    ),
                    Text(
                      '3',
                      style: TextStyle(
                        color: Color.fromRGBO(56, 54, 53, .5),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )
              
            ],
          ),

          InkWell(
            onTap: () {},
            child: Icon(
              Icons.emoji_emotions_outlined,
              color: Color.fromRGBO(56, 54, 53, .5),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}