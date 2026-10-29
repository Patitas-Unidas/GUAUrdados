import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/widgets/imagen_remota.dart';

const fotoPerfilPredeterminada =
    'https://firebasestorage.googleapis.com/v0/b/guaurdados.firebasestorage.app/o/fotoPerfil%2Fperfil_default.png?alt=media&token=af8a3d31-1cfa-42f1-88c1-f3fb294a02e3';

class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({super.key, this.fotoUrl, this.nombre, this.radio = 22});

  final String? fotoUrl;
  final String? nombre;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final foto = fotoUrl?.trim();
    return CircleAvatar(
      radius: radio,
      backgroundColor: c.contenedor,
      child: ClipOval(
        child: SizedBox.square(
          dimension: radio * 2,
          child: ImagenRemota(
            url: foto == null || foto.isEmpty ? fotoPerfilPredeterminada : foto,
            fit: BoxFit.cover,
            error: Center(
              child: Text(
                _iniciales(nombre),
                style: TextStyle(color: c.texto, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _iniciales(String? nombre) {
    final partes = (nombre ?? 'U').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).take(2);
    final iniciales = partes.map((p) => p[0].toUpperCase()).join();
    return iniciales.isEmpty ? 'U' : iniciales;
  }
}
