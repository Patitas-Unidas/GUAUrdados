import 'dart:math' as math;

import 'package:guaurdados_oficial/models/perro.dart';

class ReglasCuidado {
  static const intervaloComida = Duration(hours: 12);
  static const comidaReciente = Duration(hours: 4);
  static const intervaloDesparasitacion = Duration(days: 91);
  static const intervaloVacunas = Duration(days: 365);
  static const anticipacionAviso = Duration(days: 14);
}

enum TipoAlimento { seca, humeda, agua }

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

enum Gravedad { atencion, urgente }

class Aviso {
  const Aviso(this.texto, this.gravedad);
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
  Cuidados(this.perro, {DateTime? ahora}) : ahora = ahora ?? DateTime.now();
  final Perro perro;
  final DateTime ahora;

  Duration? get desdeUltimaComida => perro.ultimaComidaEn == null ? null : ahora.difference(perro.ultimaComidaEn!);

  DateTime? get proximaComida => perro.ultimaComidaEn?.add(ReglasCuidado.intervaloComida);

  String get textoProximaComida {
    final proxima = proximaComida;
    if (proxima == null) return 'sin comidas registradas';
    if (!proxima.isAfter(ahora)) return 'ahora';
    final manana = proxima.day != ahora.day;
    return '${manana ? 'mañana, ' : ''}${hora(proxima)}';
  }

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

  List<Aviso> get avisos {
    final lista = <Aviso>[];
    final desde = desdeUltimaComida;
    if (desde != null && desde < ReglasCuidado.comidaReciente) {
      lista.add(Aviso('Comió hace ${duracion(desde)} · evita darle más', Gravedad.atencion));
    } else if (desde != null && desde >= ReglasCuidado.intervaloComida) {
      lista.add(Aviso('Sin comer hace ${duracion(desde)}', Gravedad.atencion));
    }
    void plazo(String nombre, Plazo p) {
      if (p is PorVencer) lista.add(Aviso('$nombre vence ${p.dias == 0 ? 'hoy' : 'en ${p.dias} ${p.dias == 1 ? 'día' : 'días'}'}', Gravedad.atencion));
      if (p is Vencido) lista.add(Aviso('$nombre vencida', Gravedad.urgente));
    }
    plazo('Vacuna', vacunas);
    plazo('Desparasitación', desparasitacion);
    return lista;
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
