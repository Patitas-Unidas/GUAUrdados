import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/services/perfiles_usuario_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/avatar_usuario.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

Future<void> elegirFotoPerfil(BuildContext context) => mostrarHoja<void>(context, builder: (_) => const _HojaAvatares());

String fotoPerfilActual(User? usuario) {
  final foto = usuario?.photoURL?.trim();
  return foto == null || foto.isEmpty ? fotoPerfilPredeterminada(usuario?.uid) : foto;
}

class _HojaAvatares extends StatefulWidget {
  const _HojaAvatares();

  @override
  State<_HojaAvatares> createState() => _HojaAvataresState();
}

class _HojaAvataresState extends State<_HojaAvatares> {
  late String _elegida = fotoPerfilActual(FirebaseAuth.instance.currentUser);
  bool _guardando = false;

  Future<void> _elegir(String foto) async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (_guardando || usuario == null) return;
    HapticFeedback.selectionClick();
    final anterior = _elegida;
    setState(() {
      _elegida = foto;
      _guardando = true;
    });
    try {
      await usuario.updatePhotoURL(foto);
      await usuario.reload();
      final actualizado = FirebaseAuth.instance.currentUser;
      if (actualizado != null) await PerfilesUsuarioRepository().sincronizar(actualizado);
      await Future<void>.delayed(const Duration(milliseconds: 380));
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _elegida = anterior;
        _guardando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo cambiar la foto. Inténtalo de nuevo.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
          child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12), decoration: Formas.fondo(c.divisor, 2)),
        ),
        Text('Tu foto de perfil', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800).display),
        const SizedBox(height: 4),
        Text('Elige la carita que más te guste.', style: TextStyle(fontSize: 13, color: c.textoSecundario)),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final (i, foto) in fotosPerfilPredeterminadas.indexed)
              Aparicion(
                indice: i,
                child: _OpcionAvatar(foto: foto, elegida: foto == _elegida, alTocar: () => _elegir(foto)),
              ),
          ],
        ),
      ]),
    );
  }
}

class _OpcionAvatar extends StatelessWidget {
  const _OpcionAvatar({required this.foto, required this.elegida, required this.alTocar});
  final String foto;
  final bool elegida;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Semantics(
      button: true,
      selected: elegida,
      label: 'Foto de perfil',
      child: Presionable(
        escala: .9,
        child: GestureDetector(
          onTap: alTocar,
          child: Stack(clipBehavior: Clip.none, children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: elegida ? c.acento : Colors.transparent, width: 3),
              ),
              child: AvatarUsuario(fotoUrl: foto, radio: 40),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: AnimatedScale(
                scale: elegida ? 1 : 0,
                duration: Duration(milliseconds: elegida ? 380 : 180),
                curve: elegida ? Curves.easeOutBack : Curves.easeIn,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(color: c.acento, shape: BoxShape.circle, border: Border.all(color: c.fondo, width: 2.5)),
                  child: Icono(Iconos.check, size: 14, color: c.sobreAcento),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
