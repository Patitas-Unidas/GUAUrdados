import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/screens/camara.dart';
import 'package:guaurdados_oficial/services/notificaciones_service.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/app_colors.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/widgets/imagen_remota.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

import 'configuracion.dart';
import 'iniciar_sesion.dart';
import 'perfilperro.dart';

const _fotoPerfilDefault = 'https://firebasestorage.googleapis.com/v0/b/guaurdados.firebasestorage.app/o/fotoPerfil%2Fperfil_default.png?alt=media&token=af8a3d31-1cfa-42f1-88c1-f3fb294a02e3';

class PerfilUsuario extends StatelessWidget{
  const PerfilUsuario({super.key});

  @override
  Widget build(BuildContext context){
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.fondo,
      bottomNavigationBar: const _BarraPerfilUsuario(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
          child: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            initialData: FirebaseAuth.instance.currentUser,
            builder: (context, snapshot) {
              final usuario = snapshot.data;
              final nombre = usuario?.displayName;
              final tieneNombre = nombre != null && nombre.isNotEmpty;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: enCascada([
                  Center(child: _Avatar(foto: usuario?.photoURL)),
                  const SizedBox(height: 14),
                  Text(
                    tieneNombre ? nombre : 'Nombre de usuario',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800).display,
                  ),
                  if (usuario?.email != null)
                    Text(usuario!.email!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: c.textoTenue)),
                  const SizedBox(height: 22),

                  Row(children: [
                    Expanded(child: _Estadistica(icono: Iconos.pawPrint, color: c.acento, valor: '12', etiqueta: 'Perros ayudados')),
                    const SizedBox(width: 10),
                    Expanded(child: _Estadistica(icono: Iconos.notebookPen, color: c.exitoTexto, valor: '47', etiqueta: 'Registros')),
                    const SizedBox(width: 10),
                    Expanded(child: _Estadistica(icono: Iconos.flame, color: c.emergencia, valor: '9 días', etiqueta: 'Racha activa')),
                  ]),

                  const _TituloSeccion('Patitas que sigues'),
                  if (usuario != null) _PerrosSeguidos(uid: usuario.uid),

                  const _TituloSeccion('Actividad reciente'),
                  _Actividad(icono: Iconos.utensils, color: c.acento, titulo: 'Registraste alimentación para Scooby', cuando: 'Hace 2 horas'),
                  _Actividad(icono: Iconos.utensils, color: c.acento, titulo: 'Registraste alimentación para Mora', cuando: 'Hace 3 horas'),
                  _Actividad(icono: Iconos.messageCircle, color: AppColors.azulAgua, titulo: 'Publicaste en el foro de Ramón', cuando: 'Ayer, 14:37'),
                  _Actividad(icono: Iconos.stethoscope, color: c.medico, titulo: 'Registraste estado médico de Scooby', cuando: 'Hace 2 días'),

                  Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: c.divisor)),
                  _Opcion(
                    icono: Iconos.settings,
                    texto: 'Configuración',
                    alTocar: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Configuracion())),
                  ),
                  _Opcion(
                    icono: Iconos.logOut,
                    texto: 'Cerrar sesión',
                    color: c.emergencia,
                    alTocar: () => _cerrarSesion(context),
                  ),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      try {
        await NotificacionesService.desregistrar().timeout(const Duration(seconds: 3));
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const IniciarSesion()),
        (route) => false,
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo cerrar la sesión.')));
      }
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.foto});
  final String? foto;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.superficie,
        shape: BoxShape.circle,
        boxShadow: const [BoxShadow(color: Color(0x1f000000), blurRadius: 14, offset: Offset(0, 4))],
      ),
      child: ClipOval(
        child: ColoredBox(
          color: c.contenedor,
          child: ImagenRemota(
            url: foto == null || foto!.isEmpty ? _fotoPerfilDefault : foto!,
            fit: BoxFit.cover,
            cargando: const BloqueEsqueleto(circular: true),
            error: Icono(Iconos.user, size: 40, color: c.textoTenue),
          ),
        ),
      ),
    );
  }
}

