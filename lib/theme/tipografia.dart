import 'package:flutter/material.dart';

extension Display on TextStyle {
  TextStyle get display => copyWith(fontVariations: [
    const FontVariation('opsz', 32),
    FontVariation('wght', (fontWeight ?? FontWeight.w400).value.toDouble()),
  ]);
}
