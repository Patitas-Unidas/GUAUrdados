import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/screens/camara.dart';
import 'package:guaurdados_oficial/screens/listadoperros.dart';
import 'package:guaurdados_oficial/screens/perfilusuario.dart';

/// Base de la página de inicio
class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => HomepageBody();
}

/// Cuerpo de la página de inicio
class HomepageBody extends State<Homepage> {
  int _currentIndex = 0;
  final List<Widget> _screens = <Widget>[
    ListadoPerros(),
    Camara(),
    PerfilUsuario()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Appbar que va a tener el logo de la aplicación, el botón de notificaciones y el botón de emergencias general
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(238, 210, 195, 1),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'fotos/Letras.png',
              width: 180,
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 5),
                  child: IconButton.filledTonal(
                    icon: Icon(Icons.notifications),
                    iconSize: 20,
                    color: Colors.grey,
                    onPressed: () {},
                  ),
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
            )
          ],
        )
      ),

      // Cuerpo de la página principal
      body: _screens.elementAt(_currentIndex),

      // Bottom navbar con botones de inicio, cámara y perfil
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Color.fromRGBO(235, 185, 157, 1),
        selectedItemColor: Color.fromRGBO(222, 79, 65, 1),
        iconSize: 40,
        selectedFontSize: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            label: 'Camara',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}