import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/widgets/foto_perro.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';

class NuevaPublicacion extends StatefulWidget {
  const NuevaPublicacion({super.key, this.idPerro});

  final String? idPerro;

  @override
  State<NuevaPublicacion> createState() => _NuevaPublicacionState();
}

class _NuevaPublicacionState extends State<NuevaPublicacion> {
  final _descripcion = TextEditingController();
  final _foroRepository = ForoRepository();
  String? _perroSeleccionado;
  bool _publicando = false;

  @override
  void dispose() {
    _descripcion.dispose();
    super.dispose();
  }

  Future<void> _publicar() async {
    if (_publicando) return;

    final idPerro = widget.idPerro ?? _perroSeleccionado;
    final usuario = FirebaseAuth.instance.currentUser;
    final descripcion = _descripcion.text.trim();

    if (idPerro == null) {
      _avisar('Selecciona el perro de este foro.');
      return;
    }
    if (usuario == null) {
      _avisar('Inicia sesión para publicar.');
      return;
    }
    if (descripcion.isEmpty) {
      _avisar('Escribe algo antes de publicar.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _publicando = true);
    try {
      final perro = await PerrosRepository().observarPerro(idPerro).first;
      if (perro == null) {
        _avisar('No encontramos ese perro. Vuelve a seleccionarlo.');
        return;
      }

      await _foroRepository.crearPublicacion(
        idPerro: perro.id,
        nombrePerro: perro.nombre,
        usuario: usuario,
        tipoPublicacion: 'normal',
        descripcion: descripcion,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final mensaje = error is FirebaseException && error.code == 'permission-denied'
          ? 'Firestore rechazó la publicación. Hay que desplegar las reglas del foro.'
          : 'No se pudo publicar. Revisa tu conexión e inténtalo de nuevo.';
      _avisar(mensaje);
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  void _avisar(String texto) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        title: const Text('Nueva publicación'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icono(Iconos.chevronLeft),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SelectorPerro(
                      idInicial: widget.idPerro,
                      seleccionado: _perroSeleccionado,
                      alSeleccionar: (id) => setState(() => _perroSeleccionado = id),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _descripcion,
                      enabled: !_publicando,
                      minLines: 6,
                      maxLines: 12,
                      maxLength: 2000,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        labelText: '¿Qué quieres compartir?',
                        hintText: 'Cuéntale a la comunidad cómo está el perrito...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _publicando ? null : _publicar,
                  icon: _publicando
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icono(Iconos.send),
                  label: Text(_publicando ? 'Publicando...' : 'Publicar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorPerro extends StatefulWidget {
  const _SelectorPerro({required this.idInicial, required this.seleccionado, required this.alSeleccionar});

  final String? idInicial;
  final String? seleccionado;
  final ValueChanged<String?> alSeleccionar;

  @override
  State<_SelectorPerro> createState() => _SelectorPerroState();
}

class _SelectorPerroState extends State<_SelectorPerro> {
  late final Stream<List<Perro>> _perros = PerrosRepository().observarPerros();

  @override
  Widget build(BuildContext context) => StreamBuilder<List<Perro>>(
    stream: _perros,
    builder: (context, snapshot) {
      if (snapshot.hasError) return const Text('No se pudo cargar la lista de perros.');
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

      final perros = snapshot.data!;
      if (perros.isEmpty) return const Text('No hay perros disponibles para publicar.');

      final id = widget.idInicial ?? widget.seleccionado;
      Perro? perro;
      for (final candidato in perros) {
        if (candidato.id == id) {
          perro = candidato;
          break;
        }
      }

      if (widget.idInicial != null) {
        if (perro == null) return const Text('No encontramos el perro de este foro.');
        return _EtiquetaPerro(perro: perro);
      }

      return DropdownButtonFormField<String>(
        initialValue: perros.any((candidato) => candidato.id == widget.seleccionado)
            ? widget.seleccionado
            : null,
        decoration: const InputDecoration(labelText: 'Publicar en el foro de', border: OutlineInputBorder()),
        hint: const Text('Escoge un perrito'),
        items: perros.map((p) => DropdownMenuItem(value: p.id, child: Text(p.nombre))).toList(),
        onChanged: widget.alSeleccionar,
      );
    },
  );
}

class _EtiquetaPerro extends StatelessWidget {
  const _EtiquetaPerro({required this.perro});

  final Perro perro;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          FotoPerroRedonda(perro: perro, tamano: 36),
          const SizedBox(width: 8),
          Expanded(child: Text('Foro de ${perro.nombre}')),
        ],
      ),
    ),
  );
}
