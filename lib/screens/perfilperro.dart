import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/imagen_remota.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';

import 'carnet_veterinario.dart';
import 'foro.dart';
import 'registraralimentacion.dart';

/// Conserva el diseño de la plantilla, pero todos sus valores vienen desde
/// el documento correspondiente de Firestore.
class PerfilPerro extends StatelessWidget {
  const PerfilPerro({super.key, required this.idPerro, PerrosRepository? perrosRepository})
      : _repository = perrosRepository;

  final String idPerro;
  final PerrosRepository? _repository;

  @override
  Widget build(BuildContext context) => StreamBuilder<Perro?>(
    stream: (_repository ?? PerrosRepository()).observarPerro(idPerro),
    builder: (context, snapshot) {
      if (snapshot.hasError) return Scaffold(body: Center(child: Text('No se pudo cargar el perro: ${snapshot.error}')));
      if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
      if (snapshot.data == null) return const Scaffold(body: Center(child: Text('Este perro ya no está disponible.')));
      return _PlantillaPerfil(perro: snapshot.data!);
    },
  );
}

class _PlantillaPerfil extends StatelessWidget {
  const _PlantillaPerfil({required this.perro});
  final Perro perro;

  @override
  Widget build(BuildContext context) {
    final sano = perro.estado.toLowerCase() == 'saludable';
    final vacunado = perro.vacunacion.toLowerCase().startsWith('vacunado');
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final seguido = perro.esSeguidoPor(uid);
    // Medidas de la plantilla original. Se conserva su jerarquía visual;
    // únicamente cambió el origen de los datos a Firestore.
    const altoImagen = 350.0;

    return Scaffold(
      backgroundColor: const Color(0xfff9f0eb),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Color(0xfff9f0eb),
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Stack(fit: StackFit.expand, children: [
          // Equivalente seguro a la imagen no restringida de la plantilla:
          // conserva la proporción de la foto y el panel se superpone luego.
          Align(alignment: Alignment.topCenter, child: _Foto(perro: perro)),
          Positioned(top: 20, left: 4, child: _IconoFlotante(icono: Icons.arrow_back, onTap: () => Navigator.pop(context))),
          Positioned(top: 20, right: 4, child: _IconoFlotante(icono: Icons.edit, onTap: () => _mensaje(context, 'Editar perfil'))),
          Positioned(
            top: 295,
            left: 0,
            right: 0,
            child: Center(child: _EtiquetaEstado(estado: perro.estado, sano: sano)),
          ),
          Positioned.fill(
            top: altoImagen,
            child: Container(
              color: const Color(0xfff9f0eb),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(perro.nombre, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
                      Text('${perro.raza} · ${perro.edad}', style: const TextStyle(fontSize: 16)),
                      Row(children: [
                        const Icon(Icons.access_time, size: 15, color: Color(0xff8d8580)),
                        const SizedBox(width: 3),
                        Text('Última actualización: ${_fechaRelativa(perro.actualizadoEn)}.', style: const TextStyle(fontSize: 11, color: Color(0xff8d8580))),
                      ]),
                    ])),
                    _Seguir(
                      seguido: seguido,
                      habilitado: uid != null,
                      onTap: uid == null ? null : () => _cambiarSeguimiento(context, perro, uid, seguido),
                    ),
                  ]),
                  const SizedBox(height: 15),
                  Row(children: [
                    Expanded(child: _TarjetaDato(icono: Icons.flatware, titulo: 'Última comida', valor: perro.ultimaComida, subtitulo: _fechaRelativa(perro.actualizadoEn))),
                    const SizedBox(width: 7),
                    Expanded(child: _TarjetaDato(icono: Icons.scale_outlined, titulo: 'Peso', valor: perro.peso, subtitulo: perro.tamano)),
                    const SizedBox(width: 7),
                    Expanded(child: _TarjetaCaracter(caracter: perro.caracter)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(vacunado ? Icons.check : Icons.close, color: vacunado ? const Color(0xff4caf82) : const Color(0xffff0037)),
                    Text(perro.vacunacion, style: TextStyle(color: vacunado ? const Color(0xff4caf82) : const Color(0xffff0037), fontSize: 20)),
                  ]),
                  const SizedBox(height: 8),
                  Text(perro.descripcion, style: const TextStyle(fontSize: 16, height: 1.35)),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xffe8ded9)),
                  const Row(children: [Icon(Icons.access_time_outlined, size: 12, color: Color(0xff827a75)), SizedBox(width: 4), Text('Próxima alimentación sugerida: --', style: TextStyle(fontSize: 9, color: Color(0xff6e6560)))]),
                      ]),
                    ),
                  ),
                  _AccionesPerfil(perro: perro),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

ButtonStyle _estilo(Color color) => ElevatedButton.styleFrom(elevation: 0, backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));

