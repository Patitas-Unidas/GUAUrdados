import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guaurdados_oficial/screens/registro_usuario.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: RegistroUsuario()));
  }

  testWidgets('rechaza campos vacíos antes de acceder a Firebase', (tester) async {
    await abrir(tester);
    await tester.tap(find.text('Crear cuenta'));
    await tester.pump();
    expect(find.text('Ingresa tu nombre.'), findsOneWidget);
    expect(find.text('Ingresa un correo válido.'), findsOneWidget);
    expect(find.text('Usa al menos 6 caracteres.'), findsOneWidget);
  });

  testWidgets('valida confirmación y exige aceptar los términos', (tester) async {
    await abrir(tester);
    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Ana Pérez');
    await tester.enterText(campos.at(1), 'ana@example.com');
    await tester.enterText(campos.at(2), 'clave123');
    await tester.enterText(campos.at(3), 'otra123');
    await tester.tap(find.text('Crear cuenta'));
    await tester.pump();
    expect(find.text('Las contraseñas deben coincidir.'), findsOneWidget);
    await tester.enterText(campos.at(3), 'clave123');
    await tester.tap(find.text('Crear cuenta'));
    await tester.pump();
    expect(find.text('Debes aceptar los términos y la política de privacidad.'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });
}
