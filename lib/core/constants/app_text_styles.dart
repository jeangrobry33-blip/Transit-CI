import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typographie premium — Plus Jakarta Sans pour un rendu moderne et lisible.
class AppTextStyles {
  AppTextStyles._();

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

  static TextStyle display = _base(size: 34, weight: FontWeight.w800, height: 1.15);
  static TextStyle h1 = _base(size: 28, weight: FontWeight.w800, height: 1.2);
  static TextStyle h2 = _base(size: 22, weight: FontWeight.w700, height: 1.25);
  static TextStyle h3 = _base(size: 18, weight: FontWeight.w700, height: 1.3);
  static TextStyle titleMd = _base(size: 16, weight: FontWeight.w600, height: 1.3);
  static TextStyle bodyLg = _base(size: 16, weight: FontWeight.w400, height: 1.5);
  static TextStyle bodyMd = _base(size: 14, weight: FontWeight.w400, height: 1.5);
  static TextStyle bodySm = _base(size: 12, weight: FontWeight.w400, height: 1.4);
  static TextStyle label = _base(size: 13, weight: FontWeight.w600, height: 1.3, letterSpacing: 0.2);
  static TextStyle caption = _base(size: 11, weight: FontWeight.w500, height: 1.3, letterSpacing: 0.3);
  static TextStyle button = _base(size: 15, weight: FontWeight.w700, height: 1.2, letterSpacing: 0.2);
}