class _Foto extends StatelessWidget {
  const _Foto({required this.perro});
  final Perro perro;
  @override
  Widget build(BuildContext context) {
    const vacio = ColoredBox(color: Color(0xffefd2c3), child: Center(child: Icon(Icons.pets, size: 80)));
    final ancho = MediaQuery.sizeOf(context).width;
    if (perro.fotoUrl.isNotEmpty) return ImagenRemota(url: perro.fotoUrl, width: ancho, fit: BoxFit.fitWidth, alignment: Alignment.topCenter, error: vacio);
    if (perro.imagenAsset.isNotEmpty) return Image.asset('fotos/${perro.imagenAsset}', width: ancho, fit: BoxFit.fitWidth, alignment: Alignment.topCenter, errorBuilder: (_, __, ___) => vacio);
    return vacio;
  }
}

class _IconoFlotante extends StatelessWidget {
  const _IconoFlotante({required this.icono, required this.onTap});
  final IconData icono;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, elevation: 2, shape: const CircleBorder(), child: IconButton(iconSize: 20, onPressed: onTap, icon: Icon(icono, color: Colors.grey)));
}

class _EtiquetaEstado extends StatelessWidget {
  const _EtiquetaEstado({required this.estado, required this.sano});
  final String estado;
  final bool sano;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Text(estado, style: TextStyle(fontSize: 11, color: sano ? const Color(0xff4caf82) : const Color(0xffff9500))));
}

/// Acciones fuera del área desplazable: siempre quedan ancladas abajo.
class _AccionesPerfil extends StatelessWidget {
  const _AccionesPerfil({required this.perro});
  final Perro perro;

  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xfff9f0eb),
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
    child: Column(children: [
      SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          style: _estilo(const Color(0xffde4f41)),
          onPressed: () => showModalBottomSheet<void>(
            isScrollControlled: true,
            context: context,
            builder: (_) => RegistrarAlimentacion(perro: perro.nombre),
          ),
          icon: const Icon(Icons.flatware, color: Colors.white, size: 28),
          label: const Text('Registrar Alimentación', style: TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        if (perro.carnetUrls.isNotEmpty) ...[
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                style: _estilo(const Color(0xff1fb39c)),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CarnetVeterinario(nombrePerro: perro.nombre, imagenes: perro.carnetUrls)),
                ),
                icon: const Icon(Icons.badge_outlined, color: Colors.white, size: 28),
                label: const Text('Carnet', style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              style: _estilo(const Color(0xffebb9af)),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => Foro(IDPerro: perro.id, nombrePerro: perro.nombre)),
              ),
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
              label: const Text('Foro', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
        ),
      ]),
    ]),
  );
}

class _Seguir extends StatelessWidget {
  const _Seguir({required this.seguido, required this.habilitado, this.onTap});
  final bool seguido;
  final bool habilitado;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(10), child: InkWell(onTap: habilitado ? onTap : null, borderRadius: BorderRadius.circular(10), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Column(children: [Icon(siguiendoIcono(seguido), size: 35, color: seguido ? const Color(0xff4caf82) : Colors.grey), Text(seguido ? 'Seguido' : 'Seguir', style: const TextStyle(fontSize: 13, color: Colors.grey))]))));
}

IconData siguiendoIcono(bool seguido) => seguido ? Icons.pets : Icons.pets_outlined;

class _TarjetaDato extends StatelessWidget {
  const _TarjetaDato({required this.icono, required this.titulo, required this.valor, required this.subtitulo});
  final IconData icono;
  final String titulo;
  final String valor;
  final String subtitulo;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: SizedBox(
      height: 110,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 27),
            Text(titulo, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
            Text(valor, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            Text(subtitulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xff8d8580))),
          ],
        ),
      ),
    ),
  );
}

class _TarjetaCaracter extends StatelessWidget {
  const _TarjetaCaracter({required this.caracter});
  final String caracter;
  @override
  Widget build(BuildContext context) {
    final amable = caracter.toLowerCase().contains('cariñ') || caracter.toLowerCase().contains('amigable');
    final color = amable ? const Color(0xff4caf82) : const Color(0xffff9500);
    return Card(color: amable ? const Color(0xffc6dccc) : const Color(0xffffead7), elevation: 0, child: SizedBox(height: 110, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(amable ? Icons.favorite_border : Icons.warning_amber, size: 50, color: color), Text(caracter, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color))])));
  }
}

String _fechaRelativa(dynamic timestamp) {
  if (timestamp == null) return 'sin registro';
  final diferencia = DateTime.now().difference(timestamp.toDate());
  if (diferencia.inMinutes < 60) return 'hace ${diferencia.inMinutes} min';
  if (diferencia.inHours < 24) return 'hace ${diferencia.inHours} h';
  return 'hace ${diferencia.inDays} días';
}

void _mensaje(BuildContext context, String texto) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$texto estará disponible próximamente.')));

Future<void> _cambiarSeguimiento(BuildContext context, Perro perro, String uid, bool seguido) async {
  try {
    await PerrosRepository().actualizarSeguimiento(idPerro: perro.id, uid: uid, seguir: !seguido);
  } catch (_) {
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo actualizar el seguimiento.')));
  }
}
