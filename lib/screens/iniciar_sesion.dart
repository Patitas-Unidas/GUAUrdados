import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        password: _passwordController.text.trim(),
      );

      // Verificación de seguridad de Flutter después de un "await"
      if (!mounted) return;

      // Mensaje de éxito agregado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Inicio de sesión exitoso!'), backgroundColor: Colors.green),
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
      if (e.code == 'invalid-credential' || e.code == 'user-not-found' || e.code == 'wrong-password') {
        mensajeError = 'Credenciales incorrectas. Revisa tu correo y contraseña.';
      } else if (e.code == 'invalid-email') {
        mensajeError = 'El formato del correo es inválido.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensajeError), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error inesperado de conexión.'), backgroundColor: Colors.red),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF4E2D7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              const Text(
                "Bienvenido a",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              const SizedBox(height: 10),

              Image.asset(
                'fotos/GUAUrdados.png',
                height: 180,
                fit: BoxFit.contain,
              ),

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

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "¿Olvidaste tu contraseña?",
                  style: TextStyle(
                    color: Color(0xFFE86A4D),
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
                    backgroundColor: const Color(0xFF826C63),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _isLoading ? null : _iniciarSesion,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      color: Colors.white,
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
                  const Text(
                    "¿No tienes cuenta? ",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegistroUsuario(),
                        ),
                      );
                    },
                    child: const Text(
                      "Regístrate",
                      style: TextStyle(
                        color: Color(0xFFE86A4D),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
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

  // El teclado también activa el boton de inicar sesión
  Widget _buildTextField(
      String hint,
      bool isObscure,
      TextEditingController controller, {
        TextInputAction textInputAction = TextInputAction.next,
        VoidCallback? onSubmitted,
      }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
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
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}