import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextStyle _base({
    required double size,
    required FontWeight weight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle display = _base(size: 30, weight: FontWeight.w700, height: 1.2, letterSpacing: -0.4);
  static TextStyle h1 = _base(size: 24, weight: FontWeight.w700, height: 1.25, letterSpacing: -0.2);
  static TextStyle h2 = _base(size: 20, weight: FontWeight.w700, height: 1.3);
  static TextStyle h3 = _base(size: 17, weight: FontWeight.w600, height: 1.3);
  static TextStyle bodyLarge = _base(size: 16, weight: FontWeight.w400, height: 1.5);
  static TextStyle body = _base(size: 14, weight: FontWeight.w400, height: 1.5);
  static TextStyle bodyMedium = _base(size: 14, weight: FontWeight.w500, height: 1.4);
  static TextStyle bodySmall = _base(size: 13, weight: FontWeight.w400, height: 1.4);
  static TextStyle label = _base(size: 13, weight: FontWeight.w600, height: 1.3);
  static TextStyle caption = _base(size: 12, weight: FontWeight.w500, height: 1.3);
  static TextStyle button = _base(size: 15, weight: FontWeight.w600, height: 1.2, letterSpacing: 0.1);

  static TextStyle onColor(TextStyle style, Color color) => style.copyWith(color: color);
}
