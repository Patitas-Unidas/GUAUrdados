import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/models/comentario.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aparicion.dart';
import 'package:guaurdados_oficial/widgets/avatar_usuario.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:guaurdados_oficial/widgets/campo.dart';
import 'package:guaurdados_oficial/widgets/esqueleto.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';
import 'package:guaurdados_oficial/widgets/tarjeta_emergencia.dart';

Future<void> mostrarComentarios(
  BuildContext context, {
  required String idAutor,
  required String nombreAutor,
  required String textoPublicacion,
  required Stream<List<Comentario>> comentarios,
  required Future<void> Function(String texto) comentar,
  required Future<void> Function(Comentario comentario) eliminar,
  bool esAdmin = false,
}) => mostrarHoja<void>(
  context,
  builder: (_) => _HojaComentarios(
    idAutor: idAutor,
    nombreAutor: nombreAutor,
    textoPublicacion: textoPublicacion,
    comentarios: comentarios,
    comentar: comentar,
    eliminar: eliminar,
    esAdmin: esAdmin,
  ),
);

class _HojaComentarios extends StatefulWidget {
  const _HojaComentarios({
    required this.idAutor,
    required this.nombreAutor,
    required this.textoPublicacion,
    required this.comentarios,
    required this.comentar,
    required this.eliminar,
    required this.esAdmin,
  });

  final String idAutor;
  final String nombreAutor;
  final String textoPublicacion;
  final Stream<List<Comentario>> comentarios;
  final Future<void> Function(String texto) comentar;
  final Future<void> Function(Comentario comentario) eliminar;
  final bool esAdmin;

  @override
  State<_HojaComentarios> createState() => _HojaComentariosState();
}

class _HojaComentariosState extends State<_HojaComentarios> {
  final _texto = TextEditingController();
  late final StreamSubscription<List<Comentario>> _suscripcion;
  List<Comentario>? _lista;
  bool _fallo = false;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _suscripcion = widget.comentarios.listen(
      (lista) => setState(() {
        _lista = lista;
        _fallo = false;
      }),
      onError: (_) {
        if (mounted) setState(() => _fallo = true);
      },
    );
  }

  @override
  void dispose() {
    _suscripcion.cancel();
    _texto.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _texto.text.trim();
    if (texto.isEmpty || _enviando) return;
    HapticFeedback.lightImpact();
    _texto.clear();
    setState(() => _enviando = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _enviando = false);
    });
    try {
      await widget.comentar(texto).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      return;
    } catch (_) {
      if (!mounted) return;
      if (_texto.text.isEmpty) _texto.text = texto;
      setState(() {});
      avisar(context, 'No se pudo enviar tu comentario. Revisa tu conexión.', tipo: TipoAviso.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final medidas = MediaQuery.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return Container(
      height: (medidas.size.height * .82).clamp(0, medidas.size.height - medidas.viewInsets.bottom - medidas.padding.top - 56).toDouble(),
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      child: Column(
        children: [
          Center(
            child: Container(width: 36, height: 4, margin: const EdgeInsets.only(top: 10, bottom: 14), decoration: Formas.fondo(c.divisor, 2)),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                final lista = _lista ?? const <Comentario>[];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('Comentarios', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
                              if (lista.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                                  decoration: Formas.fondo(c.contenedor, 10),
                                  child: Text(
                                    '${lista.length}',
                                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: c.textoSecundario),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${widget.nombreAutor}: ',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                TextSpan(text: widget.textoPublicacion),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13.5, height: 1.4, color: c.textoSecundario),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: c.divisor),
                    Expanded(
                      child: _fallo && _lista == null
                          ? const _SinComentarios(fallo: true)
                          : _lista == null
                          ? ListView(
                              padding: const EdgeInsets.all(20),
                              children: [
                                for (var i = 0; i < 3; i++)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 18),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        BloqueEsqueleto(ancho: 36, alto: 36, circular: true),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              BloqueEsqueleto(ancho: 120, alto: 14, radio: 6),
                                              SizedBox(height: 8),
                                              BloqueEsqueleto(ancho: double.infinity, alto: 14, radio: 6),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            )
                          : lista.isEmpty
                          ? const _SinComentarios()
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                              itemCount: lista.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 4),
                              itemBuilder: (context, i) => Aparicion(
                                indice: i.clamp(0, 8),
                                child: _FilaComentario(
                                  comentario: lista[i],
                                  esAutor: lista[i].idUsuario == widget.idAutor,
                                  puedeEliminar: widget.esAdmin || lista[i].idUsuario == uid,
                                  eliminar: () => widget.eliminar(lista[i]),
                                ),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + (medidas.viewInsets.bottom > 0 ? 0 : medidas.padding.bottom)),
            decoration: BoxDecoration(
              color: c.fondo,
              border: Border(top: BorderSide(color: c.divisor)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: AvatarUsuario(
                    uid: uid,
                    fotoUrl: FirebaseAuth.instance.currentUser?.photoURL,
                    nombre: FirebaseAuth.instance.currentUser?.displayName,
                    radio: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _texto,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                    decoration: decoracionCampo(
                      context,
                      pista: 'Escribe un comentario',
                      radio: 22,
                      borde: true,
                      relleno: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ).copyWith(counterText: ''),
                  ),
                ),
                const SizedBox(width: 8),
                Presionable(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 46,
                    height: 46,
                    decoration: ShapeDecoration(color: _texto.text.trim().isEmpty ? c.contenedor : c.acento, shape: const CircleBorder()),
                    child: IconButton(
                      onPressed: _texto.text.trim().isEmpty || _enviando ? null : _enviar,
                      icon: _enviando
                          ? SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2.2, color: c.sobreAcento))
                          : Icono(Iconos.send, size: 20, color: _texto.text.trim().isEmpty ? c.textoTenue : c.sobreAcento),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilaComentario extends StatelessWidget {
  const _FilaComentario({required this.comentario, required this.esAutor, required this.puedeEliminar, required this.eliminar});

  final Comentario comentario;
  final bool esAutor;
  final bool puedeEliminar;
  final VoidCallback eliminar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AvatarUsuario(uid: comentario.idUsuario, fotoUrl: comentario.fotoUsuario, nombre: comentario.nombreUsuario, radio: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comentario.nombreUsuario,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (esAutor) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                        decoration: Formas.fondo(c.contenedor, 7),
                        child: Text(
                          'Autor',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: c.textoSecundario),
                        ),
                      ),
                    ],
                    const SizedBox(width: 6),
                    Text(haceCuanto(comentario.creadoEn), style: TextStyle(fontSize: 12.5, color: c.textoTenue)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(comentario.texto, style: const TextStyle(fontSize: 15, height: 1.4)),
              ],
            ),
          ),
          if (puedeEliminar)
            SizedBox.square(
              dimension: 36,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: eliminar,
                icon: Icono(Iconos.ellipsis, size: 18, color: c.textoTenue),
              ),
            )
          else
            const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _SinComentarios extends StatelessWidget {
  const _SinComentarios({this.fallo = false});

  final bool fallo;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: ShapeDecoration(color: c.contenedor, shape: Formas.squircle(20)),
              child: Center(child: Icono(fallo ? Iconos.wifiOff : Iconos.messageCircle, size: 30, color: c.textoSecundario)),
            ),
            const SizedBox(height: 14),
            Text(fallo ? 'No se pudieron cargar' : 'Aún no hay comentarios', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700).display),
            const SizedBox(height: 4),
            Text(
              fallo ? 'Revisa tu conexión e inténtalo de nuevo.' : 'Sé el primero en comentar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: c.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }
}
