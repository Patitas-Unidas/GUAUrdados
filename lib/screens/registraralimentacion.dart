import 'package:flutter/material.dart';

class RegistrarAlimentacion extends StatefulWidget {
  const RegistrarAlimentacion({
    super.key,
    required this.perro,
  });
  final String perro;

  @override
  State<RegistrarAlimentacion> createState() => _RegistrarAlimentacionState();
}

class _RegistrarAlimentacionState extends State<RegistrarAlimentacion> {
  int _currentSelectionAlimento = 0;
  int _currentSelectionTipoCantidad = 0;
  int punados = 1;
  int gramos = 50;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: new BoxDecoration(
        color: Color.fromRGBO(249, 240, 235, 1),
        borderRadius: new BorderRadius.only(
          topLeft: const Radius.circular(25.0),
          topRight: const Radius.circular(25.0),
        ),
      ),
      padding: EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título y línea divisora
          Column(
            children: [
              // Título
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.flatware,
                      size: 40,
                      color: Color.fromRGBO(222, 79, 65, 1),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registrar Alimentación',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.perro}',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color.fromRGBO(56, 54, 53, .5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Linea horizontal
              Divider(
                height: 30,
                thickness: 1,
                color: Color.fromRGBO(56, 54, 53, .3),
              ),
            ],
          ),

          //Tipo de alimento
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TIPO DE ALIMENTO',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(56, 54, 53, .5),
                ),
              ),
              NavigationBar(
                onDestinationSelected: (int index) {
                  setState(() {
                    _currentSelectionAlimento = index;
                  });
                },
                selectedIndex: _currentSelectionAlimento,
                indicatorColor: Colors.white,
                backgroundColor: Colors.transparent,
                destinations: const <Widget>[
                  NavigationDestination(
                    icon: Icon(
                      Icons.food_bank,
                      size: 40,
                    ),
                    label: 'Croquetas',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.restaurant,
                      size: 40,
                    ),
                    label: 'Comida húmeda',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.fastfood,
                      size: 40,
                    ),
                    label: 'Otro',
                  ),
                ],
              ),
              if(_currentSelectionAlimento == 2) ...[
                Card(
                  margin: EdgeInsets.all(10),
                  color: Colors.white,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 50,
                    child: TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          hintText: 'Escribe el tipo de alimento aquí.'
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          //Cantidad
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CANTIDAD APROXIMADA',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(56, 54, 53, .5),
                ),
              ),
              NavigationBar(
                onDestinationSelected: (int index) {
                  setState(() {
                    _currentSelectionTipoCantidad = index;
                  });
                },
                selectedIndex: _currentSelectionTipoCantidad,
                indicatorColor: Colors.white,
                backgroundColor: Colors.transparent,
                destinations: const <Widget>[
                  NavigationDestination(
                    icon: Icon(
                      Icons.handshake_outlined,
                      size: 40,
                    ),
                    label: 'Puñados',
                  ),
                  NavigationDestination(
                    icon: Icon(
                      Icons.scale,
                      size: 40,
                    ),
                    label: 'Gramos',
                  ),
                ],
              ),
              if(_currentSelectionTipoCantidad == 0) ...[
                Card(
                  color: Color.fromRGBO(247, 229, 220, 1),
                  shadowColor: Colors.transparent,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.18,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.remove),
                              iconSize: 25,
                              color: Color.fromRGBO(222, 79, 65, 1),
                              onPressed: () {
                                setState(() {
                                  if(punados != 1){
                                    punados--;
                                  }
                                });
                              },
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${punados}',
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(222, 79, 65, 1),
                                ),
                              ),
                              Text(
                                'puñados',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.add),
                              iconSize: 25,
                              color: Color.fromRGBO(222, 79, 65, 1),
                              onPressed: () {
                                setState(() {
                                  if(punados <= 9) {
                                    punados++;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]
              else ...[
                Card(
                  color: Color.fromRGBO(247, 229, 220, 1),
                  shadowColor: Colors.transparent,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.18,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.remove),
                              iconSize: 25,
                              color: Color.fromRGBO(222, 79, 65, 1),
                              onPressed: () {
                                setState(() {
                                  if(gramos > 25) {
                                    gramos-=25;
                                  }
                                });
                              },
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${gramos}',
                                style: TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromRGBO(222, 79, 65, 1),
                                ),
                              ),
                              Text(
                                'gramos',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.white,
                            child: IconButton(
                              icon: Icon(Icons.add),
                              iconSize: 25,
                              color: Color.fromRGBO(222, 79, 65, 1),
                              onPressed: () {
                                setState(() {
                                  if(gramos < 500) {
                                    gramos+=25;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          //Botón Guardar Registro
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: ElevatedButton(
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
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.flatware,
                      color: Colors.white,
                      size: 28,

                    ),
                  ),
                  Text(
                    'Guardar Registro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}