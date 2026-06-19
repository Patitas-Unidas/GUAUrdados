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
      ['0', 'Scooby'],
      ['1', 'Bobby'],
      ['2', 'Ramón'],
      ['3', 'Ramona'],
      ['4', 'Mora'],
      ['5', 'Tommy'],
      ['6', 'Romeo'],
      ['7', 'Lobito']
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
      ['0', 'Scooby', 'Hace 10 minutos', 'Saludable', 'Mestizo', '3 años', '40 kg', '07:30', 'Grande', 'Vacunado', 'Tiene cama, da la patita, sabe sentarse para pedir premios, le gusta poner cara de penita y está en hogar temporal.'],
      ['1', 'Bobby', 'Hace 1 hora', 'Necesita atención', 'Mestizo', '2-3 años', '33,9 kg', '13:45', 'Grande', 'No vacunado', 'Responde a órdenes básicas, está con terapia de conducta y medicación (fluoxetina 20 mg), muy regalón.'],
      ['2', 'Ramón', 'Hace 15 minutos', 'Saludable', 'Mestizo', '3-4 años', '30 kg', '09:24', 'Grande', 'Vacunado', 'Obediente y regalón, con terapia de conducta y medicación (fluoxetina 20 mg), no le gusta estar solo.'],
      ['3', 'Ramona', 'Hace 4 horas', 'Saludable', 'Mestiza', '2 años', '25 kg', '15:34', 'Mediana', 'No vacunada', 'Juguetona y regalona, territorial, corretea perros nuevos, muestra la guatita cuando hace travesuras, necesita adopción responsable.'],
      ['4', 'Mora', 'Hace 6 horas', 'Necesita atención', 'Mestiza', 'Menos de 2 años', '25 kg', '22:54', 'Mediana', 'No vacunada', 'Amorosa, tranquila y sociable; llora si otros perros pelean, no juega brusco, se porta bien y convive con gatos y perros.'],
      ['5', 'Tommy', 'Hace 10 minutos', 'Saludable', 'Mestizo', '4-5 años', '25 kg', '18:17', 'Mediano', 'Vacunado', 'Obedece órdenes, amoroso, cariñoso y sociable; no pelea, convive con perros y gatos, tranquilo y protector. Desparasitación pendiente.'],
      ['6', 'Romeo', 'Hace 1 hora', 'Necesita atención', 'Mestizo', '7-8 años', '30 kg', '08:38', 'Grande', 'Vacunado', 'Muy amoroso y sociable, aunque independiente; se porta bien encerrado y convive con otros perros. Adopción responsable.'],
      ['7', 'Lobito', 'Hace 15 minutos', 'Saludable', 'Mestizo', '10 años', '25 kg', '11:23', 'Mediano', 'No vacunado', 'Muy lindo y cariñoso, obediente, disfruta pasear sin correa y busca un hogar para sus últimos años. Desparasitación pendiente.']
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Primera fila de la columna de datos / Nombre y botón
        Padding(
          padding: EdgeInsets.only(top: 12, left: 15, right: 15,),
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

        // Segunda fila de la columna de datos / Cards con datos
        Padding(
          padding: EdgeInsets.only(top: 15, left: 20, right: 20,),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                              Icons.food_bank_outlined,
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
              Card(
                shadowColor: Colors.transparent,
                color: Colors.white,
                child: SizedBox(
                  width: 110,
                  height: 110,
                ),
              ),
            ],
          ),
        ),
        
        // Tercera fila de la columna de datos / Vacunación
        Padding(
          padding: EdgeInsets.only(top: 8, left: 20),
          child: Row(
            children: [
              if (perros[int.parse(IDPerro)][9] == 'Vacunado' || perros[int.parse(IDPerro)][9] == 'Vacunada') ...[
                Icon(
                  Icons.check,
                  color: Colors.green,
                ),
                Text(
                  perros[int.parse(IDPerro)][9],
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                  ),
                ),
              ]
              else ...[
                Icon(
                  Icons.close,
                  color: Colors.red,
                ),
                Text(
                  perros[int.parse(IDPerro)][9],
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 20,
                  ),
                ),
              ]
            ],
          ),
        ),

        // Cuarta fila de la columna de datos / Bio
        Padding(
          padding: EdgeInsets.only(top: 10, left: 20, right: 20,),
          child: Flexible(
            child: Text(
              perros[int.parse(IDPerro)][10],
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}