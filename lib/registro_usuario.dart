import 'package:flutter/material.dart';
import 'iniciar_sesion.dart';

class RegistroUsuario extends StatelessWidget {
  const RegistroUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4E2D7), // Color durazno del fondo
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Únete a",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B2B2B),
                ),
              ),
              Image.asset(
                'fotos/Letras.png', // <-- Cambia esto por el nombre de tu archivo
                height: 40, // Ajusta el tamaño
              ),
              const SizedBox(height: 40),

              _buildTextField("Nombre completo", false),
              const SizedBox(height: 16),
              _buildTextField("Correo electrónico", false),
              const SizedBox(height: 16),
              _buildTextField("Contraseña", true),
              const SizedBox(height: 16),
              _buildTextField("Confirmar contraseña", true),

              const SizedBox(height: 24),

              // Checkbox de términos
              Row(
                children: [
                  Checkbox(
                    value: true, // Aquí debes manejar el estado real
                    onChanged: (bool? value) {},
                    activeColor: Colors.blue,
                  ),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: "Acepto los ",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                        children: [
                          TextSpan(
                            text: "Términos y Condiciones",
                            style: TextStyle(color: Color(0xFFE86A4D), decoration: TextDecoration.underline),
                          ),
                          TextSpan(text: " y la "),
                          TextSpan(
                            text: "Política de Privacidad",
                            style: TextStyle(color: Color(0xFFE86A4D), decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Botón Iniciar Sesión
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF826C63), // Color café
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 4,
                  ),
                  onPressed: () {
                    // Acción de registro
                  },
                  child: const Text(
                    "Crear cuenta",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Link al login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "¿Ya tienes cuenta? ",
                    style: TextStyle(color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const IniciarSesion()),
                      );
                    },
                    child: const Text(
                      "Inicia Sesión",
                      style: TextStyle(
                        color: Color(0xFFE86A4D),
                        fontWeight: FontWeight.bold,
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

  // Widget reutilizable para los campos de texto
  Widget _buildTextField(String hint, bool isObscure) {
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
        obscureText: isObscure,
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