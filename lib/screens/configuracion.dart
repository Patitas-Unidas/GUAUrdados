import 'package:firebase_auth/firebase_auth.dart';
import 'package:guaurdados_oficial/services/perfiles_usuario_repository.dart';
import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/services/notificaciones_service.dart';
import 'package:guaurdados_oficial/theme/preferencias.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/avatar_usuario.dart';
import 'package:guaurdados_oficial/widgets/selector_avatar.dart';

import 'iniciar_sesion.dart';

const _version = '1.0.0';

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});

  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  User? get _usuario => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final nombre = _usuario?.displayName;
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuración', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700).display),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + MediaQuery.paddingOf(context).bottom),
        children: enCascada([
          const _TituloSeccion('Apariencia'),
          _Grupo(children: [
            _Bloque(
              titulo: 'Tema',
              nota: '"Sistema" usa el modo claro u oscuro que tengas en tu teléfono.',
              child: ValueListenableBuilder<ThemeMode>(
                valueListenable: Preferencias.tema,
                builder: (_, actual, _) => _Selector<ThemeMode>(
                  actual: actual,
                  alCambiar: Preferencias.cambiarTema,
                  opciones: const [
                    (ThemeMode.system, Iconos.sunMoon, 'Sistema'),
                    (ThemeMode.light, Iconos.sun, 'Claro'),
                    (ThemeMode.dark, Iconos.moon, 'Oscuro'),
                  ],
                ),
              ),
            ),
          ]),

          const _TituloSeccion('Accesibilidad'),
          _Grupo(children: [
            _Bloque(
              titulo: 'Tamaño del texto',
              nota: 'Se suma al tamaño de texto que tengas configurado en el teléfono.',
              child: ValueListenableBuilder<double>(
                valueListenable: Preferencias.escalaTexto,
                builder: (_, actual, _) => _Selector<double>(
                  actual: actual,
                  alCambiar: Preferencias.cambiarEscalaTexto,
                  opciones: [
                    for (final (escala, etiqueta) in Preferencias.escalasTexto) (escala, Iconos.aLargeSmall, etiqueta),
                  ],
                ),
              ),
            ),
          ]),

          const _TituloSeccion('Notificaciones'),
          const _Grupo(children: [
            _Fila(
              icono: Iconos.siren,
              titulo: 'Alertas de emergencia',
              subtitulo: 'Aviso inmediato cuando alguien reporta una emergencia.',
              final_: _Proximamente(),
            ),
            _Fila(
              icono: Iconos.pawPrint,
              titulo: 'Perros que sigues',
              subtitulo: 'Alimentación, estado médico y novedades del foro.',
              final_: _Proximamente(),
            ),
          ]),

          const _TituloSeccion('Cuenta'),
          _Grupo(children: [
            _Fila(
              icono: Iconos.circleUser,
              titulo: 'Foto de perfil',
              final_: AvatarUsuario(fotoUrl: fotoPerfilActual(_usuario), radio: 18),
              alTocar: () async {
                await elegirFotoPerfil(context);
                if (mounted) setState(() {});
              },
            ),
            _Fila(
              icono: Iconos.user,
              titulo: 'Nombre',
              subtitulo: (nombre == null || nombre.isEmpty) ? 'Sin nombre' : nombre,
              final_: Icono(Iconos.pencil, size: 20, color: c.textoTenue),
              alTocar: _editarNombre,
            ),
            _Fila(
              icono: Iconos.mail,
              titulo: 'Correo',
              subtitulo: _usuario?.email ?? '—',
            ),
            _Fila(
              icono: Iconos.logOut,
              titulo: 'Cerrar sesión',
              color: c.emergencia,
              alTocar: _cerrarSesion,
            ),
            _Fila(
              icono: Iconos.trash2,
              titulo: 'Eliminar cuenta',
              subtitulo: 'Borra tu cuenta de GUAUrdados de forma permanente.',
              color: c.emergencia,
              alTocar: _eliminarCuenta,
            ),
          ]),

          const _TituloSeccion('Acerca de'),
          const _Grupo(children: [
            _Fila(icono: Iconos.info, titulo: 'Versión', subtitulo: _version),
            _Fila(
              icono: Iconos.users,
              titulo: 'Hecho por Patitas Unidas',
              subtitulo: 'Frano Cerda, Valentina Muñoz, Aylin Rojas, Mishas Silva y Alejandra Zamora. '
                  'Proyecto de Software, USM.',
            ),
            _Fila(
              icono: Iconos.handHeart,
              titulo: 'En colaboración con GUAU',
              subtitulo: 'Grupo Universitario de Ayuda Canina, USM sede Viña del Mar.',
            ),
            _Fila(icono: Iconos.fileText, titulo: 'Términos y condiciones', final_: _Proximamente()),
            _Fila(icono: Iconos.lock, titulo: 'Política de privacidad', final_: _Proximamente()),
          ]),
        ]),
      ),
    );
  }

  Future<void> _editarNombre() async {
    final nuevo = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoEditarNombre(nombreInicial: _usuario?.displayName ?? ''),
    );
    if (nuevo == null || nuevo.trim().isEmpty) return;
    try {
      final usuario = _usuario;
      if (usuario == null) return;
      await usuario.updateDisplayName(nuevo.trim());
      await usuario.reload();
      final usuarioActualizado = FirebaseAuth.instance.currentUser;
      if (usuarioActualizado != null) {
        await PerfilesUsuarioRepository().sincronizar(usuarioActualizado);
      }
      if (mounted) setState(() {});
    } catch (_) {
      _avisar('No se pudo guardar el nombre.');
    }
  }

  Future<void> _cerrarSesion() async {
    try {
      try {
        await NotificacionesService.desregistrar().timeout(const Duration(seconds: 3));
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const IniciarSesion()),
        (route) => false,
      );
    } catch (_) {
      _avisar('No se pudo cerrar la sesión.');
    }
  }

  Future<void> _eliminarCuenta() async {
    final c = context.colores;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar tu cuenta?'),
        content: const Text('Se borrará tu cuenta de forma permanente. Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: c.emergencia),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await _usuario?.delete();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const IniciarSesion()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _avisar(e.code == 'requires-recent-login'
          ? 'Por seguridad, cierra sesión y vuelve a entrar antes de eliminar tu cuenta.'
          : 'No se pudo eliminar la cuenta.');
    }
  }

  void _avisar(String texto) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }
}

