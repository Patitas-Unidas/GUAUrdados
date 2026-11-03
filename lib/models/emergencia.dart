import 'package:cloud_firestore/cloud_firestore.dart';

enum EstadoEmergencia {
  enCurso('en_curso', 'En curso'),
  resuelta('resuelta', 'Resuelta'),
  veterinario('veterinario', 'Atención veterinaria'),
  falsaAlarma('falsa_alarma', 'Falsa alarma');

  const EstadoEmergencia(this.valor, this.texto);
  final String valor;
  final String texto;

  static EstadoEmergencia desde(Object? valor) =>
      values.firstWhere((e) => e.valor == valor, orElse: () => enCurso);
}

class Emergencia {
  const Emergencia({
    required this.id,
    required this.idsPerros,
    required this.nombresPerros,
    required this.tipo,
    required this.ubicacion,
    required this.creadoPor,
    required this.nombreUsuario,
    required this.estado,
    this.nota = '',
    this.creadoEn,
    this.cerradaEn,
  });

  static const vigencia = Duration(days: 3);
  static const avisoCierre = Duration(hours: 24);

  final String id;
  final List<String> idsPerros;
  final List<String> nombresPerros;
  final String tipo;
  final String ubicacion;
  final String creadoPor;
  final String nombreUsuario;
  final EstadoEmergencia estado;
  final String nota;
  final DateTime? creadoEn;
  final DateTime? cerradaEn;

  bool get enCurso => estado == EstadoEmergencia.enCurso;

  bool involucra(String idPerro) => idsPerros.contains(idPerro);

  String get nombres => nombresPerros.isEmpty ? 'Perrito sin identificar' : listarNombres(nombresPerros);

  DateTime? get ultimaNovedad => enCurso ? creadoEn : cerradaEn ?? creadoEn;

  bool visibleEnForo(DateTime ahora) => enCurso
      ? creadoEn == null || ahora.difference(creadoEn!) <= vigencia
      : cerradaEn == null || ahora.difference(cerradaEn!) <= avisoCierre;

  factory Emergencia.fromFirestore(DocumentSnapshot<Map<String, dynamic>> documento) {
    final data = documento.data() ?? const <String, dynamic>{};
    List<String> textos(Object? valor) =>
        valor is List ? valor.map((v) => '$v'.trim()).where((v) => v.isNotEmpty).toList() : const [];
    DateTime? fecha(Object? valor) => valor is Timestamp ? valor.toDate() : null;

    var ids = textos(data['idsPerros']);
    var nombres = textos(data['nombresPerros']);
    final idAntiguo = '${data['idPerro'] ?? ''}'.trim();
    if (ids.isEmpty && idAntiguo.isNotEmpty) {
      ids = [idAntiguo];
      nombres = ['${data['nombrePerro'] ?? 'Perrito'}'.trim()];
    }

    return Emergencia(
      id: documento.id,
      idsPerros: ids,
      nombresPerros: nombres,
      tipo: '${data['tipo'] ?? 'Emergencia'}',
      ubicacion: '${data['ubicacion'] ?? ''}'.trim(),
      creadoPor: '${data['creadoPor'] ?? ''}',
      nombreUsuario: '${data['nombreUsuario'] ?? ''}'.trim(),
      estado: EstadoEmergencia.desde(data['estado']),
      nota: '${data['nota'] ?? ''}'.trim(),
      creadoEn: fecha(data['creadoEn']),
      cerradaEn: fecha(data['cerradaEn']),
    );
  }
}

String listarNombres(List<String> nombres) => switch (nombres.length) {
      0 => '',
      1 => nombres.first,
      _ => '${nombres.sublist(0, nombres.length - 1).join(', ')} y ${nombres.last}',
    };
