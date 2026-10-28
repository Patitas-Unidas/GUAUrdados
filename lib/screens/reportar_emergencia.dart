import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/perro.dart';
import '../services/emergencias_repository.dart';
import '../services/perros_repository.dart';

const _telefonoClinica = '+56000000000';

const _rojo = Color(0xffff0041);
const _fondo = Color(0xfff9f0eb);
const _oscuro = Color(0xff1c1c28);

const _tipos = <String, IconData>{
  'Problema de salud': Icons.healing_outlined,
  'Pelea': Icons.bolt,
  'Peligro': Icons.warning_amber_rounded,
  'Otro': Icons.help_outline,
};

/// Hoja inferior para reportar una emergencia.
///
/// - Desde el Homepage: `ReportarEmergencia.mostrar(context)` → versión completa
///   (selector de perro, qué ocurre, ubicación).
/// - Desde el foro/perfil de un perro:
///   `ReportarEmergencia.mostrar(context, idPerro: id, nombrePerro: nombre)`
///   → versión compacta, con los datos del perro adjuntos automáticamente.
class ReportarEmergencia extends StatefulWidget {
  const ReportarEmergencia({super.key, this.idPerro, this.nombrePerro, EmergenciasRepository? repository})
      : _repository = repository;

  final String? idPerro;
  final String? nombrePerro;
  final EmergenciasRepository? _repository;

  static Future<void> mostrar(BuildContext context, {String? idPerro, String? nombrePerro}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ReportarEmergencia(idPerro: idPerro, nombrePerro: nombrePerro),
      );

  @override
  State<ReportarEmergencia> createState() => _ReportarEmergenciaState();
}

class _ReportarEmergenciaState extends State<ReportarEmergencia> {
  final _ubicacion = TextEditingController();
  late final EmergenciasRepository _repo = widget._repository ?? EmergenciasRepository();
  Stream<List<Perro>>? _perros;

  String? _tipo;
  String? _idSeleccionado;
  String? _nombreSeleccionado;
  bool _desconocido = false;
  bool _enviando = false;

  bool get _fijo => widget.idPerro != null;
  bool get _puedeEnviar => !_enviando && _tipo != null && (_fijo || _idSeleccionado != null || _desconocido);

  @override
  void initState() {
    super.initState();
    if (!_fijo) _perros = PerrosRepository().observarPerros();
  }

  @override
  void dispose() {
    _ubicacion.dispose();
    super.dispose();
  }

  void _snack(String texto) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _enviar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return _snack('Debes iniciar sesión para emitir una alerta.');
    setState(() => _enviando = true);
    try {
      await _repo
          .crear(
            idPerro: _fijo ? widget.idPerro : _idSeleccionado,
            nombrePerro: _fijo ? widget.nombrePerro : _nombreSeleccionado,
            tipo: _tipo!,
            ubicacion: _ubicacion.text.trim(),
            uid: uid,
          )
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(const SnackBar(content: Text('Alerta emitida. Se está avisando a la comunidad.')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviando = false);
      _snack('No se pudo emitir la alerta. Inténtalo de nuevo.');
    }
  }

  Future<void> _llamar() async {
    final ok = await launchUrl(Uri(scheme: 'tel', path: _telefonoClinica));
    if (!ok && mounted) _snack('No se pudo abrir el teléfono.');
  }