class _DialogoEditarNombre extends StatefulWidget {
  const _DialogoEditarNombre({required this.nombreInicial});

  final String nombreInicial;

  @override
  State<_DialogoEditarNombre> createState() => _DialogoEditarNombreState();
}

class _DialogoEditarNombreState extends State<_DialogoEditarNombre> {
  late final TextEditingController _control = TextEditingController(
    text: widget.nombreInicial,
  );

  @override
  void dispose() {
    _control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Tu nombre'),
    content: TextField(
      controller: _control,
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      decoration: const InputDecoration(hintText: 'Cómo te verán en los foros'),
      onSubmitted: (texto) => Navigator.of(context).pop(texto),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
      TextButton(onPressed: () => Navigator.of(context).pop(_control.text), child: const Text('Guardar')),
    ],
  );
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Text(
      texto.toUpperCase(),
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: .4, color: context.colores.textoTenue),
    ),
  );
}

class _Grupo extends StatelessWidget {
  const _Grupo({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Material(
    color: context.colores.superficie,
    shape: Formas.squircle(18),
    clipBehavior: Clip.antiAlias,
    child: Column(children: [
      for (var i = 0; i < children.length; i++) ...[
        if (i > 0) const Divider(height: 1, indent: 56),
        children[i],
      ],
    ]),
  );
}

class _Fila extends StatelessWidget {
  const _Fila({required this.icono, required this.titulo, this.subtitulo, this.final_, this.color, this.alTocar});
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final Widget? final_;
  final Color? color;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return InkWell(
      onTap: alTocar,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [
            Icono(icono, color: color ?? c.textoSecundario),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(titulo, style: TextStyle(fontSize: 16, color: color)),
                if (subtitulo != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitulo!, style: TextStyle(fontSize: 13, color: c.textoSecundario)),
                ],
              ]),
            ),
            if (final_ != null) ...[const SizedBox(width: 12), final_!],
          ]),
        ),
      ),
    );
  }
}

class _Bloque extends StatelessWidget {
  const _Bloque({required this.titulo, required this.child, this.nota});
  final String titulo;
  final Widget child;
  final String? nota;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      child,
      if (nota != null) ...[
        const SizedBox(height: 10),
        Text(nota!, style: TextStyle(fontSize: 12, color: context.colores.textoSecundario)),
      ],
    ]),
  );
}

class _Proximamente extends StatelessWidget {
  const _Proximamente();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: Formas.fondo(context.colores.contenedor, 8),
    child: Text('Próximamente', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.colores.textoSecundario)),
  );
}

class _Selector<T> extends StatelessWidget {
  const _Selector({required this.actual, required this.opciones, required this.alCambiar});
  final T actual;
  final List<(T, IconData, String)> opciones;
  final ValueChanged<T> alCambiar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: Formas.fondo(c.fondo, 14),
      child: Row(children: [
        for (final (valor, icono, texto) in opciones)
          Expanded(
            child: Semantics(
              button: true,
              selected: valor == actual,
              child: GestureDetector(
                onTap: () => alCambiar(valor),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  height: 64,
                  decoration: Formas.fondo(valor == actual ? c.acento : c.acento.withValues(alpha: 0), 11),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icono(icono, color: valor == actual ? c.sobreAcento : c.textoSecundario),
                    const SizedBox(height: 4),
                    Text(
                      texto,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: valor == actual ? c.sobreAcento : c.textoSecundario,
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
