import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guaurdados_oficial/services/notificaciones_service.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/logo.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';
import 'homepage.dart';
import 'registro_usuario.dart';

class IniciarSesion extends StatefulWidget {
  const IniciarSesion({super.key});

  @override
  State<IniciarSesion> createState() => _IniciarSesionState();
}

class _IniciarSesionState extends State<IniciarSesion> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _iniciarSesion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      try { await NotificacionesService.inicializar(); } catch (_) {}

      // Verificación de seguridad de Flutter después de un "await"
      if (!mounted) return;

      // Mensaje de éxito agregado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Inicio de sesión exitoso!')),
      );

      // Navegación a la página principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Homepage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensajeError = 'Ocurrió un error al iniciar sesión';

      // Manejo de códigos clásicos y el nuevo código "invalid-credential" de Firebase
      if (e.code == 'invalid-credential' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        mensajeError =
            'Credenciales incorrectas. Revisa tu correo y contraseña.';
      } else if (e.code == 'invalid-email') {
        mensajeError = 'El formato del correo es inválido.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeError), backgroundColor: context.colores.emergenciaTexto),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error inesperado de conexión.'),
          backgroundColor: context.colores.emergenciaTexto,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Scaffold(
      backgroundColor: c.fondoCalido,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              Text(
                "Bienvenido a",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: c.texto,
                ).display,
              ),
              const SizedBox(height: 10),

              const LogoGUAUrdados(alto: 180),

              const SizedBox(height: 30),

              // Input de Correo con botón "Siguiente" en el teclado
              _buildTextField(
                "Correo electrónico",
                false,
                _emailController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Input de Contraseña con botón "Listo" que ejecuta el inicio de sesión
              _buildTextField(
                "Contraseña",
                true,
                _passwordController,
                textInputAction: TextInputAction.done,
                onSubmitted: _isLoading ? null : _iniciarSesion,
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => mostrarHoja<void>(
                            context,
                            builder: (_) => _HojaRestablecer(correo: _emailController.text.trim()),
                          ),
                  style: TextButton.styleFrom(foregroundColor: c.acento, shape: Formas.squircle(12)),
                  child: const Text(
                    "¿Olvidaste tu contraseña?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.secundario,
                    shape: Formas.squircle(24),
                    elevation: 4,
                  ),
                  onPressed: _isLoading ? null : _iniciarSesion,
                  child: _isLoading
                      ? CircularProgressIndicator(color: c.sobreAcento)
                      : Text(
                          "Iniciar sesión",
                          style: TextStyle(
                            color: c.sobreAcento,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿No tienes cuenta? ",
                    style: TextStyle(color: c.textoSecundario, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistroUsuario(),
                              ),
                            );
                          },
                    child: Text(
                      "Regístrate",
                      style: TextStyle(
                        color: c.acento,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: c.acento,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // El teclado también activa el botón de iniciar sesión
  Widget _buildTextField(
    String hint,
    bool isObscure,
    TextEditingController controller, {
    TextInputAction textInputAction = TextInputAction.next,
    VoidCallback? onSubmitted,
  }) {
    final c = context.colores;
    return TextField(
      controller: controller,
      obscureText: isObscure,
      textInputAction: textInputAction,
      onSubmitted: (_) {
        if (onSubmitted != null) {
          onSubmitted();
        }
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textoTenue),
        filled: true,
        fillColor: c.superficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: const BordeSquircle(),
        enabledBorder: const BordeSquircle(),
        focusedBorder: BordeSquircle(borderSide: BorderSide(color: c.acento, width: 1.5)),
        errorBorder: BordeSquircle(borderSide: BorderSide(color: c.emergencia)),
        focusedErrorBorder: BordeSquircle(borderSide: BorderSide(color: c.emergencia, width: 1.5)),
        errorStyle: TextStyle(color: c.emergencia),
      ),
    );
  }
}

class _HojaRestablecer extends StatefulWidget {
  const _HojaRestablecer({required this.correo});
  final String correo;

  @override
  State<_HojaRestablecer> createState() => _HojaRestablecerState();
}

class _HojaRestablecerState extends State<_HojaRestablecer> {
  late final _correo = TextEditingController(text: widget.correo);
  bool _enviando = false;
  bool _enviado = false;

  @override
  void dispose() {
    _correo.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final correo = _correo.text.trim();
    if (correo.isEmpty) return _avisar('Escribe el correo de tu cuenta.');
    FocusScope.of(context).unfocus();
    setState(() => _enviando = true);
    try {
      await FirebaseAuth.instance.setLanguageCode('es');
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);
      if (mounted) setState(() => _enviado = true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        if (mounted) setState(() => _enviado = true);
      } else {
        _avisar(e.code == 'invalid-email' ? 'El formato del correo es inválido.' : 'No se pudo enviar el correo. Inténtalo de nuevo.');
      }
    } catch (_) {
      _avisar('No se pudo enviar el correo. Revisa tu conexión.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _avisar(String texto) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.paddingOf(context).bottom + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
          child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16), decoration: Formas.fondo(c.divisor, 2)),
        ),
        Text('Restablecer contraseña', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800).display),
        const SizedBox(height: 6),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _enviado
                ? 'Si ${_correo.text.trim()} tiene una cuenta, te llegará un correo con un enlace para crear una contraseña nueva. Revisa también la carpeta de spam.'
                : 'Te enviaremos un enlace a tu correo para que crees una contraseña nueva.',
            key: ValueKey(_enviado),
            style: TextStyle(fontSize: 14, height: 1.4, color: c.textoSecundario),
          ),
        ),
        const SizedBox(height: 18),
        if (!_enviado)
          TextField(
            controller: _correo,
            enabled: !_enviando,
            autofocus: widget.correo.isEmpty,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _enviar(),
            decoration: InputDecoration(
              hintText: 'Correo electrónico',
              hintStyle: TextStyle(color: c.textoTenue),
              filled: true,
              fillColor: c.superficie,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: const BordeSquircle(),
              enabledBorder: const BordeSquircle(),
              focusedBorder: BordeSquircle(borderSide: BorderSide(color: c.acento, width: 1.5)),
            ),
          ),
        const SizedBox(height: 16),
        Presionable(
          child: SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _enviando ? null : _enviado ? () => Navigator.pop(context) : _enviar,
              style: FilledButton.styleFrom(
                backgroundColor: c.acento,
                foregroundColor: c.sobreAcento,
                disabledBackgroundColor: c.acento.withValues(alpha: .5),
                disabledForegroundColor: c.sobreAcento,
                shape: Formas.squircle(16),
              ),
              child: _enviando
                  ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: c.sobreAcento))
                  : Text(_enviado ? 'Entendido' : 'Enviar enlace', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ]),
    );
  }
}
