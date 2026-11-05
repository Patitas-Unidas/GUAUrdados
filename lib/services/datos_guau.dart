class DatosGuau {
  DatosGuau._();

  static const whatsapp = '';

  static const cuenta = <(String, String)>[
    ('Titular', ''),
    ('RUT', ''),
    ('Banco', ''),
    ('Tipo de cuenta', ''),
    ('Número de cuenta', ''),
    ('Correo', ''),
  ];

  static bool get hayCuenta => cuenta.every((dato) => dato.$2.isNotEmpty);

  static String get cuentaParaCopiar => [for (final (campo, valor) in cuenta) '$campo: $valor'].join('\n');

  static String mensajeAdopcion(String? nombrePerro) => nombrePerro == null
      ? 'Hola GUAU, me interesa adoptar a uno de los perritos de la sede. Los vi en la app GUAUrdados. ¿Cómo puedo hacerlo?'
      : 'Hola GUAU, me interesa adoptar a $nombrePerro. Lo vi en la app GUAUrdados. ¿Cómo puedo hacerlo?';

  static Uri enlaceWhatsapp(String mensaje) => Uri.https('wa.me', '/$whatsapp', {'text': mensaje});
}