  @override
  Widget build(BuildContext context) {
    final nombre = widget.nombrePerro ?? 'el perro';
    return Container(
      decoration: const BoxDecoration(
        color: _fondo,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(color: const Color(0xffd9cfca), borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 14),
            _encabezado(nombre),
            const SizedBox(height: 18),
            if (!_fijo) ...[
              const _Etiqueta('¿QUIÉN NECESITA AYUDA?', icono: Icons.pets, color: Color(0xff776d68)),
              const SizedBox(height: 10),
              _selectorPerros(),
              const SizedBox(height: 18),
            ],
            _Etiqueta(_fijo ? 'AVISAR A LA SEDE' : '¿QUÉ OCURRE?', icono: _fijo ? null : Icons.bolt, color: const Color(0xffffa000)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final e in _tipos.entries)
                  _Pill(
                    texto: e.key,
                    icono: _fijo ? null : e.value,
                    seleccionado: _tipo == e.key,
                    onTap: () => setState(() => _tipo = e.key),
                  ),
              ],
            ),
            if (!_fijo) ...[
              const SizedBox(height: 18),
              const _Etiqueta('UBICACIÓN', icono: Icons.place_outlined, color: _rojo),
              const SizedBox(height: 10),
              TextField(
                controller: _ubicacion,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Ej: Patio Central, Entrada...',
                  prefixIcon: const Icon(Icons.place_outlined, size: 20),
                  filled: true,
                  fillColor: const Color(0xfffdf6f3),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xffefe2dc))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xffefe2dc))),
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _puedeEnviar ? _enviar : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _rojo,
                  disabledBackgroundColor: const Color(0xfff3b4b4),
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: _enviando
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.warning_amber_rounded),
                label: const Text('Emitir Alerta a la Comunidad', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
            if (_fijo) ...[
              const SizedBox(height: 12),
              const Center(child: Text('O', style: TextStyle(color: Color(0xff9a918c)))),
              const SizedBox(height: 12),
              const _Etiqueta('ASISTENCIA PROFESIONAL'),
              const SizedBox(height: 10),
            ] else
              const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: _fijo ? 56 : 50,
              child: ElevatedButton(
                onPressed: _llamar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _oscuro,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Llamar a Clínica Veterinaria', style: TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                    if (_fijo) const Text('(Línea directa para urgencias)', style: TextStyle(fontSize: 10, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: _enviando ? null : () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: Color(0xff8d8580), fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado(String nombre) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: const Color(0xffffdfe5), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xffffb8c6))),
            child: const Icon(Icons.warning_amber_rounded, color: _rojo, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_fijo ? 'Emergencia: $nombre' : 'Reportar Emergencia', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(
                  _fijo ? 'Los datos de $nombre se adjuntarán automáticamente' : 'Se notificará a toda la comunidad',
                  style: const TextStyle(fontSize: 12, color: Color(0xff8d8580)),
                ),
              ],
            ),
          ),
          if (!_fijo)
            IconButton.filledTonal(
              visualDensity: VisualDensity.compact,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 18),
            ),
        ],
      );

  Widget _selectorPerros() => SizedBox(
        height: 98,
        child: StreamBuilder<List<Perro>>(
          stream: _perros,
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('No se pudieron cargar los perros.');
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final perros = snapshot.data!;
            return ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in perros)
                  _OpcionPerro(
                    nombre: p.nombre,
                    imagen: p.fotoUrl.isNotEmpty
                        ? NetworkImage(p.fotoUrl)
                        : p.imagenAsset.isNotEmpty
                            ? AssetImage('fotos/${p.imagenAsset}') as ImageProvider
                            : null,
                    seleccionado: _idSeleccionado == p.id,
                    onTap: () => setState(() {
                      _idSeleccionado = p.id;
                      _nombreSeleccionado = p.nombre;
                      _desconocido = false;
                    }),
                  ),
                _OpcionPerro(
                  nombre: 'No lo conozco',
                  seleccionado: _desconocido,
                  onTap: () => setState(() {
                    _desconocido = true;
                    _idSeleccionado = null;
                    _nombreSeleccionado = null;
                  }),
                ),
              ],
            );
          },
        ),
      );
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto, {this.icono, this.color});
  final String texto;
  final IconData? icono;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(children: [
        if (icono != null) ...[Icon(icono, size: 15, color: color), const SizedBox(width: 6)],
        Text(texto, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: .3)),
      ]);
}

class _Pill extends StatelessWidget {
  const _Pill({required this.texto, required this.seleccionado, required this.onTap, this.icono});
  final String texto;
  final IconData? icono;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: seleccionado ? const Color(0xffffdfe5) : const Color(0xfffdf6f3),
        shape: StadiumBorder(side: BorderSide(color: seleccionado ? _rojo : const Color(0xfff6c3c8), width: seleccionado ? 1.5 : 1)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: icono == null ? 28 : 16, vertical: 13),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icono != null) ...[Icon(icono, size: 16, color: seleccionado ? _rojo : const Color(0xff776d68)), const SizedBox(width: 8)],
              Text(texto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
}

class _OpcionPerro extends StatelessWidget {
  const _OpcionPerro({required this.nombre, required this.seleccionado, required this.onTap, this.imagen});
  final String nombre;
  final ImageProvider? imagen;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 74,
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: seleccionado ? _rojo : Colors.transparent, width: 2.5)),
              child: CircleAvatar(
                radius: 25,
                backgroundColor: const Color(0xffefe9e6),
                backgroundImage: imagen,
                onBackgroundImageError: imagen == null ? null : (_, __) {},
                child: imagen == null ? const Icon(Icons.pets, color: Color(0xff776d68)) : null,
              ),
            ),
            const SizedBox(height: 5),
            Text(nombre, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.1, fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500)),
          ]),
        ),
      );
}
