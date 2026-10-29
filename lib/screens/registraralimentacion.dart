import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/services/cuidados.dart';
import 'package:guaurdados_oficial/services/foro_repository.dart';
import 'package:guaurdados_oficial/theme/app_colors.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';

class _Tipo {
  const _Tipo(this.tipo, this.emoji, this.nombre, this.color, {this.enMl = false});
  final TipoAlimento? tipo;
  final String emoji;
  final String nombre;
  final Color color;
  final bool enMl;
}

const _tipos = [
  _Tipo(TipoAlimento.seca, '🥣', 'Comida seca', AppColors.naranjaComida),
  _Tipo(TipoAlimento.humeda, '🍖', 'Comida húmeda', AppColors.rojoMarca),
  _Tipo(TipoAlimento.agua, '💧', 'Agua', AppColors.azulAgua, enMl: true),
  _Tipo(null, '🍽️', 'Otro', AppColors.cafe),
];

enum _Unidad {
  punados('puñados', 1, 1, 10),
  gramos('g', 25, 150, 1000),
  ml('ml', 50, 250, 2000);

  const _Unidad(this.texto, this.paso, this.inicial, this.maximo);
  final String texto;
  final int paso;
  final int inicial;
  final int maximo;
}

class RegistrarAlimentacion extends StatefulWidget {
  const RegistrarAlimentacion({super.key, required this.perro});
  final Perro perro;

  @override
  State<RegistrarAlimentacion> createState() => _RegistrarAlimentacionState();
}

class _RegistrarAlimentacionState extends State<RegistrarAlimentacion> {
  int _elegido = 0;
  _Unidad _unidadComida = _Unidad.punados;
  final _cantidades = {for (final u in _Unidad.values) u: u.inicial};
  final _otro = TextEditingController();
  bool _guardando = false;

  _Tipo get _tipo => _tipos[_elegido];
  _Unidad get _unidad => _tipo.enMl ? _Unidad.ml : _unidadComida;

  @override
  void dispose() {
    _otro.dispose();
    super.dispose();
  }

  void _cambiarCantidad(int pasos) {
    final nueva = _cantidades[_unidad]! + pasos * _unidad.paso;
    if (nueva < _unidad.paso || nueva > _unidad.maximo) return;
    setState(() => _cantidades[_unidad] = nueva);
  }

  Future<void> _guardar() async {
    if (_guardando) return;
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) {
      _avisar('Inicia sesión para guardar el registro.');
      return;
    }
    final tipoComida = _tipo.tipo == null ? _otro.text.trim() : _tipo.nombre.toLowerCase();
    if (tipoComida.isEmpty) {
      _avisar('Escribe qué alimento recibió.');
      return;
    }

