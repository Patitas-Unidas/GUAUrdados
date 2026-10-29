import 'package:flutter/material.dart';

class Formas {
  static RoundedSuperellipseBorder squircle(double radio, {BorderSide lado = BorderSide.none}) =>
      RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(radio), side: lado);

  static RoundedSuperellipseBorder squircleArriba(double radio) =>
      RoundedSuperellipseBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(radio)));

  static ShapeDecoration fondo(Color color, double radio, {List<BoxShadow>? sombras}) =>
      ShapeDecoration(color: color, shape: squircle(radio), shadows: sombras);
}

class BordeSquircle extends InputBorder {
  const BordeSquircle({this.radio = 24, super.borderSide = BorderSide.none});
  final double radio;

  RoundedSuperellipseBorder get _forma => Formas.squircle(radio, lado: borderSide);

  @override
  bool get isOutline => true;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.width);

  @override
  BordeSquircle copyWith({BorderSide? borderSide}) => BordeSquircle(radio: radio, borderSide: borderSide ?? this.borderSide);

  @override
  ShapeBorder scale(double t) => BordeSquircle(radio: radio * t, borderSide: borderSide.scale(t));

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => _forma.getInnerPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => _forma.getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {double? gapStart, double gapExtent = 0, double gapPercentage = 0, TextDirection? textDirection}) =>
      _forma.paint(canvas, rect, textDirection: textDirection);
}
