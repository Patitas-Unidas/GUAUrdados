import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/models/publicacion_foro.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/widgets/avatar_usuario.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';
import 'package:shared_preferences/shared_preferences.dart';

TextStyle estiloEmoji(double tamano) => TextStyle(fontSize: tamano, fontFamily: 'Noto Color Emoji', fontFamilyFallback: const ['Apple Color Emoji'], height: 1.15);

class BarraReacciones extends StatefulWidget {
  const BarraReacciones({super.key, required this.publicacion, required this.alComentar});

  final PublicacionForo publicacion;
  final VoidCallback alComentar;

  @override
  State<BarraReacciones> createState() => _BarraReaccionesState();
}

class _BarraReaccionesState extends State<BarraReacciones> {
  static const _clavePista = 'pista_reacciones_vista';
  final _boton = GlobalKey();

  Future<void> _reaccionar(String? emoji) async {
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;
    HapticFeedback.lightImpact();
    try {
      await ForoRepository().reaccionar(widget.publicacion, usuario, emoji);
    } catch (_) {
      if (mounted) avisar(context, 'No se pudo guardar tu reacción. Revisa tu conexión.', tipo: TipoAviso.error);
    }
  }

  Future<void> _tocar(String? actual) async {
    await _reaccionar(actual == null ? emojisReaccion.first : null);
    if (actual != null || !mounted) return;
    try {
      final preferencias = await SharedPreferences.getInstance();
      if (preferencias.getBool(_clavePista) == true) return;
      await preferencias.setBool(_clavePista, true);
      if (mounted) avisar(context, 'Mantén apretado "Me gusta" para elegir otra reacción.', icono: Iconos.smile);
    } catch (_) {}
  }