    final cantidadNumero = _cantidades[_unidad]!;
    final unidad = _unidad == _Unidad.punados && cantidadNumero == 1 ? 'puñado' : _unidad.texto;
    final cantidad = '$cantidadNumero $unidad';
    setState(() => _guardando = true);
    try {
      await ForoRepository().registrarAlimentacion(
        idPerro: widget.perro.id,
        nombrePerro: widget.perro.nombre,
        usuario: usuario,
        tipoComida: tipoComida,
        cantidadComida: cantidad,
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(content: Text('Alimentación guardada y agregada al foro.')));
    } catch (error) {
      if (!mounted) return;
      final mensaje = error is FirebaseException && error.code == 'permission-denied'
          ? 'Firestore rechazó el registro. Revisa las reglas de alimentación.'
          : 'No se pudo guardar la alimentación. Inténtalo de nuevo.';
      _avisar(mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _avisar(String texto) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final racion = _tipo.tipo == null ? null : racionDiaria(pesoEnKg(widget.perro.peso), _tipo.tipo!);
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .85),
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.paddingOf(context).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(
            child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 14), decoration: Formas.fondo(c.divisor, 2)),
          ),

          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: Formas.fondo(c.acento, 12),
              child: Icono(Iconos.utensils, color: c.sobreAcento),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Registrar alimentación', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800).display),
                Text('${widget.perro.nombre} · ${fechaLarga(DateTime.now())}', style: TextStyle(fontSize: 13, color: c.textoSecundario)),
              ]),
            ),
            Presionable(
              child: Material(
                color: c.acento.withValues(alpha: .12),
                shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.pop(context),
                  icon: Icono(Iconos.x, color: c.acento),
                ),
              ),
            ),
          ]),
          Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Divider(height: 1, color: c.divisor)),

          if (widget.perro.restricciones.isNotEmpty) ...[
            _Restricciones(restricciones: widget.perro.restricciones),
            const SizedBox(height: 16),
          ],

          const _Titulo('Tipo de alimento'),
          AbsorbPointer(
            absorbing: _guardando,
            child: _SelectorTipo(elegido: _elegido, alElegir: (i) => setState(() => _elegido = i)),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: _tipo.tipo != null
                ? const SizedBox(width: double.infinity)
                : Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: Formas.fondo(c.superficie, 16),
                    child: TextField(
                      controller: _otro,
                      enabled: !_guardando,
                      maxLength: 60,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: '¿Qué le diste? (ej.: arroz con pollo)',
                        hintStyle: TextStyle(color: c.textoTenue),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          Row(children: [
            const Expanded(child: _Titulo('Cantidad')),
            if (!_tipo.enMl)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SelectorUnidad(
                  unidad: _unidadComida,
                  color: _tipo.color,
                  alCambiar: (u) => setState(() => _unidadComida = u),
                ),
              ),
          ]),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            height: 140,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: ShapeDecoration(
              color: _tipo.color.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .18 : .12),
              shape: Formas.squircle(22, lado: BorderSide(color: _tipo.color.withValues(alpha: .25))),
            ),
            child: Row(children: [
              _BotonCantidad(icono: Iconos.minus, color: _tipo.color, alTocar: () => _cambiarCantidad(-1)),
              Expanded(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  _NumeroAnimado(valor: _cantidades[_unidad]!, color: _tipo.color),
                  Text(
                    _unidad == _Unidad.punados && _cantidades[_unidad] == 1 ? 'puñado' : _unidad.texto,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: c.textoSecundario),
                  ),
                ]),
              ),
              _BotonCantidad(icono: Iconos.plus, color: _tipo.color, alTocar: () => _cambiarCantidad(1)),
            ]),
          ),
          if (_tipo.tipo != null) ...[
            const SizedBox(height: 10),
            Text(
              racion == null
                  ? 'Registra su peso para ver la ración recomendada'
                  : '${_tipo.enMl ? 'Agua diaria recomendada' : 'Ración diaria recomendada'} para su peso: '
                      '${racion.$1} – ${racion.$2} ${_tipo.enMl ? 'ml' : 'g'}',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: c.textoTenue),
            ),
          ],
          const SizedBox(height: 20),

          _BotonGuardar(guardando: _guardando, alTocar: _guardar),
        ]),
      ),
    );
  }
}

class _Restricciones extends StatelessWidget {
  const _Restricciones({required this.restricciones});
  final List<String> restricciones;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final tinte = c.advertencia.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? .2 : .12);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: Formas.fondo(tinte, 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icono(Iconos.triangleAlert, color: c.advertenciaTexto),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Restricciones de alimentación', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.advertenciaTexto)),
            const SizedBox(height: 6),
            Wrap(spacing: 6, runSpacing: 6, children: [
              for (final r in restricciones)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: Formas.fondo(tinte, 9),
                  child: Text(r, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.advertenciaTexto)),
                ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 2, bottom: 8),
    child: Text(
      texto.toUpperCase(),
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: .4, color: context.colores.textoTenue),
    ),
  );
}

