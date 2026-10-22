import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/screens/camara.dart';
import 'package:guaurdados_oficial/screens/perfilperro.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'foro.dart';
import 'package:guaurdados_oficial/screens/perfilusuario.dart';

const _fondo = Color(0xfff0d2c2);
const _tarjeta = Color(0xfffff9f6);
const _coral = Color(0xffe85042);

class Homepage extends StatelessWidget {
  const Homepage({super.key, PerrosRepository? perrosRepository})
      : _repository = perrosRepository;

  final PerrosRepository? _repository;

  @override
  Widget build(BuildContext context) {
    final repository = _repository ?? PerrosRepository();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: _fondo,
      appBar: AppBar(
        toolbarHeight: 76,
        backgroundColor: _fondo,
        elevation: 0,
        titleSpacing: 18,
        title: Row(
          children: [
            Image.asset('fotos/Letras.png', width: 154),
            const Spacer(),
            IconButton.filled(
              onPressed: () {},
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xffff8500),
              ),
              icon: const Icon(Icons.notifications_none),
            ),
            const SizedBox(width: 9),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffff0041),
                foregroundColor: Colors.white,
                elevation: 3,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                shape: const StadiumBorder(),
              ),
              child: const Text('Emergencia', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Perro>>(
        stream: repository.observarPerros(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return _EstadoError(error: snapshot.error);
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final perros = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (uid != null) _PerrosSeguidos(repository: repository, uid: uid),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 10, 18, 8),
                child: BotonForo(),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 8, 18, 5),
                child: Text(
                  'Todos los perritos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: perros.isEmpty
                    ? const Center(child: Text('Aún no hay perros publicados.'))
                    : ListaTodosLosPerros(listaPerros: perros),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const _NavegacionInferior(),
    );
  }
}

class _PerrosSeguidos extends StatelessWidget {
  const _PerrosSeguidos({required this.repository, required this.uid});
  final PerrosRepository repository;
  final String uid;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Perro>>(
        stream: repository.observarPerrosSeguidos(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          if (snapshot.data!.isEmpty) {
            return const Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 10),
              child: _MensajeSinSeguidos(),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 8, 18, 2),
                child: Text('Patitas seguidas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ),
              ListaPerrosSeguidos(listaPerrosSeguidos: snapshot.data!),
            ],
          );
        },
      );
}

class _MensajeSinSeguidos extends StatelessWidget {
  const _MensajeSinSeguidos();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xfffff9f6),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Row(
      children: [
        Icon(Icons.pets_outlined, size: 28, color: _coral),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aún no sigues a ningún perrito', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              SizedBox(height: 2),
              Text('Conoce a nuestros perritos y sigue a tus favoritos.', style: TextStyle(fontSize: 11, color: Color(0xff776d68))),
            ],
          ),
        ),
      ],
    ),
  );
}

class ListaPerrosSeguidos extends StatelessWidget {
  const ListaPerrosSeguidos({super.key, required this.listaPerrosSeguidos});
  final List<Perro> listaPerrosSeguidos;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 184,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
          scrollDirection: Axis.horizontal,
          itemCount: listaPerrosSeguidos.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) => _TarjetaPerro(
            perro: listaPerrosSeguidos[index],
            compacta: true,
          ),
        ),
      );
}

class ListaTodosLosPerros extends StatelessWidget {
  const ListaTodosLosPerros({super.key, required this.listaPerros});
  final List<Perro> listaPerros;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
        itemCount: listaPerros.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => _TarjetaPerro(perro: listaPerros[index]),
      );
}

class _TarjetaPerro extends StatelessWidget {
  const _TarjetaPerro({required this.perro, this.compacta = false});
  final Perro perro;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final contenido = compacta ? _contenidoCompacto() : _contenidoLista();
    return Material(
      color: _tarjeta,
      borderRadius: BorderRadius.circular(compacta ? 20 : 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(compacta ? 20 : 18),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PerfilPerro(idPerro: perro.id)),
        ),
        child: SizedBox(
          width: compacta ? 138 : double.infinity,
          height: compacta ? 160 : 88,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: contenido,
          ),
        ),
      ),
    );
  }

  Widget _contenidoCompacto() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _FotoPerro(perro: perro, size: 54, circular: true)),
          const SizedBox(height: 8),
          Text(perro.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          _EtiquetaEstado(estado: perro.estado, compacta: true),
        ],
      );

  Widget _contenidoLista() => Row(
        children: [
          _FotoPerro(perro: perro, size: 52),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(perro.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.access_time, size: 13, color: Color(0xff867d78)),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(_fechaRelativa(perro.actualizadoEn),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Color(0xff625b57))),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _EtiquetaEstado(estado: perro.estado),
          const Icon(Icons.chevron_right, color: Color(0xffd8cfca)),
        ],
      );
}

