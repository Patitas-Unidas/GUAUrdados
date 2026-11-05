import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guaurdados_oficial/services/datos_guau.dart';
import 'package:guaurdados_oficial/theme/colores_app.dart';
import 'package:guaurdados_oficial/theme/formas.dart';
import 'package:guaurdados_oficial/theme/tipografia.dart';
import 'package:guaurdados_oficial/widgets/aviso.dart';
import 'package:guaurdados_oficial/widgets/hoja.dart';
import 'package:guaurdados_oficial/widgets/iconos.dart';
import 'package:guaurdados_oficial/widgets/presionable.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> mostrarDonaciones(BuildContext context) => mostrarHoja<void>(context, builder: (_) => const _HojaDonaciones());

Future<void> mostrarAdopcion(BuildContext context, {String? nombrePerro}) =>
    mostrarHoja<void>(context, builder: (_) => _HojaAdopcion(nombrePerro: nombrePerro));

class _Hoja extends StatelessWidget {
  const _Hoja({required this.icono, required this.color, required this.titulo, required this.texto, required this.children});
  final IconData icono;
  final Color color;
  final String titulo;
  final String texto;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .88),
      decoration: ShapeDecoration(color: c.fondo, shape: Formas.squircleArriba(28)),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 16 + MediaQuery.paddingOf(context).bottom),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 18), decoration: Formas.fondo(c.divisor, 2))),
          Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: ShapeDecoration(color: color.withValues(alpha: .14), shape: Formas.squircle(15)),
              child: Center(child: Icono(icono, color: color, size: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(titulo, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800).display)),
          ]),
          const SizedBox(height: 14),
          Text(texto, style: TextStyle(fontSize: 14.5, height: 1.45, color: c.textoSecundario)),
          const SizedBox(height: 18),
          ...children,
        ]),
      ),
    );
  }
}

class _HojaDonaciones extends StatelessWidget {
  const _HojaDonaciones();

  void _copiar(BuildContext context, String texto, String aviso) {
    Clipboard.setData(ClipboardData(text: texto));
    HapticFeedback.selectionClick();
    avisar(context, aviso, tipo: TipoAviso.exito, icono: Iconos.copy);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return _Hoja(
      icono: Iconos.handHeart,
      color: c.acento,
      titulo: 'Dona a GUAU',
      texto: 'GUAU es el grupo de voluntarios de la USM que cuida a los perritos de la sede: los alimenta, los lleva al veterinario y '
          'les busca un hogar. Con tu aporte compran comida, vacunas y remedios. Cualquier monto ayuda.',
      children: [
        Container(
          decoration: ShapeDecoration(color: c.superficie, shape: Formas.squircle(18)),
          child: Column(children: [
            for (final (i, (campo, valor)) in DatosGuau.cuenta.indexed) ...[
              if (i > 0) Divider(height: 1, indent: 16, endIndent: 16, color: c.divisor),
              InkWell(
                onTap: valor.isEmpty ? null : () => _copiar(context, valor, '$campo copiado.'),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(campo, style: TextStyle(fontSize: 12.5, color: c.textoTenue)),
                        const SizedBox(height: 2),
                        Text(
                          valor.isEmpty ? 'Por confirmar' : valor,
                          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: valor.isEmpty ? c.textoTenue : c.texto),
                        ),
                      ]),
                    ),
                    if (valor.isNotEmpty) Icono(Iconos.copy, size: 18, color: c.textoSecundario),
                  ]),
                ),
              ),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        Presionable(
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: DatosGuau.hayCuenta
                  ? () => _copiar(context, DatosGuau.cuentaParaCopiar, 'Datos copiados. Pégalos en la app de tu banco para transferir.')
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: c.acento,
                foregroundColor: c.sobreAcento,
                disabledBackgroundColor: c.acento.withValues(alpha: .4),
                disabledForegroundColor: c.sobreAcento,
                shape: Formas.squircle(16),
              ),
              icon: Icono(Iconos.copy, color: c.sobreAcento, size: 20),
              label: const Text('Copiar todos los datos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Toca un dato para copiar solo ese. GUAUrdados no recibe ni administra dinero: la transferencia va directo a GUAU.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, height: 1.4, color: c.textoTenue),
        ),
      ],
    );
  }
}

class _HojaAdopcion extends StatelessWidget {
  const _HojaAdopcion({this.nombrePerro});
  final String? nombrePerro;

  Future<void> _escribir(BuildContext context) async {
    final mensaje = DatosGuau.mensajeAdopcion(nombrePerro);
    final abierto = await launchUrl(DatosGuau.enlaceWhatsapp(mensaje), mode: LaunchMode.externalApplication).catchError((_) => false);
    if (abierto || !context.mounted) return;
    Clipboard.setData(ClipboardData(text: mensaje));
    avisar(context, 'No pudimos abrir WhatsApp. Copiamos el mensaje para que se lo envíes a GUAU.', icono: Iconos.copy);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final hayContacto = DatosGuau.whatsapp.isNotEmpty;
    final mensaje = DatosGuau.mensajeAdopcion(nombrePerro);
    return _Hoja(
      icono: Iconos.heart,
      color: c.adoptadoTexto,
      titulo: nombrePerro == null ? 'Adopta un perrito' : '¿Quieres adoptar a $nombrePerro?',
      texto: 'Las adopciones las coordina GUAU, el grupo de voluntarios de la USM. Ellos te van a contar cómo es el proceso, '
          'resolver tus dudas y acompañarte para que el perrito llegue a un buen hogar.',
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: ShapeDecoration(color: c.superficie, shape: Formas.squircle(18)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tu mensaje para GUAU', style: TextStyle(fontSize: 12.5, color: c.textoTenue)),
            const SizedBox(height: 6),
            Text(mensaje, style: const TextStyle(fontSize: 14.5, height: 1.4)),
          ]),
        ),
        const SizedBox(height: 16),
        Presionable(
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: hayContacto ? () => _escribir(context) : null,
              style: FilledButton.styleFrom(
                backgroundColor: c.acento,
                foregroundColor: c.sobreAcento,
                disabledBackgroundColor: c.acento.withValues(alpha: .4),
                disabledForegroundColor: c.sobreAcento,
                shape: Formas.squircle(16),
              ),
              icon: Icono(Iconos.messageCircle, color: c.sobreAcento, size: 20),
              label: const Text('Escribir a GUAU por WhatsApp', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: hayContacto ? '+${DatosGuau.whatsapp}\n\n$mensaje' : mensaje));
            avisar(context, hayContacto ? 'Copiamos el número de GUAU y tu mensaje.' : 'Copiamos tu mensaje.', tipo: TipoAviso.exito, icono: Iconos.copy);
          },
          icon: Icono(Iconos.copy, size: 18, color: c.textoSecundario),
          label: Text(hayContacto ? 'Copiar número y mensaje' : 'Copiar mensaje', style: TextStyle(color: c.textoSecundario, fontWeight: FontWeight.w600)),
        ),
        if (!hayContacto)
          Text(
            'El contacto de GUAU estará disponible pronto.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: c.textoTenue),
          ),
      ],
    );
  }
}