class _SelectorTipo extends StatelessWidget {
  const _SelectorTipo({required this.elegido, required this.alElegir});
  final int elegido;
  final ValueChanged<int> alElegir;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 64,
      padding: const EdgeInsets.all(4),
      decoration: Formas.fondo(oscuro ? c.superficie : c.contenedor, 16),
      child: Stack(children: [
        AnimatedAlign(
          alignment: Alignment(-1 + 2 * elegido / (_tipos.length - 1), 0),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutBack,
          child: FractionallySizedBox(
            widthFactor: 1 / _tipos.length,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: Formas.fondo(
                oscuro ? AppColors.oscuroBorde : AppColors.blanco,
                12,
                sombras: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
            ),
          ),
        ),
        Row(children: [
          for (var i = 0; i < _tipos.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == elegido,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => alElegir(i),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    AnimatedScale(
                      scale: i == elegido ? 1.15 : 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      child: Text(_tipos[i].emoji, style: const TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: i == elegido ? FontWeight.w700 : FontWeight.w500,
                            color: i == elegido ? _tipos[i].color : c.textoSecundario,
                          ),
                          child: Text(_tipos[i].nombre, maxLines: 1),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
        ]),
      ]),
    );
  }
}

class _SelectorUnidad extends StatelessWidget {
  const _SelectorUnidad({required this.unidad, required this.color, required this.alCambiar});
  final _Unidad unidad;
  final Color color;
  final ValueChanged<_Unidad> alCambiar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: Formas.fondo(oscuro ? c.superficie : c.contenedor, 12),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final (u, texto) in const [(_Unidad.punados, 'Puñados'), (_Unidad.gramos, 'Gramos')])
          GestureDetector(
            onTap: () => alCambiar(u),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: Formas.fondo(
                u == unidad ? (oscuro ? AppColors.oscuroBorde : AppColors.blanco) : AppColors.blanco.withValues(alpha: 0),
                9,
              ),
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: u == unidad ? FontWeight.w700 : FontWeight.w500,
                  color: u == unidad ? color : c.textoSecundario,
                ),
              ),
            ),
          ),
      ]),
    );
  }
}

class _BotonCantidad extends StatelessWidget {
  const _BotonCantidad({required this.icono, required this.color, required this.alTocar});
  final IconData icono;
  final Color color;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Presionable(
      escala: .9,
      child: Material(
        color: oscuro ? AppColors.oscuroBorde : AppColors.blanco,
        elevation: 2,
        shadowColor: const Color(0x33000000),
        shape: Formas.squircle(14),
        child: InkWell(
          customBorder: Formas.squircle(14),
          onTap: alTocar,
          child: SizedBox(width: 52, height: 52, child: Icono(icono, color: color, size: 26)),
        ),
      ),
    );
  }
}

class _NumeroAnimado extends StatelessWidget {
  const _NumeroAnimado({required this.valor, required this.color});
  final int valor;
  final Color color;

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 280),
    switchInCurve: Curves.easeOutBack,
    switchOutCurve: Curves.easeIn,
    transitionBuilder: (child, animacion) => FadeTransition(
      opacity: animacion,
      child: ScaleTransition(scale: animacion, child: child),
    ),
    child: Text(
      '$valor',
      key: ValueKey(valor),
      style: TextStyle(fontSize: 54, fontWeight: FontWeight.w800, height: 1.1, color: color).display,
    ),
  );
}

class _BotonGuardar extends StatelessWidget {
  const _BotonGuardar({required this.guardando, required this.alTocar});
  final bool guardando;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Presionable(
      child: Container(
        height: 56,
        decoration: ShapeDecoration(
          shape: Formas.squircle(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(c.acento, AppColors.blanco, .2)!, c.acento],
          ),
          shadows: [BoxShadow(color: c.acento.withValues(alpha: .3), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: Formas.squircle(18),
            onTap: alTocar,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Row(
                key: ValueKey(guardando),
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (guardando)
                    SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: c.sobreAcento))
                  else
                    Icono(Iconos.utensils, color: c.sobreAcento, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    guardando ? 'Guardando...' : 'Guardar registro',
                    style: TextStyle(color: c.sobreAcento, fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
