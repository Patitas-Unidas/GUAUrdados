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
      ['0', 'Scooby', 'Hace 10 minutos', 'Saludable'],
      ['1', 'Bobby', 'Hace 1 hora', 'Necesita atención'],
      ['2', 'Ramón', 'Hace 15 minutos', 'Saludable'],
      ['3', 'Ramona', 'Hace 4 horas', 'Saludable'],
      ['4', 'Mora', 'Hace 6 horas', 'Necesita atención'],
      ['5', 'Tommy', 'Hace 10 minutos', 'Saludable'],
      ['6', 'Romeo', 'Hace 1 hora', 'Necesita atención'],
      ['7', 'Lobito', 'Hace 15 minutos', 'Saludable']
    ];

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Container(
                padding: EdgeInsets.only(top: 0),
                height: 500,
                child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Image.asset('fotos/' + perros[int.parse(IDPerro)][1] + '.jpg'),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment(-1, 0),
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
            ],
          ),
        ],
      ),
    );
  }
}