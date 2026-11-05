import 'dart:math' as math;

import 'package:guaurdados_oficial/models/perro.dart';
import 'package:guaurdados_oficial/models/publicacion_foro.dart';

class ReglasCuidado {
  static const ventana = Duration(hours: 24);
  static const sinAgua = Duration(hours: 24);
  static const urgente = Duration(hours: 48);
  static const historial = Duration(hours: 48);
  static const pesoSupuestoKg = 15.0;
  static const gramosPorPunado = {TipoAlimento.seca: 40, TipoAlimento.humeda: 60};
  static const excesoDiario = 1.25;
  static const intervaloDesparasitacion = Duration(days: 91);
  static const intervaloVacunas = Duration(days: 365);
  static const anticipacionAviso = Duration(days: 14);
}

enum TipoAlimento { seca, humeda, agua }

TipoAlimento? tipoAlimento(String? texto) {
  final t = (texto ?? '').trim().toLowerCase();
  if (t.contains('seca')) return TipoAlimento.seca;
  if (t.contains('húmeda') || t.contains('humeda')) return TipoAlimento.humeda;
  if (t == 'agua') return TipoAlimento.agua;
  return null;
}

double? pesoEnKg(String peso) {
  final numero = RegExp(r'\d+([.,]\d+)?').firstMatch(peso)?.group(0);
  return numero == null ? null : double.tryParse(numero.replaceAll(',', '.'));
}

(int, int)? racionDiaria(double? pesoKg, TipoAlimento tipo) {
  if (pesoKg == null || pesoKg <= 0) return null;
  int redondear(double x) => (x / 10).round() * 10;
  if (tipo == TipoAlimento.agua) return (redondear(pesoKg * 50), redondear(pesoKg * 60));
  final reposo = 70 * math.pow(pesoKg, .75);
  final kcalPorGramo = tipo == TipoAlimento.seca ? 3.5 : 1.0;
  return (redondear(reposo * 1.4 / kcalPorGramo), redondear(reposo * 1.8 / kcalPorGramo));
}

enum Unidad { punados, gramos, ml }

class Alimentacion {
  const Alimentacion({required this.fecha, required this.tipo, required this.cantidad, required this.unidad});
  final DateTime fecha;
  final TipoAlimento? tipo;
  final double cantidad;
  final Unidad unidad;

  bool get esAgua => tipo == TipoAlimento.agua;

  static Alimentacion? desde(PublicacionForo publicacion) {
    final fecha = publicacion.creadoEn;
    if (publicacion.tipoPublicacion != 'alimentacion' || fecha == null) return null;
    final partes = RegExp(r'(\d+(?:[.,]\d+)?)\s*(\S*)').firstMatch(publicacion.cantidadComida ?? '');
    final cantidad = double.tryParse(partes?.group(1)?.replaceAll(',', '.') ?? '');
    if (cantidad == null || cantidad <= 0) return null;
    final unidad = partes!.group(2)!.toLowerCase();
    return Alimentacion(
      fecha: fecha,
      tipo: tipoAlimento(publicacion.tipoComida),
      cantidad: cantidad,
      unidad: unidad.startsWith('pu') ? Unidad.punados : unidad.startsWith('ml') ? Unidad.ml : Unidad.gramos,
    );
  }
}

enum Gravedad { bien, neutro, revisar, urgente, adoptado }

class Aviso {
  const Aviso(this.texto, this.gravedad);
  final String texto;
  final Gravedad gravedad;
}

enum EstadoPerro {
  saludable('Saludable', Gravedad.bien),
  revisar('Revisar', Gravedad.revisar),
  urgente('Urgente', Gravedad.urgente),
  adoptado('Adoptado', Gravedad.adoptado),
  sinEstado('Sin estado', Gravedad.neutro);

  const EstadoPerro(this.texto, this.gravedad);
  final String texto;
  final Gravedad gravedad;
}

sealed class Plazo {
  const Plazo();
}

class SinDato extends Plazo {
  const SinDato();
}

class AlDia extends Plazo {
  const AlDia(this.vence);
  final DateTime vence;
}

class PorVencer extends Plazo {
  const PorVencer(this.vence, this.dias);
  final DateTime vence;
  final int dias;
}