class _FotoPerro extends StatelessWidget {
  const _FotoPerro({required this.perro, required this.size, this.circular = false});
  final Perro perro;
  final double size;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final image = perro.fotoUrl.isNotEmpty
        ? Image.network(perro.fotoUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _sinImagen())
        : perro.imagenAsset.isNotEmpty
            ? Image.asset('fotos/${perro.imagenAsset}', fit: BoxFit.cover, errorBuilder: (_, __, ___) => _sinImagen())
            : _sinImagen();
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(circular ? size / 2 : 10),
        child: image,
      ),
    );
  }

  Widget _sinImagen() => const ColoredBox(
        color: Color(0xffe7d9ff),
        child: Icon(Icons.pets, color: Color(0xff6345a2)),
      );
}

class _EtiquetaEstado extends StatelessWidget {
  const _EtiquetaEstado({required this.estado, this.compacta = false});
  final String estado;
  final bool compacta;

  @override
  Widget build(BuildContext context) {
    final saludable = estado.toLowerCase() == 'saludable';
    final color = saludable ? const Color(0xff35ae7b) : const Color(0xffff8d17);
    final fondo = saludable ? const Color(0xffe4f5ec) : const Color(0xffffedda);
    final texto = saludable ? estado : estado == 'Sin estado' ? estado : 'Revisar';
    return Container(
      constraints: BoxConstraints(maxWidth: compacta ? 112 : 72),
      padding: EdgeInsets.symmetric(horizontal: compacta ? 7 : 9, vertical: 7),
      decoration: BoxDecoration(color: fondo, borderRadius: BorderRadius.circular(18)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (compacta) ...[Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4)],
        Text(texto, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: compacta ? 10 : 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

String _fechaRelativa(dynamic timestamp) {
  if (timestamp == null) return 'Sin actualizaciones';
  final difference = DateTime.now().difference(timestamp.toDate());
  if (difference.inMinutes < 1) return 'Hace unos instantes';
  if (difference.inMinutes < 60) return 'Hace ${difference.inMinutes} min';
  if (difference.inHours < 24) return 'Hace ${difference.inHours} h';
  return 'Hace ${difference.inDays} días';
}

class _EstadoError extends StatelessWidget {
  const _EstadoError({this.error});
  final Object? error;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('No se pudieron cargar los perros.\n$error', textAlign: TextAlign.center)));
}

class BotonForo extends StatelessWidget {
  const BotonForo({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 39,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: _coral, shape: const StadiumBorder()),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Foro())),
          icon: const Icon(Icons.chat_bubble_outline, size: 18),
          label: const Text('Foros', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      );
}

class _NavegacionInferior extends StatelessWidget {
  const _NavegacionInferior();
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 86,
        child: Stack(clipBehavior: Clip.none, alignment: Alignment.topCenter, children: [
          Container(color: const Color(0xfff4bea5)),
          Positioned(
            left: 0,
            right: 0,
            top: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  tooltip: 'Inicio',
                  onPressed: () {},
                  icon: const Icon(Icons.home_outlined, color: _coral, size: 32),
                ),
                const SizedBox(width: 48),
                IconButton(
                  tooltip: 'Mi perfil',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PerfilUsuario()),
                  ),
                  icon: const Icon(Icons.person_outline, color: Color(0xff776d68), size: 31),
                ),
              ],
            ),
          ),
          Positioned(top: -20, child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Camara()),
              ),
              child: Container(width: 78, height: 78, decoration: const BoxDecoration(color: _coral, shape: BoxShape.circle), child: const Icon(Icons.camera_alt_outlined, color: Colors.white, size: 31)))),
        ]),
      );
}