class _Estadistica extends StatelessWidget {
  const _Estadistica({required this.icono, required this.color, required this.valor, required this.etiqueta});
  final IconData icono;
  final Color color;
  final String valor;
  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: Formas.fondo(c.superficie, 18),
      child: Column(children: [
        Container(
          width: 36,
          height: 36,
          decoration: Formas.fondo(color.withValues(alpha: .12), 11),
          child: Icono(icono, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        FittedBox(fit: BoxFit.scaleDown, child: Text(valor, maxLines: 1, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800).display)),
        FittedBox(fit: BoxFit.scaleDown, child: Text(etiqueta, maxLines: 1, style: TextStyle(fontSize: 12, color: c.textoTenue))),
      ]),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 24, 2, 10),
    child: Text(texto, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700).display),
  );
}

class _PerrosSeguidos extends StatelessWidget {
  const _PerrosSeguidos({required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return StreamBuilder<List<Perro>>(
      stream: PerrosRepository().observarPerrosSeguidos(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SizedBox(
            height: 96,
            child: Row(children: [
              for (var i = 0; i < 4; i++)
                const Padding(padding: EdgeInsets.only(right: 14), child: BloqueEsqueleto(ancho: 64, alto: 64, circular: true)),
            ]),
          );
        }
        final perros = snapshot.data!;
        if (perros.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: Formas.fondo(c.superficie, 16),
            child: Row(children: [
              Icono(Iconos.pawPrint, color: c.acento),
              const SizedBox(width: 10),
              Expanded(child: Text('Aún no sigues a ningún perrito. Toca "Seguir" en su perfil.', style: TextStyle(fontSize: 13, color: c.textoSecundario))),
            ]),
          );
        }
        return SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: perros.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) => Presionable(
              child: GestureDetector(
                onTap: () => Navigator.push(context, PerfilPerro.ruta(perros[i])),
                child: SizedBox(
                  width: 68,
                  child: Column(children: [
                    _FotoCircular(perro: perros[i]),
                    const SizedBox(height: 6),
                    Text(perros[i].nombre, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FotoCircular extends StatelessWidget {
  const _FotoCircular({required this.perro});
  final Perro perro;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final vacio = ColoredBox(color: c.contenedor, child: Icono(Iconos.pawPrint, color: c.textoTenue));
    final imagen = perro.fotoUrl.isNotEmpty
        ? ImagenRemota(url: perro.fotoUrl, fit: BoxFit.cover, alignment: perro.encuadre, cargando: const BloqueEsqueleto(circular: true), error: vacio)
        : perro.imagenAsset.isNotEmpty
            ? Image.asset('fotos/${perro.imagenAsset}', fit: BoxFit.cover, alignment: perro.encuadre, errorBuilder: (_, _, _) => vacio)
            : vacio;
    return Container(
      width: 64,
      height: 64,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(color: c.acento, shape: BoxShape.circle),
      child: ClipOval(child: imagen),
    );
  }
}

class _Actividad extends StatelessWidget {
  const _Actividad({required this.icono, required this.color, required this.titulo, required this.cuando});
  final IconData icono;
  final Color color;
  final String titulo;
  final String cuando;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: Formas.fondo(c.superficie, 16),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: Formas.fondo(color.withValues(alpha: .12), 12),
          child: Icono(icono, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(cuando, style: TextStyle(fontSize: 12, color: c.textoTenue)),
          ]),
        ),
      ]),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({required this.icono, required this.texto, required this.alTocar, this.color});
  final IconData icono;
  final String texto;
  final VoidCallback alTocar;
  final Color? color;

  @override
  Widget build(BuildContext context) => InkWell(
    customBorder: Formas.squircle(12),
    onTap: alTocar,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(children: [
        Icono(icono, size: 24, color: color ?? context.colores.textoSecundario),
        const SizedBox(width: 12),
        Text(texto, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color)),
      ]),
    ),
  );
}

class _BarraPerfilUsuario extends StatelessWidget {
  const _BarraPerfilUsuario();

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return SizedBox(
    height: 86,
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(color: c.navegacion),
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                tooltip: 'Inicio',
                onPressed: () => Navigator.pop(context),
                icon: Icono(Iconos.house, color: c.textoSecundario, size: 31),
              ),
              const SizedBox(width: 48),
              Icono(Iconos.user, color: c.acento, size: 31),
            ],
          ),
        ),
        Positioned(
          top: -20,
          child: InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const Camara()),
              ),
            child: Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(color: c.acento, shape: BoxShape.circle),
              child: Icono(Iconos.camera, color: c.sobreAcento, size: 31),
            ),
          ),
        ),
      ],
    ),
  );
  }
}
