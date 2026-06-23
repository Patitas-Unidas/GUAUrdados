import 'package:flutter/material.dart';

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
      body: Padding(
        padding: EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 20,),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Primera fila con botón de regreso, nombre del foro, actualizaciones y botón de emergencia
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
                              '5 actualizaciones',
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


            ],
          ),
        ),
      ),
    );
  }
}