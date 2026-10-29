import 'package:flutter/material.dart';

import 'app_colors.dart';

@immutable
class ColoresApp extends ThemeExtension<ColoresApp> {
  const ColoresApp({
    required this.fondo,
    required this.fondoCalido,
    required this.superficie,
    required this.superficieSuave,
    required this.contenedor,
    required this.fondoAvatar,
    required this.navegacion,
    required this.texto,
    required this.textoSecundario,
    required this.textoTenue,
    required this.divisor,
    required this.acento,
    required this.sobreAcento,
    required this.secundario,
    required this.tonal,
    required this.sobreTonal,
    required this.emergencia,
    required this.emergenciaSuave,
    required this.exito,
    required this.exitoSuave,
    required this.advertencia,
    required this.advertenciaSuave,
    required this.medico,
    required this.velo,
    required this.esqueleto,
    required this.esqueletoBrillo,
    required this.exitoTexto,
    required this.advertenciaTexto,
    required this.neutroTexto,
    required this.emergenciaTexto,
  });

  final Color fondo;
  final Color fondoCalido;
  final Color superficie;
  final Color superficieSuave;
  final Color contenedor;
  final Color fondoAvatar;
  final Color navegacion;
  final Color texto;
  final Color textoSecundario;
  final Color textoTenue;
  final Color divisor;
  final Color acento;
  final Color sobreAcento;
  final Color secundario;
  final Color tonal;
  final Color sobreTonal;
  final Color emergencia;
  final Color emergenciaSuave;
  final Color exito;
  final Color exitoSuave;
  final Color advertencia;
  final Color advertenciaSuave;
  final Color medico;
  final Color velo;
  final Color esqueleto;
  final Color esqueletoBrillo;
  final Color exitoTexto;
  final Color advertenciaTexto;
  final Color neutroTexto;
  final Color emergenciaTexto;

  static const claro = ColoresApp(
    fondo: AppColors.crema,
    fondoCalido: AppColors.cremaRosada,
    superficie: AppColors.blanco,
    superficieSuave: AppColors.cremaClara,
    contenedor: AppColors.cremaRosada,
    fondoAvatar: AppColors.arena,
    navegacion: AppColors.durazno,
    texto: AppColors.grisOscuro,
    textoSecundario: AppColors.grisMedio,
    textoTenue: AppColors.grisTenue,
    divisor: AppColors.grisBorde,
    acento: AppColors.rojoMarca,
    sobreAcento: AppColors.blanco,
    secundario: AppColors.cafe,
    tonal: AppColors.tierra,
    sobreTonal: AppColors.cafe,
    emergencia: AppColors.rojoUrgencia,
    emergenciaSuave: AppColors.rojoUrgenciaSuave,
    exito: AppColors.verde,
    exitoSuave: AppColors.verdeSuave,
    advertencia: AppColors.naranja,
    advertenciaSuave: AppColors.naranjaSuave,
    medico: AppColors.turquesaMedico,
    velo: Color(0xb3000000),
    esqueleto: AppColors.grisBorde,
    esqueletoBrillo: AppColors.crema,
    exitoTexto: AppColors.verdeTexto,
    advertenciaTexto: AppColors.naranjaTexto,
    neutroTexto: AppColors.grisTexto,
    emergenciaTexto: AppColors.rojoTexto,
  );

  static const oscuro = ColoresApp(
    fondo: AppColors.oscuroFondo,
    fondoCalido: AppColors.oscuroFondo,
    superficie: AppColors.oscuroSuperficie,
    superficieSuave: AppColors.oscuroSuperficie,
    contenedor: AppColors.oscuroContenedor,
    fondoAvatar: AppColors.oscuroContenedor,
    navegacion: AppColors.oscuroSuperficie,
    texto: AppColors.oscuroTexto,
    textoSecundario: AppColors.oscuroTextoSecundario,
    textoTenue: AppColors.oscuroTextoTenue,
    divisor: AppColors.oscuroBorde,
    acento: AppColors.rojoMarca,
    sobreAcento: AppColors.blanco,
    secundario: AppColors.cafe,
    tonal: AppColors.oscuroContenedor,
    sobreTonal: AppColors.tierra,
    emergencia: AppColors.rojoUrgencia,
    emergenciaSuave: Color(0x33ff0037),
    exito: AppColors.verde,
    exitoSuave: Color(0x334caf82),
    advertencia: AppColors.naranja,
    advertenciaSuave: Color(0x33ff9500),
    medico: AppColors.turquesaMedico,
    velo: Color(0xb3000000),
    esqueleto: AppColors.oscuroContenedor,
    esqueletoBrillo: AppColors.oscuroBorde,
    exitoTexto: AppColors.verde,
    advertenciaTexto: AppColors.naranja,
    neutroTexto: AppColors.oscuroTextoSecundario,
    emergenciaTexto: AppColors.rojoUrgencia,
  );

  @override
  ColoresApp copyWith() => this;

  @override
  ColoresApp lerp(ColoresApp? other, double t) {
    if (other == null) return this;
    Color m(Color a, Color b) => Color.lerp(a, b, t)!;
    return ColoresApp(
      fondo: m(fondo, other.fondo),
      fondoCalido: m(fondoCalido, other.fondoCalido),
      superficie: m(superficie, other.superficie),
      superficieSuave: m(superficieSuave, other.superficieSuave),
      contenedor: m(contenedor, other.contenedor),
      fondoAvatar: m(fondoAvatar, other.fondoAvatar),
      navegacion: m(navegacion, other.navegacion),
      texto: m(texto, other.texto),
      textoSecundario: m(textoSecundario, other.textoSecundario),
      textoTenue: m(textoTenue, other.textoTenue),
      divisor: m(divisor, other.divisor),
      acento: m(acento, other.acento),
      sobreAcento: m(sobreAcento, other.sobreAcento),
      secundario: m(secundario, other.secundario),
      tonal: m(tonal, other.tonal),
      sobreTonal: m(sobreTonal, other.sobreTonal),
      emergencia: m(emergencia, other.emergencia),
      emergenciaSuave: m(emergenciaSuave, other.emergenciaSuave),
      exito: m(exito, other.exito),
      exitoSuave: m(exitoSuave, other.exitoSuave),
      advertencia: m(advertencia, other.advertencia),
      advertenciaSuave: m(advertenciaSuave, other.advertenciaSuave),
      medico: m(medico, other.medico),
      velo: m(velo, other.velo),
      esqueleto: m(esqueleto, other.esqueleto),
      esqueletoBrillo: m(esqueletoBrillo, other.esqueletoBrillo),
      exitoTexto: m(exitoTexto, other.exitoTexto),
      advertenciaTexto: m(advertenciaTexto, other.advertenciaTexto),
      neutroTexto: m(neutroTexto, other.neutroTexto),
      emergenciaTexto: m(emergenciaTexto, other.emergenciaTexto),
    );
  }
}

extension ColoresContext on BuildContext {
  ColoresApp get colores {
    final tema = Theme.of(this);
    return tema.extension<ColoresApp>() ?? (tema.brightness == Brightness.dark ? ColoresApp.oscuro : ColoresApp.claro);
  }
}
