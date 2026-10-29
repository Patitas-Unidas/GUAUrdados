import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/models/publicacion_foro.dart';
import 'package:guaurdados_oficial/screens/camara.dart';
import 'package:guaurdados_oficial/services/notificaciones_service.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/app_colors.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/widgets/imagen_remota.dart';
import 'package:guaurdados_oficial/widgets/avatar_usuario.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

import 'configuracion.dart';
import 'iniciar_sesion.dart';
import 'perfilperro.dart';

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

                  if (usuario != null) _ResumenUsuario(uid: usuario.uid),

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
      child: AvatarUsuario(fotoUrl: foto, radio: 48),
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

class _ResumenUsuario extends StatelessWidget {
  const _ResumenUsuario({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) => StreamBuilder<ResumenActividadForo>(
    stream: ForoRepository().observarResumenUsuario(uid),
    builder: (context, snapshot) {
      final c = context.colores;
      final resumen = snapshot.data;
      final recientes = resumen?.actividadReciente ?? const <PublicacionForo>[];
      final racha = resumen?.rachaDias;
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: _Estadistica(
              icono: Iconos.pawPrint,
              color: c.acento,
              valor: resumen?.perrosAyudados.toString() ?? '…',
              etiqueta: 'Perros ayudados',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Estadistica(
              icono: Iconos.notebookPen,
              color: c.exitoTexto,
              valor: resumen?.registros.toString() ?? '…',
              etiqueta: 'Registros',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Estadistica(
              icono: Iconos.flame,
              color: c.emergencia,
              valor: racha == null ? '…' : '$racha ${racha == 1 ? 'día' : 'días'}',
              etiqueta: 'Racha activa',
            ),
          ),
        ]),
        const _TituloSeccion('Patitas que sigues'),
        _PerrosSeguidos(uid: uid),
        const _TituloSeccion('Actividad reciente'),
        if (snapshot.hasError)
          const _ActividadVacia(texto: 'No se pudo cargar tu actividad reciente.')
        else if (!snapshot.hasData)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (recientes.isEmpty)
          const _ActividadVacia(texto: 'Todavía no tienes actividad registrada.')
        else
          ...recientes.map((publicacion) {
            final tipo = publicacion.tipoPublicacion;
            final esAlimentacion = tipo == 'alimentacion';
            final esMedico = tipo == 'estado_medico';
            final icono = esAlimentacion
                ? Iconos.utensils
                : esMedico
                    ? Iconos.stethoscope
                    : Iconos.messageCircle;
            final color = esAlimentacion
                ? c.acento
                : esMedico
                    ? c.medico
                    : AppColors.azulAgua;
            final titulo = esAlimentacion
                ? 'Registraste alimentación para ${publicacion.nombrePerro}'
                : esMedico
                    ? 'Actualizaste el estado médico de ${publicacion.nombrePerro}'
                    : 'Publicaste en el foro de ${publicacion.nombrePerro}';
            return _Actividad(
              icono: icono,
              color: color,
              titulo: titulo,
              cuando: _fechaActividad(publicacion.creadoEn),
            );
          }),
      ]);
    },
  );

  String _fechaActividad(DateTime? fecha) {
    if (fecha == null) return 'Recién';
    final diferencia = DateTime.now().difference(fecha);
    if (diferencia.inMinutes < 1) return 'Ahora';
    if (diferencia.inHours < 1) return 'Hace ${diferencia.inMinutes} min';
    if (diferencia.inDays < 1) {
      final horas = diferencia.inHours;
      return 'Hace $horas ${horas == 1 ? 'hora' : 'horas'}';
    }
    final hora = '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    if (diferencia.inDays == 1) return 'Ayer, $hora';
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')} · $hora';
  }
}

class _ActividadVacia extends StatelessWidget {
  const _ActividadVacia({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(texto, style: TextStyle(color: context.colores.textoTenue, fontSize: 13)),
    ),
  );
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
