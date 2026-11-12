import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/services/eliminar_cuenta.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/campo.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

Future<bool> mostrarEliminarCuenta(BuildContext context) async =>
    await mostrarHoja<bool>(context, builder: (_) => const _HojaEliminarCuenta()) == true;

class _HojaEliminarCuenta extends StatefulWidget {
  const _HojaEliminarCuenta();

  @override
  State<_HojaEliminarCuenta> createState() => _HojaEliminarCuentaState();
}

class _HojaEliminarCuentaState extends State<_HojaEliminarCuenta> {
  final _contrasena = TextEditingController();
  bool _oculta = true;
  bool _trabajando = false;
  String? _error;

  @override
  void dispose() {
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _eliminar() async {
    final usuario = FirebaseAuth.instance.currentUser;
    final contrasena = _contrasena.text;
    if (usuario == null || _trabajando) return;
    if (contrasena.isEmpty) {
      setState(() => _error = 'Escribe tu contraseña para confirmar.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _trabajando = true;
      _error = null;
    });
    try {
      await EliminarCuenta.confirmarIdentidad(usuario, contrasena);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _trabajando = false;
        _error = switch (e.code) {
          'wrong-password' || 'invalid-credential' || 'invalid-login-credentials' => 'La contraseña no es correcta.',
          'too-many-requests' => 'Demasiados intentos. Espera unos minutos y vuelve a intentarlo.',
          'network-request-failed' => 'No hay conexión. Revisa tu internet e inténtalo de nuevo.',
          _ => 'No se pudo confirmar tu identidad. Inténtalo de nuevo.',
        };
      });
      return;
    }
    try {
      await EliminarCuenta.eliminar(usuario);
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _trabajando = false;
        _error = 'No se pudo terminar de eliminar tu cuenta. Revisa tu conexión y vuelve a intentarlo: no se perderá nada que no se haya borrado ya.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final medidas = MediaQuery.of(context);
    return Container(
      constraints: BoxConstraints(maxHeight: medidas.size.height - medidas.viewInsets.bottom - medidas.padding.top - 40),
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      padding: EdgeInsets.only(bottom: medidas.viewInsets.bottom),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + (medidas.viewInsets.bottom > 0 ? 0 : medidas.padding.bottom)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
          Center(
            child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 18), decoration: Formas.fondo(c.divisor, 2)),
          ),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(color: c.emergenciaSuave, shape: Formas.squircle(20)),
              child: Center(child: Icono(Iconos.trash2, size: 30, color: c.emergenciaTexto)),
            ),
          ),
          const SizedBox(height: 14),
          Text('Eliminar tu cuenta', textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800).display),
          const SizedBox(height: 6),
          Text(
            'Es permanente y no se puede deshacer.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.4, color: c.textoSecundario),
          ),
          const SizedBox(height: 16),
          _Detalle(
            icono: Iconos.trash2,
            color: c.emergenciaTexto,
            titulo: 'Se borra',
            texto: 'Tu cuenta, tu perfil, tus publicaciones, comentarios y reacciones, tus reportes, tus bloqueos, tus insignias y los perritos que sigues.',
          ),
          const SizedBox(height: 8),
          _Detalle(
            icono: Iconos.pawPrint,
            color: c.textoSecundario,
            titulo: 'Se mantiene sin tu nombre',
            texto: 'Tus registros de alimentación y las emergencias que reportaste, porque son parte del historial de los perritos. Aparecerán como "${EliminarCuenta.nombreEliminado}".',
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: _contrasena,
            obscureText: _oculta,
            enabled: !_trabajando,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            forceErrorText: _error,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onFieldSubmitted: (_) => _eliminar(),
            decoration: decoracionCampo(context, pista: 'Tu contraseña', radio: 18, borde: true).copyWith(
              suffixIcon: IconButton(
                tooltip: _oculta ? 'Mostrar contraseña' : 'Ocultar contraseña',
                onPressed: () => setState(() => _oculta = !_oculta),
                icon: Icono(_oculta ? Iconos.eye : Iconos.eyeOff, size: 20, color: c.textoTenue),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('Por seguridad, confirma con tu contraseña.', style: TextStyle(fontSize: 12.5, color: c.textoTenue)),
          ),
          const SizedBox(height: 16),
          Presionable(
            escala: .97,
            child: SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: _trabajando ? null : _eliminar,
                style: FilledButton.styleFrom(
                  backgroundColor: c.emergencia,
                  foregroundColor: c.sobreAcento,
                  disabledBackgroundColor: c.emergencia.withValues(alpha: .6),
                  disabledForegroundColor: c.sobreAcento,
                  shape: Formas.squircle(16),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _trabajando
                      ? Row(key: const ValueKey('trabajando'), mainAxisSize: MainAxisSize.min, children: [
                          SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: c.sobreAcento)),
                          const SizedBox(width: 10),
                          const Text('Borrando tus datos…', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ])
                      : const Text('Eliminar mi cuenta', key: ValueKey('listo'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _trabajando ? null : () => Navigator.of(context).pop(false),
            child: Text('Cancelar', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: c.textoSecundario)),
          ),
        ]),
      ),
    );
  }
}

class _Detalle extends StatelessWidget {
  const _Detalle({required this.icono, required this.color, required this.titulo, required this.texto});

  final IconData icono;
  final Color color;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
      decoration: ShapeDecoration(color: c.superficie, shape: Formas.squircle(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icono(icono, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(titulo, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: c.texto)),
            const SizedBox(height: 2),
            Text(texto, style: TextStyle(fontSize: 13.5, height: 1.4, color: c.textoSecundario)),
          ]),
        ),
      ]),
    );
  }
}
