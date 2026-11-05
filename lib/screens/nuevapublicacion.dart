import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';
import 'package:guaurdados_oficial/services/perros_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:guaurdados_oficial/widgets/campo.dart';
import 'package:guaurdados_oficial/widgets/foto_perro.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';

class NuevaPublicacion extends StatefulWidget {
  const NuevaPublicacion({super.key, this.idPerro, this.perritoNuevo = false, this.fotoInicial});

  final String? idPerro;
  final bool perritoNuevo;
  final String? fotoInicial;

  @override
  State<NuevaPublicacion> createState() => _NuevaPublicacionState();
}

class _NuevaPublicacionState extends State<NuevaPublicacion> {
  final _descripcion = TextEditingController();
  final _ubicacion = TextEditingController();
  final _formulario = GlobalKey<FormState>();
  final _foroRepository = ForoRepository();
  String? _perroSeleccionado;
  bool _publicando = false;
  late String? _foto = widget.fotoInicial;

  @override
  void dispose() {
    _descripcion.dispose();
    _ubicacion.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto(ImageSource origen) async {
    try {
      final imagen = await ImagePicker().pickImage(source: origen, maxWidth: 1600, imageQuality: 82);
      if (imagen != null && mounted) setState(() => _foto = imagen.path);
    } catch (_) {
      _avisar(origen == ImageSource.camera
          ? 'No se pudo abrir la cámara. Revisa que la app tenga permiso.'
          : 'No se pudo abrir la galería. Revisa que la app tenga permiso.');
    }
  }

  Future<void> _avisarPerritoNuevo() async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (!_formulario.currentState!.validate()) return;
    if (usuario == null) return _avisar('Inicia sesión para publicar.');
    FocusScope.of(context).unfocus();
    setState(() => _publicando = true);
    final foto = _foto;
    try {
      await _foroRepository
          .avisarPerritoNuevo(
            usuario: usuario,
            descripcion: _descripcion.text,
            ubicacion: _ubicacion.text,
            foto: foto == null ? null : File(foto),
          )
          .timeout(Duration(seconds: foto == null ? 15 : 60));
      if (mounted) Navigator.of(context).pop(true);
    } on TimeoutException {
      if (foto == null) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        _avisar('La foto está tardando mucho en subir. Revisa tu conexión o publica el aviso sin foto.');
      }
    } catch (_) {
      _avisar('No se pudo publicar el aviso. Revisa tu conexión e inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  Future<void> _publicar() async {
    if (_publicando) return;
    if (widget.perritoNuevo) return _avisarPerritoNuevo();

    final idPerro = widget.idPerro ?? _perroSeleccionado;
    final usuario = FirebaseAuth.instance.currentUser;
    final descripcion = _descripcion.text.trim();

    if (!_formulario.currentState!.validate() || idPerro == null) return;
    if (usuario == null) {
      _avisar('Inicia sesión para publicar.');
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
          ? 'Tu cuenta no tiene permiso para publicar en este foro.'
          : 'No se pudo publicar. Revisa tu conexión e inténtalo de nuevo.';
      _avisar(mensaje);
    } finally {
      if (mounted) setState(() => _publicando = false);
    }
  }

  void _avisar(String texto) {
    if (mounted) avisar(context, texto, tipo: TipoAviso.error);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.fondo,
      appBar: AppBar(
        title: Text(widget.perritoNuevo ? 'Avisar de un perrito nuevo' : 'Nueva publicación'),
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
                child: Form(
                  key: _formulario,
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.perritoNuevo)
                      const _ExplicacionPerritoNuevo()
                    else
                      _SelectorPerro(
                        idInicial: widget.idPerro,
                        seleccionado: _perroSeleccionado,
                        alSeleccionar: (id) => setState(() => _perroSeleccionado = id),
                      ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _descripcion,
                      enabled: !_publicando,
                      minLines: widget.perritoNuevo ? 4 : 6,
                      maxLines: 12,
                      maxLength: widget.perritoNuevo ? 1000 : 2000,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (valor) => (valor ?? '').trim().isEmpty
                          ? widget.perritoNuevo
                              ? 'Descríbelo para que GUAU lo pueda reconocer: color, tamaño, alguna marca o collar.'
                              : 'Escribe algo antes de publicar: cómo lo viste, dónde estaba o qué necesita.'
                          : null,
                      decoration: decoracionCampo(
                        context,
                        etiqueta: widget.perritoNuevo ? '¿Cómo es?' : '¿Qué quieres compartir?',
                        pista: widget.perritoNuevo
                            ? 'Ej.: café claro, mediano, collar rojo, cojea un poco...'
                            : 'Cuéntale a la comunidad cómo está el perrito...',
                        radio: 16,
                        borde: true,
                      ),
                    ),
                    if (widget.perritoNuevo) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ubicacion,
                        enabled: !_publicando,
                        maxLength: 200,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: decoracionCampo(
                          context,
                          etiqueta: '¿Dónde lo viste? (opcional)',
                          pista: 'Ej.: Patio Central, entrada principal...',
                          prefijo: Icono(Iconos.mapPin, size: 20, color: c.textoTenue),
                          radio: 16,
                          borde: true,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _FotoAviso(
                        ruta: _foto,
                        deshabilitada: _publicando,
                        alElegir: _elegirFoto,
                        alQuitar: () => setState(() => _foto = null),
                      ),
                    ],
                  ],
                ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Presionable(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _publicando ? null : _publicar,
                    style: FilledButton.styleFrom(
                      backgroundColor: c.acento,
                      foregroundColor: c.sobreAcento,
                      disabledBackgroundColor: c.acento.withValues(alpha: .5),
                      disabledForegroundColor: c.sobreAcento,
                      shape: Formas.squircle(16),
                    ),
                    icon: _publicando
                        ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.sobreAcento))
                        : Icono(Iconos.send, color: c.sobreAcento),
                    label: Text(_publicando ? 'Publicando...' : widget.perritoNuevo ? 'Avisar a GUAU' : 'Publicar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FotoAviso extends StatelessWidget {
  const _FotoAviso({required this.ruta, required this.deshabilitada, required this.alElegir, required this.alQuitar});
  final String? ruta;
  final bool deshabilitada;
  final ValueChanged<ImageSource> alElegir;
  final VoidCallback alQuitar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final botones = Row(children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: deshabilitada ? null : () => alElegir(ImageSource.gallery),
          style: OutlinedButton.styleFrom(foregroundColor: c.texto, side: BorderSide(color: c.divisor), minimumSize: const Size(0, 48), shape: Formas.squircle(14)),
          icon: Icono(Iconos.imagePlus, size: 18, color: c.texto),
          label: Text(ruta == null ? 'Galería' : 'Cambiar'),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: OutlinedButton.icon(
          onPressed: deshabilitada ? null : () => alElegir(ImageSource.camera),
          style: OutlinedButton.styleFrom(foregroundColor: c.texto, side: BorderSide(color: c.divisor), minimumSize: const Size(0, 48), shape: Formas.squircle(14)),
          icon: Icono(Iconos.camera, size: 18, color: c.texto),
          label: const Text('Tomar foto'),
        ),
      ),
    ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Foto (opcional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textoSecundario)),
      const SizedBox(height: 4),
      Text(
        'Ayuda a que GUAU lo reconozca. Si no quieres adjuntar una, puedes quitarla.',
        style: TextStyle(fontSize: 12.5, height: 1.35, color: c.textoTenue),
      ),
      const SizedBox(height: 10),
      AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        child: ruta == null
            ? const SizedBox(width: double.infinity)
            : Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ClipRSuperellipse(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Stack(fit: StackFit.expand, children: [
                      Image.file(File(ruta!), fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Material(
                          color: Colors.black.withValues(alpha: .55),
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: 'Quitar foto',
                            onPressed: deshabilitada ? null : alQuitar,
                            icon: const Icono(Iconos.x, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
      ),
      botones,
    ]);
  }
}

class _ExplicacionPerritoNuevo extends StatelessWidget {
  const _ExplicacionPerritoNuevo();

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(color: c.contenedor, shape: Formas.squircle(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40,
          height: 40,
          decoration: ShapeDecoration(color: c.superficie, shape: Formas.squircle(12)),
          child: Center(child: Icono(Iconos.pawPrint, size: 22, color: c.acento)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Perrito sin registrar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Tu aviso se publicará en el foro general. Solo los administradores de GUAU pueden agregar perritos nuevos: con tu descripción podrán buscarlo y decidir si lo registran.',
              style: TextStyle(fontSize: 13, height: 1.4, color: c.textoSecundario),
            ),
          ]),
        ),
      ]),
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
      if (!snapshot.hasData) return const BloqueEsqueleto(alto: 58, radio: 16);

      final perros = snapshot.data!.where((p) => !p.adoptado || p.id == widget.idInicial).toList();
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
        decoration: decoracionCampo(context, etiqueta: 'Publicar en el foro de', radio: 16, borde: true),
        validator: (valor) => valor == null ? 'Elige el perrito del que quieres hablar.' : null,
        borderRadius: BorderRadius.circular(16),
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
