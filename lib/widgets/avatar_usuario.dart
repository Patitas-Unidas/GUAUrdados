import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/widgets/imagen_remota.dart';

const fotosPerfilPredeterminadas = [
  'https://firebasestorage.googleapis.com/v0/b/guaurdados.firebasestorage.app/o/fotoPerfil%2Fperfil_default.png?alt=media&token=af8a3d31-1cfa-42f1-88c1-f3fb294a02e3',
  'https://firebasestorage.googleapis.com/v0/b/guaurdados.firebasestorage.app/o/fotoPerfil%2Fperfil_default_2.png?alt=media&token=e184a401-7c95-4788-a47d-3737ffca6262',
  'https://firebasestorage.googleapis.com/v0/b/guaurdados.firebasestorage.app/o/fotoPerfil%2Fperfil_default_3.png?alt=media&token=a3b2422e-3361-43e7-8efc-6b785c6c703c',
  'https://firebasestorage.googleapis.com/v0/b/guaurdados.firebasestorage.app/o/fotoPerfil%2Fperfil_default_4.png?alt=media&token=bc032c59-4b51-4ad5-bf5f-47136f0ca4c4',
  'https://firebasestorage.googleapis.com/v0/b/guaurdados.firebasestorage.app/o/fotoPerfil%2Fperfil_default_5.png?alt=media&token=57ea9f91-0e31-44b8-8ef5-fe8da7c3dfdf',
];

String fotoPerfilPredeterminada(String? uid) {
  final semilla = (uid ?? '').codeUnits.fold(0, (suma, unidad) => (suma * 31 + unidad) & 0x7fffffff);
  return fotosPerfilPredeterminadas[semilla % fotosPerfilPredeterminadas.length];
}

class AvatarUsuario extends StatelessWidget {
  const AvatarUsuario({super.key, this.uid, this.fotoUrl, this.nombre, this.radio = 22});

  final String? uid;
  final String? fotoUrl;
  final String? nombre;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final foto = fotoUrl?.trim();
    return CircleAvatar(
      radius: radio,
      backgroundColor: c.fondoAvatar,
      child: ClipOval(
        child: SizedBox.square(
          dimension: radio * 2,
          child: ImagenRemota(
            url: foto == null || foto.isEmpty ? fotoPerfilPredeterminada(uid) : foto,
            fit: BoxFit.cover,
            cargando: const BloqueEsqueleto(circular: true),
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
