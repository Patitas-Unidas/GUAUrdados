import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:guaurdados_oficial/services/perfiles_usuario_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:guaurdados_oficial/widgets/campo.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
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
  final _errorCorreo = ValueNotifier<String?>(null);
  final _errorPassword = ValueNotifier<String?>(null);

  @override
  void dispose() {
    for (final controller in [_nombre, _correo, _password, _confirmacion]) {
      controller.dispose();
    }
    _errorCorreo.dispose();
    _errorPassword.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    _errorCorreo.value = null;
    _errorPassword.value = null;
    if (_isLoading || !_formKey.currentState!.validate()) return;
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
      avisar(context, mensaje, tipo: TipoAviso.exito);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Homepage()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      switch (e.code) {
        case 'email-already-in-use':
          _errorCorreo.value = 'Este correo ya tiene una cuenta. Toca «Inicia sesión», más abajo.';
        case 'invalid-email':
          _errorCorreo.value = 'Revisa el correo: debe verse como nombre@correo.cl';
        case 'weak-password':
          _errorPassword.value = 'Elige una contraseña más difícil de adivinar (mezcla letras y números).';
        case 'network-request-failed':
          avisar(context, 'No hay conexión a internet. Revísala e inténtalo de nuevo.', tipo: TipoAviso.error, icono: Iconos.wifiOff);
        case 'too-many-requests':
          avisar(context, 'Se crearon muchas cuentas seguidas desde esta red. Espera unos minutos o usa tus datos móviles.', tipo: TipoAviso.error, icono: Iconos.clock);
        default:
          avisar(context, 'No se pudo crear la cuenta. Inténtalo de nuevo.', tipo: TipoAviso.error);
      }
    } catch (_) {
      if (!mounted) return;
      avisar(context, 'No se pudo completar el registro. Revisa tu conexión.', tipo: TipoAviso.error, icono: Iconos.wifiOff);
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
                ValueListenableBuilder<String?>(
                  valueListenable: _errorCorreo,
                  builder: (context, error, _) => _buildTextField(
                    "Correo electrónico",
                    false,
                    _correo,
                    (value) => correoValido.hasMatch(value?.trim() ?? '')
                        ? null
                        : 'Revisa el correo: debe verse como nombre@correo.cl',
                    errorForzado: error,
                    alCambiar: () => _errorCorreo.value = null,
                  ),
                ),
                const SizedBox(height: 16),
                ValueListenableBuilder<String?>(
                  valueListenable: _errorPassword,
                  builder: (context, error, _) => _buildTextField(
                    "Contraseña (mínimo 6 caracteres)",
                    true,
                    _password,
                    (value) => (value?.length ?? 0) < 6
                        ? 'Usa al menos 6 caracteres.'
                        : null,
                    errorForzado: error,
                    alCambiar: () => _errorPassword.value = null,
                  ),
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
                FormField<bool>(
                  initialValue: _aceptaTerminos,
                  validator: (valor) => valor == true ? null : 'Para crear tu cuenta, acepta los términos y la política de privacidad.',
                  builder: (campo) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Row(
                  children: [
                    Checkbox(
                      value: campo.value ?? false,
                      isError: campo.hasError,
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              _aceptaTerminos = value ?? false;
                              campo.didChange(_aceptaTerminos);
                              if (campo.hasError) campo.validate();
                            },
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
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        child: campo.hasError
                            ? Padding(
                                padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
                                child: Text(
                                  campo.errorText!,
                                  style: TextStyle(color: c.emergenciaTexto, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.3),
                                ),
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                    ],
                  ),
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
    String? Function(String?) validator, {
    String? errorForzado,
    VoidCallback? alCambiar,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      forceErrorText: errorForzado,
      onChanged: alCambiar == null ? null : (_) => alCambiar(),
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
      decoration: decoracionCampo(context, pista: hint),
    );
  }
}
