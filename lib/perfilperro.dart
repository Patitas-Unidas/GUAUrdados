import 'package:flutter/material.dart';

class PerfilPerro extends StatelessWidget {
  const PerfilPerro({
    super.key,
    required this.IDPerro
  });
  final String IDPerro;

  @override
  Widget build(BuildContext context) {
    // Variables auxiliares mientras no se tiene la base de datos
    var perros = [
      ['0', 'Scooby', 'Hace 10 minutos', 'Saludable', 'Mestizo', '3 años', '40 kg'],
      ['1', 'Bobby', 'Hace 1 hora', 'Necesita atención', 'Mestizo', '2-3 años', '33,9 kg'],
      ['2', 'Ramón', 'Hace 15 minutos', 'Saludable', 'Mestizo', '3-4 años', '30 kg'],
      ['3', 'Ramona', 'Hace 4 horas', 'Saludable', 'Mestiza', '2 años', '25-30 kg'],
      ['4', 'Mora', 'Hace 6 horas', 'Necesita atención', 'Mestiza', 'Menos de 2 años', '25-30 kg'],
      ['5', 'Tommy', 'Hace 10 minutos', 'Saludable', 'Mestizo', '4-5 años', '25-30 kg'],
      ['6', 'Romeo', 'Hace 1 hora', 'Necesita atención', 'Mestizo', '7-8 años', '30 kg'],
      ['7', 'Lobito', 'Hace 15 minutos', 'Saludable', 'Mestizo', '10 años', '25 kg']
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              // Imagen del perro
              Container(
                padding: EdgeInsets.only(top: 0),
                child: Flexible(
                  child: Image.asset(
                    'fotos/${perros[int.parse(IDPerro)][1]}.jpg',
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),

              // Botón de regreso
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment(-.98, 0),
                  child: IconButton.filledTonal(
                    icon: Icon(Icons.arrow_back),
                    iconSize: 20,
                    color: Colors.grey,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // Fondo para los datos que contiene a la clase DatosPerro
              Padding(
                padding: EdgeInsets.only(top: 350),
                child: Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: Color.fromRGBO(249, 240, 235, 1),
                      height: 564,
                      child: DatosPerro(
                        IDPerro: IDPerro,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


/// Todos los datos del perro
class DatosPerro extends StatelessWidget {
  const DatosPerro({
    super.key,
    required this.IDPerro,
  });
  final String IDPerro;

  @override
  Widget build(BuildContext context){
    // Variables auxiliares mientras no se tiene la base de datos
    var perros = [
      ['0', 'Scooby', 'Hace 10 minutos', 'Saludable', 'Mestizo', '3 años', '40 kg'],
      ['1', 'Bobby', 'Hace 1 hora', 'Necesita atención', 'Mestizo', '2-3 años', '33,9 kg'],
      ['2', 'Ramón', 'Hace 15 minutos', 'Saludable', 'Mestizo', '3-4 años', '30 kg'],
      ['3', 'Ramona', 'Hace 4 horas', 'Saludable', 'Mestiza', '2 años', '25-30 kg'],
      ['4', 'Mora', 'Hace 6 horas', 'Necesita atención', 'Mestiza', 'Menos de 2 años', '25-30 kg'],
      ['5', 'Tommy', 'Hace 10 minutos', 'Saludable', 'Mestizo', '4-5 años', '25-30 kg'],
      ['6', 'Romeo', 'Hace 1 hora', 'Necesita atención', 'Mestizo', '7-8 años', '30 kg'],
      ['7', 'Lobito', 'Hace 15 minutos', 'Saludable', 'Mestizo', '10 años', '25 kg']
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primera fila de la columna de datos
        Padding(
          padding: EdgeInsets.only(top: 5, left: 15, right: 15,),
          // Row que contiene el nombre, raza, edad, última actualización y botón de seguido
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ítem que contiene los datos a la izquierda de la página
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del perro
                  Text(
                    perros[int.parse(IDPerro)][1],
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  // Raza y edad del perro
                  Text(
                    '${perros[int.parse(IDPerro)][4]} - ${perros[int.parse(IDPerro)][5]}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  // Ícono de reloj y última actualización del perro
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 15,
                        color: Color.fromRGBO(56, 54, 53, .5),
                      ),
                      Text(
                        'Última actualización: ${perros[int.parse(IDPerro)][2]}.',
                        style: TextStyle(
                          color: Color.fromRGBO(56, 54, 53, .5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Ítem que contiene el botón de seguido a la derecha de la página
              ElevatedButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
                onPressed: () {},
                child: Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Column(
                    children: [
                      Icon(
                        Icons.pets,
                        size: 35,
                        color: Colors.grey,
                      ),
                      Text(
                        'Seguido',
                        style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}