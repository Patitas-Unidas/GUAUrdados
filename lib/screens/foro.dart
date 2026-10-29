import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/screens/reportar_emergencia.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'nuevapublicacion.dart';
import 'componentesforo.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

class Foro extends StatelessWidget {
  const Foro({
    super.key,
    this.IDPerro,
    this.nombrePerro,
  });
  final String? IDPerro;
  final String? nombrePerro;

  @override
  Widget build(BuildContext context) {
    var users = ['María G.', 'Carlos M.', 'Sofía R.'];
    final c = context.colores;

    return Scaffold(
      backgroundColor: c.fondo,
      body: Padding(
        padding: EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 20,),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: enCascada([
              // Botón de regreso, nombre del foro, actualizaciones y botón de emergencia
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: Icono(Iconos.chevronLeft),
                        iconSize: 20,
                        color: c.textoTenue,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (nombrePerro == null) ...[
                              Text(
                                'Foro',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ).display,
                              ),
                            ]
                            else ...[
                              Text(
                                'Foro de $nombrePerro',
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w600,
                                ).display,
                              ),
                            ],
                            Text(
                              '4 actualizaciones',
                              style: TextStyle(
                                color: c.textoTenue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: TextButton.styleFrom(
                      backgroundColor: c.emergencia,
                    ),
                    onPressed: () => ReportarEmergencia.mostrar(
                    context,
                    idPerro: IDPerro,
                    nombrePerro: nombrePerro,
                  ),
                    child: Text(
                      'Emergencia',
                      style: TextStyle(
                        color: c.sobreAcento,
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
                      shape: Formas.squircle(25),
                      color: c.superficie,
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
                      shape: Formas.squircle(25),
                      color: c.superficie,
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
                      shape: Formas.squircle(25),
                      color: c.superficie,
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

              // Línea horizontal
              Divider(
                height: 30,
                thickness: 1,
                color: c.divisor,
              ),

              // Botón nueva publicación
              Presionable(
                child: Card(
                margin: EdgeInsets.all(10),
                color: c.superficie,
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
                        Icono(Iconos.plus),
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
              ),

              // Publicaciones
              if (nombrePerro != null) ...[
                Publicacion(
                  TipoPub: 'General',
                  IDPerro: nombrePerro!,
                  IDUsuario: ['María González', '@mariag'],
                  TextoPub: 'Le di su desayuno hoy a las 7am, ¡se lo comió todo muy rápido! Le noté la cola moviéndose sin parar :)',
                ),
                Publicacion(
                  TipoPub: 'Alimentación',
                  IDPerro: nombrePerro!,
                  IDUsuario: ['María González', '@mariag'],
                  comida: ['200 gr', 'croquetas'],
                  tiempo: ['hoy', '12:43'],
                ),
                Publicacion(
                  TipoPub: 'Estado médico',
                  IDPerro: nombrePerro!,
                  IDUsuario: ['Sofía Ramos', '@sofiar'],
                  procedimiento: 'desparasitación',
                  tiempo: ['hoy', '10:07'],
                ),
              ]
              else ...[
                Publicacion(
                  TipoPub: 'General',
                  IDPerro: '01',
                  IDUsuario: ['María González', '@mariag'],
                  TextoPub: 'Le di su desayuno hoy a las 7am, ¡se lo comió todo muy rápido! Le noté la cola moviéndose sin parar :)',
                ),
              ],
              
              Card(
                margin: EdgeInsets.all(10),
                color: c.superficie,
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
                                        color: c.textoTenue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icono(Iconos.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 10,),
                      child: Flexible(
                        child: Text(
                          'Fuimos a dar una vuelta al patio. Estuvo jugando con unos estudiantes de primer año. ¡La pasó muy bien!',
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
                      IDUsuario: ['Carlos Méndez', '@carlosm'],
                    ),
                  ],
                ),
              ),

              Card(
                margin: EdgeInsets.all(10),
                color: c.superficie,
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
                                        color: c.textoTenue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icono(Iconos.ellipsis),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15, right: 15, bottom: 20,),
                      child: Flexible(
                        child: Text(
                          'Revisé su zona de descanso y la encontré limpia. Le puse agua fresca. ¡Sigue de buen humor hoy!',
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
                      IDUsuario: ['Sofía Ramos', '@sofiar'],
                    ),
                  ],
                ),
              ),

              if (nombrePerro != null) ...[
                Publicacion(
                  TipoPub: 'Alimentación',
                  IDPerro: nombrePerro!,
                  IDUsuario: ['María González', '@mariag'],
                  comida: ['200 gr', 'croquetas'],
                  tiempo: ['ayer', '22:14'],
                ),
              ],

              Card(
                margin: EdgeInsets.all(10),
                color: c.superficie,
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
                                        color: c.textoTenue,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icono(Iconos.ellipsis),
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
                      IDUsuario: ['Carlos Méndez', '@carlosm'],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
