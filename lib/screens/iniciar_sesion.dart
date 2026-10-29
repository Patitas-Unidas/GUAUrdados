import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guaurdados_oficial/services/notificaciones_service.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/logo.dart';
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
        SnackBar(
          content: const Text('¡Inicio de sesión exitoso!'),
          backgroundColor: context.colores.exito,
        ),
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
        SnackBar(content: Text(mensajeError), backgroundColor: context.colores.emergencia),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error inesperado de conexión.'),
          backgroundColor: context.colores.emergencia,
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
                child: Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    color: c.acento,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 32),

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
