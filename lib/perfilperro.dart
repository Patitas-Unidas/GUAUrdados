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
      ['0', 'Scooby', 'Saludable'],
      ['1', 'Bobby', 'Necesita atención'],
      ['2', 'Ramón', 'Saludable'],
      ['3', 'Ramona', 'Saludable'],
      ['4', 'Mora', 'Necesita atención'],
      ['5', 'Tommy', 'Saludable'],
      ['6', 'Romeo', 'Necesita atención'],
      ['7', 'Lobito', 'Saludable']
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

              // Botón editar
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment(.98, 0),
                  child: IconButton.filledTonal(
                    icon: Icon(Icons.edit),
                    iconSize: 20,
                    color: Colors.grey,
                    onPressed: () {},
                  ),
                ),
              ),

              // Burbuja estado perro
              Padding(
                padding: EdgeInsets.only(top: 295),
                child: Align(
                  alignment: Alignment(0, 0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: null,
                    child: Builder(
                      builder: (context) {
                        if (perros[int.parse(IDPerro)][2] == 'Saludable') {
                          return Text(
                            perros[int.parse(IDPerro)][2],
                            style: TextStyle(
                              color: Color.fromRGBO(76, 175, 130, 1),
                              fontSize: 12,
                            ),
                          );
                        }
                        return Text(
                          perros[int.parse(IDPerro)][2],
                          style: TextStyle(
                            color: Color.fromRGBO(255, 149, 0, 1),
                            fontSize: 12,
                          ),
                        );
                      }
                    ),
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
      ['0', 'Scooby', 'Hace 10 minutos', 'Saludable', 'Mestizo', '3 años', '40 kg', '07:30', 'Grande', 'Vacunado', 'Tiene cama, da la patita, sabe sentarse para pedir premios, le gusta poner cara de penita y está en hogar temporal.', 'Cariñoso'],
      ['1', 'Bobby', 'Hace 1 hora', 'Necesita atención', 'Mestizo', '2-3 años', '33,9 kg', '13:45', 'Grande', 'No vacunado', 'Responde a órdenes básicas, está con terapia de conducta y medicación (fluoxetina 20 mg), muy regalón.', 'Cariñoso'],
      ['2', 'Ramón', 'Hace 15 minutos', 'Saludable', 'Mestizo', '3-4 años', '30 kg', '09:24', 'Grande', 'Vacunado', 'Obediente y regalón, con terapia de conducta y medicación (fluoxetina 20 mg), no le gusta estar solo.', 'Gruñón'],
      ['3', 'Ramona', 'Hace 4 horas', 'Saludable', 'Mestiza', '2 años', '25 kg', '15:34', 'Mediana', 'No vacunada', 'Juguetona y regalona, territorial, corretea perros nuevos, muestra la guatita cuando hace travesuras, necesita adopción responsable.', 'Gruñona'],
      ['4', 'Mora', 'Hace 6 horas', 'Necesita atención', 'Mestiza', 'Menos de 2 años', '25 kg', '22:54', 'Mediana', 'No vacunada', 'Amorosa, tranquila y sociable; llora si otros perros pelean, no juega brusco, se porta bien y convive con gatos y perros.', 'Cariñosa'],
      ['5', 'Tommy', 'Hace 10 minutos', 'Saludable', 'Mestizo', '4-5 años', '25 kg', '18:17', 'Mediano', 'Vacunado', 'Obedece órdenes, amoroso, cariñoso y sociable; no pelea, convive con perros y gatos, tranquilo y protector. Desparasitación pendiente.', 'Agresivo'],
      ['6', 'Romeo', 'Hace 1 hora', 'Necesita atención', 'Mestizo', '7-8 años', '30 kg', '08:38', 'Grande', 'Vacunado', 'Muy amoroso y sociable, aunque independiente; se porta bien encerrado y convive con otros perros. Adopción responsable.', 'Cariñoso'],
      ['7', 'Lobito', 'Hace 15 minutos', 'Saludable', 'Mestizo', '10 años', '25 kg', '11:23', 'Mediano', 'No vacunado', 'Muy lindo y cariñoso, obediente, disfruta pasear sin correa y busca un hogar para sus últimos años. Desparasitación pendiente.', 'Agresivo']
    ];

    return Padding(
      padding: EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primera fila de la columna de datos / Nombre y botón seguir
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5,),
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
                          'Seguir',
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

          // Segunda fila de la columna de datos / Cards con datos
          Padding(
            padding: EdgeInsets.only(top: 15, left: 8, right: 8,),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Última comida
                Card(
                  shadowColor: Colors.transparent,
                  color: Colors.white,
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flatware,
                                size: 30,
                              ),
                              Flexible(child: Text('Última comida:'))
                            ],
                          ),
                          Text(
                            perros[int.parse(IDPerro)][7],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            perros[int.parse(IDPerro)][2],
                            style: TextStyle(
                              fontSize: 11,
                              color: Color.fromRGBO(56, 54, 53, .5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Peso
                Card(
                  shadowColor: Colors.transparent,
                  color: Colors.white,
                  child: SizedBox(
                    width: 110,
                    height: 110,
                    child: Padding(
                      padding: EdgeInsets.only(top: 15, left: 12, right: 12,),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.scale,
                                size: 27,
                              ),
                              Text('Peso:')
                            ],
                          ),
                          Text(
                            perros[int.parse(IDPerro)][6],
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            perros[int.parse(IDPerro)][8],
                            style: TextStyle(
                              fontSize: 11,
                              color: Color.fromRGBO(56, 54, 53, .5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Caracter
                if (perros[int.parse(IDPerro)][11] == 'Cariñoso' || perros[int.parse(IDPerro)][11] == 'Cariñosa') ...[
                  Card(
                    shadowColor: Colors.transparent,
                    color: Color.fromRGBO(198, 220, 204, 1),
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              color: Color.fromRGBO(76, 175, 130, 1),
                              size: 50,
                            ),
                            Text(
                              perros[int.parse(IDPerro)][11],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(76, 175, 130, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]
                else if (perros[int.parse(IDPerro)][11] == 'Gruñón' || perros[int.parse(IDPerro)][11] == 'Gruñona') ...[
                  Card(
                    shadowColor: Colors.transparent,
                    color: Color.fromRGBO(251, 213, 165, 1),
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Color.fromRGBO(255, 149, 0, 1),
                              size: 50,
                            ),
                            Text(
                              perros[int.parse(IDPerro)][11],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(255, 149, 0, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ]
                else if (perros[int.parse(IDPerro)][11] == 'Agresivo' || perros[int.parse(IDPerro)][11] == 'Agresiva') ...[
                  Card(
                    shadowColor: Colors.transparent,
                    color: Color.fromRGBO(251, 168, 182, 1),
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Column(
                          children: [
                            Icon(
                              Icons.do_not_disturb_alt,
                              color: Color.fromRGBO(255, 0, 55, 1),
                              size: 50,
                            ),
                            Text(
                              perros[int.parse(IDPerro)][11],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color.fromRGBO(255, 0, 55, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ]
              ],
            ),
          ),

          // Tercera fila de la columna de datos / Vacunación
          Padding(
            padding: EdgeInsets.only(top: 8, left: 5),
            child: Row(
              children: [
                if (perros[int.parse(IDPerro)][9] == 'Vacunado' || perros[int.parse(IDPerro)][9] == 'Vacunada') ...[
                  Icon(
                    Icons.check,
                    color: Color.fromRGBO(76, 175, 130, 1),
                  ),
                  Text(
                    perros[int.parse(IDPerro)][9],
                    style: TextStyle(
                      color: Color.fromRGBO(76, 175, 130, 1),
                      fontSize: 20,
                    ),
                  ),
                ]
                else ...[
                  Icon(
                    Icons.close,
                    color: Color.fromRGBO(255, 0, 55, 1),
                  ),
                  Text(
                    perros[int.parse(IDPerro)][9],
                    style: TextStyle(
                      color: Color.fromRGBO(255, 0, 55, 1),
                      fontSize: 20,
                    ),
                  ),
                ]
              ],
            ),
          ),

          // Cuarta fila de la columna de datos / Bio
          Padding(
            padding: EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 20,),
            child: Flexible(
              child: Text(
                perros[int.parse(IDPerro)][10],
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),

          // Quinta fila de la columna de datos / Botones
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                // Botón Registrar Alimentación
                ElevatedButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Color.fromRGBO(222, 79, 65, 1),
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flatware,
                        color: Colors.white,
                        size: 28,

                      ),
                      Text(
                        'Registrar Alimentación',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(padding: EdgeInsets.only(top: 12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botón Estado Médico
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromRGBO(31, 179, 156, 1),
                        padding: EdgeInsets.only(top: 15, bottom: 15, left: 15, right: 15,),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_open_outlined,
                            color: Colors.white,
                            size: 28,

                          ),
                          Text(
                            'Estado Médico',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Botón Foro
                    ElevatedButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromRGBO(235, 185, 175, 1),
                        padding: EdgeInsets.only(top: 15, bottom: 15, left: 58, right: 58,),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 28,

                          ),
                          Text(
                            'Foro',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}