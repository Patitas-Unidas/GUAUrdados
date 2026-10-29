import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/screens/comentarios.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';

class Publicacion extends StatelessWidget {
  const Publicacion({
    super.key,
    required this.TipoPub,
    required this.IDPerro,
    required this.IDUsuario,
    this.TextoPub,
    this.ImagenPub,
    this.comida,
    this.procedimiento,
    this.tiempo,
  });
  final String TipoPub;
  final String IDPerro;
  final List<String> IDUsuario;
  final String? TextoPub;
  final String? ImagenPub;
  final List<String>? comida;
  final String? procedimiento;
  final List<String>? tiempo;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    if (TipoPub == 'Alimentación') {
      return ActualizacionComida(
        IDPerro: IDPerro,
        IDUsuario: IDUsuario,
        comida: comida!,
        tiempo: tiempo!,
      );
    }
    else if (TipoPub == 'Estado médico') {
      return ActualizacionEstadoMedico(
        IDPerro: IDPerro,
        IDUsuario: IDUsuario,
        procedimiento: procedimiento!,
        tiempo: tiempo!,
      );
    }
    else {
      return Card(
        margin: EdgeInsets.all(10),
        color: c.superficie,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BarraUsuario(
              IDUsuario: IDUsuario,
            ),
            Padding(
              padding: EdgeInsets.only(left: 15, right: 15, bottom: 20,),
              child: Flexible(
                child: Text(
                  TextoPub!,
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
              IDPublicacion: TextoPub!,
              IDUsuario: IDUsuario,
            ),
          ],
        ),
      );
    }
  }
}

class ActualizacionComida extends StatelessWidget {
  const ActualizacionComida({
    super.key,
    required this.IDPerro,
    required this.IDUsuario,
    required this.comida,
    required this.tiempo,
  });
  final String IDPerro;
  final List<String> IDUsuario;
  final List<String> comida;
  final List<String> tiempo;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Card(
      margin: EdgeInsets.all(10),
      color: c.acento,
      child: Padding(
        padding: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icono(
              Iconos.utensils,
              color: c.sobreAcento,
              size: 40,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡${IDUsuario[0]} ha registrado una nueva alimentación!',
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: c.sobreAcento,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ), 
                  Padding(
                    padding: EdgeInsets.all(1),
                    child:  Expanded( 
                      child: Text(
                        'Se ha registrado que $IDPerro ha recibido ${comida[0]} de ${comida[1]} ${tiempo[0]} a las ${tiempo[1]}.',
                        style: TextStyle(
                          color: c.sobreAcento,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
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

class ActualizacionEstadoMedico extends StatelessWidget {
  const ActualizacionEstadoMedico({
    super.key,
    required this.IDPerro,
    required this.IDUsuario,
    required this.procedimiento,
    required this.tiempo,
  });
  final String IDPerro;
  final List<String> IDUsuario;
  final String procedimiento;
  final List<String> tiempo;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Card(
      margin: EdgeInsets.all(10),
      color: c.medico,
      child: Padding(
        padding: EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icono(
              Iconos.stethoscope,
              color: c.sobreAcento,
              size: 40,
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡${IDUsuario[0]} ha actualizado el estado médico!',
                    overflow: TextOverflow.fade,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: c.sobreAcento,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ), 
                  Padding(
                    padding: EdgeInsets.all(1),
                    child:  Expanded( 
                      child: Text(
                        'Se ha registrado que $IDPerro ha recibido el siguiente procedimiento ${tiempo[0]} a las ${tiempo[1]}: $procedimiento.',
                        style: TextStyle(
                          color: c.sobreAcento,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
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

class BarraUsuario extends StatelessWidget {
  const BarraUsuario({
    super.key,
    required this.IDUsuario,
  });
  final List<String> IDUsuario;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Padding(
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
                      IDUsuario[0],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${IDUsuario[1]}   Hace 2 horas',
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
            child: InkWell(
              onTap: () {},
              child: Icono(Iconos.ellipsis),
            ),
          ),
        ],
      ),
    );
  }
}

class BarraAcciones extends StatelessWidget {
  const BarraAcciones({
    super.key,
    required this.IDPublicacion,
    required this.IDUsuario,
  });
  final String IDPublicacion;
  final List<String> IDUsuario;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Padding(
      padding: EdgeInsets.only(top: 5, left: 25, right: 25, bottom: 10,),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: 3),
                        child: Icono(
                          Iconos.heart,
                          color: c.textoTenue,
                          size: 20,
                        ),
                      ),
                      Text(
                        '14',
                        style: TextStyle(
                          color: c.textoTenue,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  mostrarHoja<void>(
                    context,
                    builder: (BuildContext context) {
                      return Comentarios(
                        IDComentario: [IDPublicacion],
                        IDUsuario: IDUsuario,
                      );
                    },
                  );
                },
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icono(
                        Iconos.messageCircle,
                        color: c.textoTenue,
                        size: 19,
                      ),
                    ),
                    Text(
                      '3',
                      style: TextStyle(
                        color: c.textoTenue,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )
              
            ],
          ),

          InkWell(
            onTap: () {},
            child: Icono(
              Iconos.smile,
              color: c.textoTenue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}