import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/perro.dart';
import '../services/emergencias_repository.dart';
import '../services/perros_repository.dart';
import '../theme/colores_app.dart';
import '../theme/formas.dart';
import '../theme/tipografia.dart';
import '../widgets/esqueleto.dart';
import '../widgets/foto_perro.dart';
import '../widgets/hoja.dart';
import '../widgets/iconos.dart';
import '../widgets/presionable.dart';

const _tipos = <String, IconData>{
  'Problema de salud': Iconos.heartPulse,
  'Pelea': Iconos.zap,
  'Peligro': Iconos.triangleAlert,
  'Otro': Iconos.circleHelp,
};

/// Hoja inferior para reportar una emergencia.
///
/// - Desde el Homepage: `ReportarEmergencia.mostrar(context)` > versión completa
///   (selector de perro, qué ocurre, ubicación).
/// - Desde el foro/perfil de un perro:
///   `ReportarEmergencia.mostrar(context, idPerro: id, nombrePerro: nombre)`
///   > versión compacta, con los datos del perro adjuntos automáticamente.
class ReportarEmergencia extends StatefulWidget {
  const ReportarEmergencia({super.key, this.idPerro, this.nombrePerro, EmergenciasRepository? repository})
      : _repository = repository;

  final String? idPerro;
  final String? nombrePerro;
  final EmergenciasRepository? _repository;

  static Future<void> mostrar(BuildContext context, {String? idPerro, String? nombrePerro}) =>
      mostrarHoja<void>(
        context,
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

  @override
  Widget build(BuildContext context) {
    final nombre = widget.nombrePerro ?? 'el perro';
    final c = context.colores;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .9),
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + MediaQuery.paddingOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: Formas.fondo(c.divisor, 2),
              ),
            ),
            const SizedBox(height: 14),
            _encabezado(nombre),
            const SizedBox(height: 18),
            if (!_fijo) ...[
              _Etiqueta('¿QUIÉN NECESITA AYUDA?', icono: Iconos.pawPrint, color: c.textoSecundario),
              const SizedBox(height: 10),
              _selectorPerros(),
              const SizedBox(height: 18),
            ],
            _Etiqueta(_fijo ? 'AVISAR A LA SEDE' : '¿QUÉ OCURRE?', icono: _fijo ? null : Iconos.zap, color: c.advertencia),
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
              _Etiqueta('UBICACIÓN', icono: Iconos.mapPin, color: c.emergencia),
              const SizedBox(height: 10),
              Container(
                decoration: ShapeDecoration(color: c.superficie, shape: Formas.squircle(14, lado: BorderSide(color: c.divisor))),
                child: TextField(
                  controller: _ubicacion,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Ej: Patio Central, Entrada...',
                    hintStyle: TextStyle(color: c.textoTenue),
                    prefixIcon: Icono(Iconos.mapPin, size: 20, color: c.textoTenue),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: Presionable(
                child: FilledButton.icon(
                  onPressed: _puedeEnviar ? _enviar : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: c.emergencia,
                    foregroundColor: c.sobreAcento,
                    disabledBackgroundColor: c.emergencia.withValues(alpha: .35),
                    disabledForegroundColor: c.sobreAcento,
                    shape: Formas.squircle(16),
                  ),
                  icon: _enviando
                      ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.sobreAcento))
                      : Icono(Iconos.triangleAlert, color: c.sobreAcento),
                  label: const Text('Emitir alerta a la comunidad', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: _enviando ? null : () => Navigator.pop(context),
                child: Text('Cancelar', style: TextStyle(color: c.textoSecundario, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado(String nombre) {
    final c = context.colores;
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46, height: 46,
            decoration: ShapeDecoration(
              color: c.emergencia.withValues(alpha: .12),
              shape: Formas.squircle(14, lado: BorderSide(color: c.emergencia.withValues(alpha: .3))),
            ),
            child: Icono(Iconos.triangleAlert, color: c.emergencia, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_fijo ? 'Emergencia: $nombre' : 'Reportar emergencia', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800).display),
                const SizedBox(height: 2),
                Text(
                  _fijo ? 'Los datos de $nombre se adjuntarán automáticamente' : 'Se notificará a toda la comunidad',
                  style: TextStyle(fontSize: 12, color: c.textoSecundario),
                ),
              ],
            ),
          ),
          if (!_fijo)
            IconButton(
              tooltip: 'Cerrar',
              onPressed: () => Navigator.pop(context),
              icon: Icono(Iconos.x, size: 20, color: c.textoSecundario),
            ),
        ],
      );
  }

  Widget _selectorPerros() => SizedBox(
        height: 98,
        child: StreamBuilder<List<Perro>>(
          stream: _perros,
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Text('No se pudieron cargar los perros.');
            if (!snapshot.hasData) {
              return Row(children: [
                for (var i = 0; i < 4; i++)
                  const Padding(padding: EdgeInsets.only(right: 20), child: BloqueEsqueleto(ancho: 54, alto: 54, circular: true)),
              ]);
            }
            final perros = snapshot.data!;
            return ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final p in perros)
                  _OpcionPerro(
                    nombre: p.nombre,
                    perro: p,
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
        if (icono != null) ...[Icono(icono!, size: 15, color: color), const SizedBox(width: 6)],
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
  Widget build(BuildContext context) {
    final c = context.colores;
    final forma = Formas.squircle(20, lado: BorderSide(color: seleccionado ? c.emergencia : c.divisor, width: seleccionado ? 1.5 : 1));
    return Presionable(
      child: Material(
        color: seleccionado ? c.emergencia.withValues(alpha: .12) : c.superficie,
        shape: forma,
        child: InkWell(
          customBorder: forma,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: icono == null ? 28 : 16, vertical: 13),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icono != null) ...[Icono(icono!, size: 16, color: seleccionado ? c.emergencia : c.textoSecundario), const SizedBox(width: 8)],
              Text(texto, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _OpcionPerro extends StatelessWidget {
  const _OpcionPerro({required this.nombre, required this.seleccionado, required this.onTap, this.perro});
  final String nombre;
  final Perro? perro;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return InkWell(
        onTap: onTap,
        customBorder: Formas.squircle(12),
        child: SizedBox(
          width: 74,
          child: Column(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: seleccionado ? c.emergencia : Colors.transparent, width: 2.5)),
              child: FotoPerroRedonda(perro: perro, tamano: 50),
            ),
            const SizedBox(height: 5),
            Text(nombre, maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, height: 1.1, fontWeight: seleccionado ? FontWeight.w700 : FontWeight.w500)),
          ]),
        ),
      );
  }
}
