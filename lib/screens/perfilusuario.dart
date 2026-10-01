import 'package:flutter/material.dart';

class PerfilUsuario extends StatelessWidget{
  const PerfilUsuario({super.key});

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: 30, left: 15, right: 15, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 30),
              child: Text(
                'Nombre de usuario',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800
                ),
              ),
            ),

            //Cuadrícula datos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  shadowColor: Colors.transparent,
                  color: Color.fromRGBO(249, 240, 235, 1),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.27,
                    height: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pets_outlined,
                          color: Color.fromRGBO(222, 79, 65, 1),
                        ),
                        Text(
                          '12',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 25
                          ),
                        ),
                        Text(
                          'Perros ayudados',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(56, 54, 53, .5),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  shadowColor: Colors.transparent,
                  color: Color.fromRGBO(249, 240, 235, 1),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.27,
                    height: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.feed_outlined,
                          color: Color.fromRGBO(76, 175, 130, 1),
                        ),
                        Text(
                          '47',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 25
                          ),
                        ),
                        Text(
                          'Registros',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(56, 54, 53, .5),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Card(
                  shadowColor: Colors.transparent,
                  color: Color.fromRGBO(249, 240, 235, 1),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.27,
                    height: 110,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.leaderboard,
                          color: Color.fromRGBO(255, 0, 55, 1),
                        ),
                        Text(
                          '9 días',
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 25
                          ),
                        ),
                        Text(
                          'Racha activa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(56, 54, 53, .5),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),

            //Actividad Reciente
            Padding(
              padding: EdgeInsets.only(top: 20, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Actividad Reciente',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Card(
              shadowColor: Colors.transparent,
              color: Color.fromRGBO(249, 240, 235, 1),
              child: ListTile(
                leading: Icon(Icons.flatware),
                title: Text('Registraste alimentación para Scooby.'),
                subtitle: Text('Hace 2 horas.'),
              ),
            ),
            Card(
              shadowColor: Colors.transparent,
              color: Color.fromRGBO(249, 240, 235, 1),
              child: ListTile(
                leading: Icon(Icons.flatware),
                title: Text('Registraste alimentación para Mora.'),
                subtitle: Text('Hace 3 horas.'),
              ),
            ),
            Card(
              shadowColor: Colors.transparent,
              color: Color.fromRGBO(249, 240, 235, 1),
              child: ListTile(
                leading: Icon(Icons.comment_outlined),
                title: Text('Publicaste en el foro de Ramón.'),
                subtitle: Text('Ayer a las 14:37 hrs.'),
              ),
            ),
            Card(
              shadowColor: Colors.transparent,
              color: Color.fromRGBO(249, 240, 235, 1),
              child: ListTile(
                leading: Icon(Icons.medical_information_outlined),
                title: Text('Registraste estado médico de Scooby.'),
                subtitle: Text('Hace 2 días.'),
              ),
            ),

            // Linea horizontal
            Divider(
              height: 30,
              thickness: 1,
              color: Color.fromRGBO(56, 54, 53, .3),
            ),

            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.settings,
                      size: 28,
                    ),
                  ),
                  Text(
                    'Configuración',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Icon(
                      Icons.logout,
                      size: 28,
                      color: Color.fromRGBO(255, 0, 55, 1),
                    ),
                  ),
                  Text(
                    'Cerrar sesión',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(255, 0, 55, 1),
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