  Future<void> _elegir(String? actual) async {
    final caja = _boton.currentContext?.findRenderObject() as RenderBox?;
    if (caja == null) return;
    HapticFeedback.mediumImpact();
    final origen = caja.localToGlobal(Offset.zero) & caja.size;
    final elegido = await Navigator.of(context).push<String>(_RutaSelector(origen: origen, actual: actual));
    if (elegido == null) return;
    await _reaccionar(elegido == actual ? null : elegido);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final publicacion = widget.publicacion;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final mia = publicacion.reaccionDe(uid);
    final total = publicacion.reacciones.length;
    final comentarios = publicacion.numComentarios;

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: total == 0 && comentarios == 0
            ? const SizedBox(width: double.infinity, height: 10)
            : Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Row(children: [
                  if (total > 0)
                    Flexible(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => mostrarHoja<void>(context, builder: (_) => _HojaReacciones(publicacion: publicacion)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            _Apilados(emojis: publicacion.emojisPrincipales),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                mia == null ? '$total' : total == 1 ? 'Tú' : 'Tú y ${total - 1} más',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13.5, color: c.textoSecundario),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (comentarios > 0)
                    InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: widget.alComentar,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                        child: Text(
                          comentarios == 1 ? '1 comentario' : '$comentarios comentarios',
                          style: TextStyle(fontSize: 13.5, color: c.textoSecundario),
                        ),
                      ),
                    ),
                ]),
              ),
      ),
      Divider(height: 1, color: c.divisor),
      Row(children: [
        Expanded(
          child: Presionable(
            child: InkWell(
              key: _boton,
              borderRadius: BorderRadius.circular(12),
              onTap: () => _tocar(mia),
              onLongPress: () => _elegir(mia),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (hijo, animacion) => ScaleTransition(scale: animacion, child: hijo),
                  child: Row(
                    key: ValueKey(mia),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (mia == null)
                        Icono(Iconos.heart, size: 19, color: c.textoSecundario)
                      else
                        Text(mia, style: estiloEmoji(18)),
                      const SizedBox(width: 7),
                      Text(
                        mia == null || mia == emojisReaccion.first ? 'Me gusta' : 'Reaccionaste',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: mia == null ? c.textoSecundario : c.acento),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Presionable(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.alComentar,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icono(Iconos.messageCircle, size: 19, color: c.textoSecundario),
                  const SizedBox(width: 7),
                  Text('Comentar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textoSecundario)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    ]);
  }
}

class _Apilados extends StatelessWidget {
  const _Apilados({required this.emojis});

  final List<String> emojis;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return SizedBox(
      width: 24 + (emojis.length - 1) * 15.0,
      height: 24,
      child: Stack(children: [
        for (final (i, emoji) in emojis.indexed)
          Positioned(
            left: i * 15.0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: c.superficie, shape: BoxShape.circle),
              child: Center(child: Text(emoji, style: estiloEmoji(14))),
            ),
          ),
      ]),
    );
  }
}

class _RutaSelector extends PopupRoute<String> {
  _RutaSelector({required this.origen, required this.actual});

  final Rect origen;
  final String? actual;

  @override
  Color? get barrierColor => Colors.transparent;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Cerrar';

  @override
  Duration get transitionDuration => const Duration(milliseconds: 420);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 160);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final c = context.colores;
    final pantalla = MediaQuery.sizeOf(context);
    const tamano = 44.0;
    const ancho = tamano * 7 + 16.0;
    final izquierda = (origen.left - 4).clamp(12.0, pantalla.width - ancho - 12);
    final arriba = origen.top - tamano - 26 < MediaQuery.paddingOf(context).top + 8 ? origen.bottom + 6 : origen.top - tamano - 26;
    return Stack(children: [
      Positioned(
        left: izquierda,
        top: arriba,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: const Interval(0, .4)),
          child: ScaleTransition(
            alignment: Alignment(((origen.center.dx - izquierda) / ancho) * 2 - 1, 1),
            scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: ancho + 2,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: ShapeDecoration(
                  color: c.superficie,
                  shape: Formas.squircle(26, lado: BorderSide(color: c.divisor)),
                  shadows: const [BoxShadow(color: Color(0x2A000000), blurRadius: 18, offset: Offset(0, 6))],
                ),
                child: Row(children: [
                  for (final (i, emoji) in emojisReaccion.indexed)
                    _EmojiSelector(
                      emoji: emoji,
                      elegido: emoji == actual,
                      tamano: tamano,
                      animacion: CurvedAnimation(
                        parent: animation,
                        curve: Interval((i * .07).clamp(0, .6), (i * .07 + .45).clamp(0, 1), curve: Curves.easeOutBack),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _EmojiSelector extends StatelessWidget {
  const _EmojiSelector({required this.emoji, required this.elegido, required this.tamano, required this.animacion});

  final String emoji;
  final bool elegido;
  final double tamano;
  final Animation<double> animacion;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return ScaleTransition(
      scale: animacion,
      child: Presionable(
        escala: 1.25,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.of(context).pop(emoji);
          },
          child: Container(
            width: tamano,
            height: tamano,
            decoration: elegido ? ShapeDecoration(color: c.contenedor, shape: const CircleBorder()) : null,
            child: Center(child: Text(emoji, style: estiloEmoji(26))),
          ),
        ),
      ),
    );
  }
}

class _HojaReacciones extends StatefulWidget {
  const _HojaReacciones({required this.publicacion});

  final PublicacionForo publicacion;

  @override
  State<_HojaReacciones> createState() => _HojaReaccionesState();
}

class _HojaReaccionesState extends State<_HojaReacciones> {
  String? _filtro;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final todas = [...widget.publicacion.reacciones]..sort((a, b) => a.uid == uid ? -1 : b.uid == uid ? 1 : a.nombre.compareTo(b.nombre));
    final cuenta = <String, int>{};
    for (final reaccion in todas) {
      cuenta[reaccion.emoji] = (cuenta[reaccion.emoji] ?? 0) + 1;
    }
    final presentes = emojisReaccion.where(cuenta.containsKey).toList();
    final visibles = _filtro == null ? todas : todas.where((r) => r.emoji == _filtro).toList();

    Widget filtro(String? emoji, String texto) {
      final activo = _filtro == emoji;
      return Presionable(
        child: GestureDetector(
          onTap: () => setState(() => _filtro = emoji),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: ShapeDecoration(
              color: activo ? c.contenedor : c.superficie,
              shape: Formas.squircle(14, lado: BorderSide(color: activo ? c.acento.withValues(alpha: .45) : c.divisor)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (emoji != null) ...[Text(emoji, style: estiloEmoji(15)), const SizedBox(width: 5)],
              Text(texto, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: activo ? c.texto : c.textoSecundario)),
            ]),
          ),
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .7),
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      padding: EdgeInsets.fromLTRB(0, 10, 0, 12 + MediaQuery.paddingOf(context).bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14), decoration: Formas.fondo(c.divisor, 2))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text('Reacciones', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              filtro(null, 'Todas ${todas.length}'),
              for (final emoji in presentes) ...[const SizedBox(width: 6), filtro(emoji, '${cuenta[emoji]}')],
            ],
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 4, 20, 4),
            itemCount: visibles.length,
            itemBuilder: (context, i) {
              final reaccion = visibles[i];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(children: [
                  AvatarUsuario(uid: reaccion.uid, fotoUrl: reaccion.foto, nombre: reaccion.nombre, radio: 19),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reaccion.uid == uid ? 'Tú' : reaccion.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(reaccion.emoji, style: estiloEmoji(22)),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }
}
