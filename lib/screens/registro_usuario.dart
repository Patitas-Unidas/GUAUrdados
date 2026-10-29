import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guaurdados_oficial/services/perfiles_usuario_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/logo.dart';
import 'iniciar_sesion.dart';
import 'homepage.dart';

class RegistroUsuario extends StatefulWidget {
  const RegistroUsuario({super.key});

  @override
  State<RegistroUsuario> createState() => _RegistroUsuarioState();
}

class _RegistroUsuarioState extends State<RegistroUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _correo = TextEditingController();
  final _password = TextEditingController();
  final _confirmacion = TextEditingController();
  bool _aceptaTerminos = false;
  bool _isLoading = false;

  @override
  void dispose() {
    for (final controller in [_nombre, _correo, _password, _confirmacion]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _registrar() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes aceptar los términos y la política de privacidad.',
          ),
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final nombre = _nombre.text.trim();
    setState(() => _isLoading = true);
    try {
      final credencial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _correo.text.trim(),
            password: _password.text,
          );
      // La cuenta ya existe aunque falle la actualización del nombre.
      var mensaje = '¡Cuenta creada correctamente!';
      try {
        await credencial.user!.updateDisplayName(nombre);
      } catch (_) {
        mensaje = 'Cuenta creada, pero no se pudo guardar tu nombre.';
      }
      try {
        await credencial.user!.reload();
        final usuarioActual = FirebaseAuth.instance.currentUser;
        if (usuarioActual != null) {
          await PerfilesUsuarioRepository().sincronizar(usuarioActual);
        }
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Homepage()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final mensaje = switch (e.code) {
        'email-already-in-use' =>
          'Este correo ya tiene una cuenta. Inicia sesión.',
        'invalid-email' => 'Ingresa un correo electrónico válido.',
        'weak-password' =>
          'La contraseña no cumple los requisitos de seguridad.',
        'network-request-failed' =>
          'Revisa tu conexión e inténtalo nuevamente.',
        'too-many-requests' => 'Demasiados intentos. Espera un momento.',
        'operation-not-allowed' => 'El registro por correo no está habilitado.',
        _ => 'No se pudo crear la cuenta. Inténtalo nuevamente.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo completar el registro. Revisa tu conexión.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  "Únete a",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: c.texto,
                  ).display,
                ),
                const NombreGUAUrdados(alto: 40),
                const SizedBox(height: 40),

                _buildTextField(
                  "Nombre completo",
                  false,
                  _nombre,
                  (value) => value == null || value.trim().isEmpty
                      ? 'Ingresa tu nombre.'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "Correo electrónico",
                  false,
                  _correo,
                  (value) =>
                      RegExp(
                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                      ).hasMatch(value?.trim() ?? '')
                      ? null
                      : 'Ingresa un correo válido.',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "Contraseña",
                  true,
                  _password,
                  (value) => (value?.length ?? 0) < 6
                      ? 'Usa al menos 6 caracteres.'
                      : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  "Confirmar contraseña",
                  true,
                  _confirmacion,
                  (value) => value != _password.text || (value?.isEmpty ?? true)
                      ? 'Las contraseñas deben coincidir.'
                      : null,
                ),

                const SizedBox(height: 24),

                // Términos y condiciones
                Row(
                  children: [
                    Checkbox(
                      value: _aceptaTerminos,
                      onChanged: _isLoading
                          ? null
                          : (value) => setState(
                              () => _aceptaTerminos = value ?? false,
                            ),
                      activeColor: c.acento,
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: "Acepto los ",
                          style: TextStyle(fontSize: 12, color: c.textoSecundario),
                          children: [
                            TextSpan(
                              text: "Términos y condiciones",
                              style: TextStyle(
                                color: c.acento,
                                decoration: TextDecoration.underline,
                                decorationColor: c.acento,
                              ),
                            ),
                            const TextSpan(text: " y la "),
                            TextSpan(
                              text: "Política de privacidad",
                              style: TextStyle(
                                color: c.acento,
                                decoration: TextDecoration.underline,
                                decorationColor: c.acento,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Botón crear cuenta
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.secundario,
                      shape: Formas.squircle(24),
                      elevation: 4,
                    ),
                    onPressed: _isLoading ? null : _registrar,
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: c.sobreAcento,
                            ),
                          )
                        : Text(
                            "Crear cuenta",
                            style: TextStyle(
                              color: c.sobreAcento,
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
                    Text(
                      "¿Ya tienes cuenta? ",
                      style: TextStyle(color: c.textoSecundario),
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const IniciarSesion(),
                                ),
                              );
                            },
                      child: Text(
                        "Inicia sesión",
                        style: TextStyle(
                          color: c.acento,
                          fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildTextField(
    String hint,
    bool isObscure,
    TextEditingController controller,
    String? Function(String?) validator,
  ) {
    final c = context.colores;
    return TextFormField(
      controller: controller,
      validator: validator,
      enabled: !_isLoading,
      autocorrect: !isObscure,
      enableSuggestions: !isObscure,
      keyboardType: controller == _correo
          ? TextInputType.emailAddress
          : TextInputType.text,
      textInputAction: controller == _confirmacion
          ? TextInputAction.done
          : TextInputAction.next,
      onFieldSubmitted: controller == _confirmacion
          ? (_) => _registrar()
          : null,
      obscureText: isObscure,
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
