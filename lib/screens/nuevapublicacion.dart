import 'package:flutter/material.dart';

class NuevaPublicacion extends StatefulWidget{
  const NuevaPublicacion({
    super.key,
    this.IDPerro,
  });
  final String? IDPerro;

  @override
  State<NuevaPublicacion> createState() => _NuevaPublicacionState();
}

class _NuevaPublicacionState extends State<NuevaPublicacion> {
  List<String> _perros = ['Scooby', 'Bobby', 'Ramón', 'Ramona'];
  String? _perroSelec;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Color.fromRGBO(249, 240, 235, 1),
      body: Padding(
        padding: EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 20,),
        child: Column(
          children: [
            // Botón de regreso y título
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    "Nueva publicación",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ), 
                ),
              ],
            ),
            Divider(
              height: 10,
              thickness: 1,
              color: Color.fromRGBO(56, 54, 53, .3),
            ),

            // Card con información de qué foro se está usando y botón para agregar imágenes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  margin: EdgeInsets.all(5),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Foro",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        if (widget.IDPerro == null) ...[
                          Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: DropdownButton<String>(
                              hint: Text(
                                "Escoja un perrito",
                                style: TextStyle(color: Color.fromRGBO(56, 54, 53, 1), letterSpacing: -.2),
                              ),
                              value: _perroSelec,
                              items: _perros.map((perro) {
                                return DropdownMenuItem(
                                  value: perro,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 5, right: 5),
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundImage: AssetImage('fotos/$perro.jpg'),
                                        ),
                                      ),
                                      Text(perro),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (valor) {
                                setState(() {
                                  _perroSelec = valor;
                                });
                              },
                            ),
                          ),
                        ]
                        else ...[
                          Padding(
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundImage: AssetImage('fotos/${_perros[int.parse(widget.IDPerro!)]}.jpg'),
                            ),
                          ),
                          Text(
                            _perros[int.parse(widget.IDPerro!)],
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                Card(
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {},
                    child:  Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(Icons.add_a_photo),
                    ),
                  ),                
                ),
              ],
            ),

            // Cuadro de texto
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: Card(
                color: Colors.white,
                child: TextField(
                  autofocus: true,
                  keyboardType: TextInputType.multiline,
                  maxLines: 10,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    hintText: 'Escribe aquí' 
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
