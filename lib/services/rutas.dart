import 'package:flutter/material.dart';

class RegistroRutas extends NavigatorObserver {
  RegistroRutas._();

  static final instancia = RegistroRutas._();
  final _abiertas = <Route<dynamic>>[];

  void limpiar() => _abiertas.clear();

  bool estaAbierta(String nombre) => _abiertas.any((ruta) => ruta.settings.name == nombre);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _abiertas.add(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _abiertas.remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _abiertas.remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final i = oldRoute == null ? -1 : _abiertas.indexOf(oldRoute);
    if (i >= 0 && newRoute != null) {
      _abiertas[i] = newRoute;
    } else if (newRoute != null) {
      _abiertas.add(newRoute);
    }
  }
}

void abrir(BuildContext context, Route<void> ruta) {
  final nombre = ruta.settings.name;
  final navegador = Navigator.of(context);
  if (nombre != null && RegistroRutas.instancia.estaAbierta(nombre)) {
    navegador.popUntil((r) => r.settings.name == nombre);
  } else {
    navegador.push(ruta);
  }
}

void abrirDesdeInicio(BuildContext context, Route<void> ruta) =>
    Navigator.of(context).pushAndRemoveUntil(ruta, (r) => r.isFirst);
