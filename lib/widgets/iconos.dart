import 'package:flutter/material.dart';

const _lucide = 'Lucide';
const _duotono = 'PhosphorDuotone';

class Iconos {
  static const aLargeSmall = IconData(0xe587, fontFamily: _lucide);
  static const bell = IconData(0xe059, fontFamily: _lucide);
  static const calendar = IconData(0xe063, fontFamily: _lucide);
  static const camera = IconData(0xe064, fontFamily: _lucide);
  static const check = IconData(0xe06c, fontFamily: _lucide);
  static const chevronLeft = IconData(0xe06e, fontFamily: _lucide);
  static const chevronRight = IconData(0xe06f, fontFamily: _lucide);
  static const circleAlert = IconData(0xe077, fontFamily: _lucide);
  static const circleCheck = IconData(0xe226, fontFamily: _lucide);
  static const circleHelp = IconData(0xe082, fontFamily: _lucide);
  static const circleUser = IconData(0xe461, fontFamily: _lucide);
  static const circleX = IconData(0xe084, fontFamily: _lucide);
  static const clock = IconData(0xe087, fontFamily: _lucide);
  static const ellipsis = IconData(0xe0b6, fontFamily: _lucide);
  static const fileText = IconData(0xe0cc, fontFamily: _lucide);
  static const flame = IconData(0xe0d2, fontFamily: _lucide);
  static const handHeart = IconData(0xe5b9, fontFamily: _lucide);
  static const heartPulse = IconData(0xe36e, fontFamily: _lucide);
  static const heart = IconData(0xe0f2, fontFamily: _lucide);
  static const house = IconData(0xe0f5, fontFamily: _lucide);
  static const idCard = IconData(0xe617, fontFamily: _lucide);
  static const imageOff = IconData(0xe1c0, fontFamily: _lucide);
  static const imagePlus = IconData(0xe1f7, fontFamily: _lucide);
  static const info = IconData(0xe0f9, fontFamily: _lucide);
  static const lock = IconData(0xe10b, fontFamily: _lucide);
  static const logOut = IconData(0xe10e, fontFamily: _lucide);
  static const mail = IconData(0xe10f, fontFamily: _lucide);
  static const mapPin = IconData(0xe111, fontFamily: _lucide);
  static const messageCircle = IconData(0xe116, fontFamily: _lucide);
  static const minus = IconData(0xe11c, fontFamily: _lucide);
  static const moon = IconData(0xe11e, fontFamily: _lucide);
  static const notebookPen = IconData(0xe596, fontFamily: _lucide);
  static const pencil = IconData(0xe1f9, fontFamily: _lucide);
  static const pill = IconData(0xe3bd, fontFamily: _lucide);
  static const plus = IconData(0xe13d, fontFamily: _lucide);
  static const scissors = IconData(0xe14e, fontFamily: _lucide);
  static const search = IconData(0xe151, fontFamily: _lucide);
  static const send = IconData(0xe152, fontFamily: _lucide);
  static const settings = IconData(0xe154, fontFamily: _lucide);
  static const shieldCheck = IconData(0xe1ff, fontFamily: _lucide);
  static const siren = IconData(0xe2ef, fontFamily: _lucide);
  static const smile = IconData(0xe164, fontFamily: _lucide);
  static const stethoscope = IconData(0xe2f1, fontFamily: _lucide);
  static const sun = IconData(0xe178, fontFamily: _lucide);
  static const sunMoon = IconData(0xe2b2, fontFamily: _lucide);
  static const syringe = IconData(0xe2f2, fontFamily: _lucide);
  static const trash2 = IconData(0xe18e, fontFamily: _lucide);
  static const triangleAlert = IconData(0xe193, fontFamily: _lucide);
  static const user = IconData(0xe19f, fontFamily: _lucide);
  static const users = IconData(0xe1a4, fontFamily: _lucide);
  static const utensils = IconData(0xe2f6, fontFamily: _lucide);
  static const weight = IconData(0xe530, fontFamily: _lucide);
  static const x = IconData(0xe1b2, fontFamily: _lucide);
  static const zap = IconData(0xe1b4, fontFamily: _lucide);

  static const pawPrint = IconData(0xe649, fontFamily: _duotono);
  static const pawPrintRelleno = IconData(0xe648, fontFamily: 'PhosphorFill');
}

class Icono extends StatelessWidget {
  const Icono(this.icono, {super.key, this.size, this.color});
  final IconData icono;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final trazo = Icon(icono, size: size, color: color);
    if (icono != Iconos.pawPrint) return trazo;
    return Stack(alignment: Alignment.center, children: [
      Opacity(opacity: .2, child: Icon(const IconData(0xe648, fontFamily: _duotono), size: size, color: color)),
      trazo,
    ]);
  }
}