class Vencido extends Plazo {
  const Vencido(this.vencio, this.dias);
  final DateTime vencio;
  final int dias;
}

class Cuidados {
  Cuidados(this.perro, {List<Alimentacion> alimentaciones = const [], DateTime? ahora}) : ahora = ahora ?? DateTime.now() {
    for (final a in alimentaciones) {
      if (this.ahora.difference(a.fecha) > ReglasCuidado.historial) continue;
      (a.esAgua ? _agua : _comidas).add(a);
    }
    _comidas.sort((a, b) => a.fecha.compareTo(b.fecha));
    _agua.sort((a, b) => a.fecha.compareTo(b.fecha));
  }

  final Perro perro;
  final DateTime ahora;
  final _comidas = <Alimentacion>[];
  final _agua = <Alimentacion>[];

  bool get pesoSupuesto => pesoEnKg(perro.peso) == null;
  double get pesoKg => pesoEnKg(perro.peso) ?? ReglasCuidado.pesoSupuestoKg;

  double _fraccion(Alimentacion a) {
    final tipo = a.tipo ?? TipoAlimento.humeda;
    final gramos = a.unidad == Unidad.punados ? a.cantidad * ReglasCuidado.gramosPorPunado[tipo]! : a.cantidad;
    final (minimo, maximo) = racionDiaria(pesoKg, tipo)!;
    return gramos / ((minimo + maximo) / 2);
  }

  bool _hoy(Alimentacion a) => ahora.difference(a.fecha) <= ReglasCuidado.ventana;

  DateTime? get ultimaComidaEn => _comidas.isNotEmpty ? _comidas.last.fecha : perro.ultimaComidaEn;

  Duration? get desdeUltimaComida => ultimaComidaEn == null ? null : ahora.difference(ultimaComidaEn!);

  DateTime? get ultimaAguaEn => _agua.isNotEmpty ? _agua.last.fecha : perro.ultimaAguaEn;

  Duration? get desdeUltimaAgua => ultimaAguaEn == null ? null : ahora.difference(ultimaAguaEn!);

  bool get sinComerHaceMucho => !perro.adoptado && (desdeUltimaComida ?? Duration.zero) > ReglasCuidado.ventana;

  bool get sinAguaHaceMucho => !perro.adoptado && (desdeUltimaAgua ?? Duration.zero) > ReglasCuidado.sinAgua;

  bool get sinComerUrgente => (desdeUltimaComida ?? Duration.zero) > ReglasCuidado.urgente;

  bool get sinAguaUrgente => (desdeUltimaAgua ?? Duration.zero) > ReglasCuidado.urgente;

  double get racionHoy => _comidas.where(_hoy).fold(0.0, (suma, a) => suma + _fraccion(a));

  int get aguaHoyMl => _agua.where(_hoy).fold(0, (suma, a) => suma + a.cantidad.round());

  int get aguaDiariaMl {
    final (minimo, maximo) = racionDiaria(pesoKg, TipoAlimento.agua)!;
    return (minimo + maximo) ~/ 2;
  }

  DateTime? get alimentadoHasta {
    DateTime? hasta;
    for (final a in _comidas) {
      final desde = hasta != null && hasta.isAfter(a.fecha) ? hasta : a.fecha;
      hasta = desde.add(ReglasCuidado.ventana * _fraccion(a));
    }
    return hasta;
  }

  String get textoProximaComida {
    final hasta = alimentadoHasta;
    if (hasta == null) return ultimaComidaEn == null ? 'sin comidas registradas' : 'ahora';
    if (!hasta.isAfter(ahora)) return 'ahora';
    return _cuando(hasta);
  }

  String _cuando(DateTime f) => '${f.day != ahora.day ? 'mañana, ' : ''}${hora(f)}';

  Plazo get vacunas => _plazo(perro.ultimaVacunaEn, ReglasCuidado.intervaloVacunas);
  Plazo get desparasitacion => _plazo(perro.ultimaDesparasitacionEn, ReglasCuidado.intervaloDesparasitacion);

  Plazo _plazo(DateTime? ultima, Duration intervalo) {
    if (ultima == null) return const SinDato();
    final vence = ultima.add(intervalo);
    final restante = vence.difference(ahora);
    if (restante.isNegative) return Vencido(vence, -restante.inDays);
    if (restante <= ReglasCuidado.anticipacionAviso) return PorVencer(vence, restante.inDays);
    return AlDia(vence);
  }

  bool get evaluado => !const {'sin estado', 'sin información', ''}.contains(perro.estado.trim().toLowerCase());

  List<Aviso> get avisos {
    if (perro.adoptado) return const [];
    final lista = <Aviso>[];
    final desde = desdeUltimaComida;
    final hasta = alimentadoHasta;
    if (desde == null) {
      final fichaNueva = perro.actualizadoEn != null && ahora.difference(perro.actualizadoEn!.toDate()) <= ReglasCuidado.urgente;
      lista.add(Aviso('Sin comidas registradas', fichaNueva ? Gravedad.revisar : Gravedad.urgente));
    } else if (sinComerHaceMucho) {
      lista.add(Aviso('Sin comer hace ${duracion(desde)}', sinComerUrgente ? Gravedad.urgente : Gravedad.revisar));
    } else if (racionHoy > ReglasCuidado.excesoDiario) {
      lista.add(const Aviso('Comió más de su ración diaria', Gravedad.revisar));
    } else if (hasta != null && hasta.isAfter(ahora)) {
      lista.add(Aviso('Alimentado hasta ${_cuando(hasta)} · evita darle más', Gravedad.bien));
    } else {
      lista.add(const Aviso('Le toca comer', Gravedad.neutro));
    }
    if (sinAguaHaceMucho) {
      lista.add(Aviso('Sin agua hace ${duracion(desdeUltimaAgua!)}', sinAguaUrgente ? Gravedad.urgente : Gravedad.revisar));
    }

    if (evaluado && perro.estado.trim().toLowerCase() != 'saludable') {
      lista.add(Aviso(perro.estado.trim(), Gravedad.revisar));
    }
    if (perro.vacunacion.trim().toLowerCase().startsWith('no')) {
      lista.add(const Aviso('Vacunas pendientes', Gravedad.revisar));
    }
    void plazo(String nombre, Plazo p) {
      if (p is PorVencer) lista.add(Aviso('$nombre vence ${p.dias == 0 ? 'hoy' : 'en ${p.dias} ${p.dias == 1 ? 'día' : 'días'}'}', Gravedad.revisar));
      if (p is Vencido) lista.add(Aviso('$nombre vencida', Gravedad.revisar));
    }
    plazo('Vacuna', vacunas);
    plazo('Desparasitación', desparasitacion);
    return evaluado ? lista : [for (final a in lista) a.gravedad == Gravedad.revisar ? Aviso(a.texto, Gravedad.neutro) : a];
  }

  Aviso? get principal {
    final lista = avisos;
    for (final gravedad in const [Gravedad.urgente, Gravedad.revisar]) {
      for (final aviso in lista) {
        if (aviso.gravedad == gravedad) return aviso;
      }
    }
    return null;
  }

  EstadoPerro get estado {
    if (perro.adoptado) return EstadoPerro.adoptado;
    final lista = avisos;
    if (lista.any((a) => a.gravedad == Gravedad.urgente)) return EstadoPerro.urgente;
    if (!evaluado) return EstadoPerro.sinEstado;
    return lista.any((a) => a.gravedad == Gravedad.revisar) ? EstadoPerro.revisar : EstadoPerro.saludable;
  }
}

const _meses = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

const _dias = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

String fechaLarga(DateTime f) => '${_dias[f.weekday - 1]}, ${f.day} ${_meses[f.month - 1]}';

String fecha(DateTime f) => '${f.day} ${_meses[f.month - 1]} ${f.year}';

String hora(DateTime f) => '${f.hour.toString().padLeft(2, '0')}:${f.minute.toString().padLeft(2, '0')}';

String duracion(Duration d) {
  if (d.inMinutes < 60) return '${d.inMinutes} min';
  if (d.inHours < 24) return '${d.inHours} h';
  return '${d.inDays} ${d.inDays == 1 ? 'día' : 'días'}';
}
