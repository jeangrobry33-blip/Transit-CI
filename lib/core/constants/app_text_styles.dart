import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typographie Transit CI — Fraunces (titres, du caractère) + Archivo
/// (interface, lisible et robuste pour les chiffres). Voir docs/DESIGN.md §2
/// pour la justification du choix et le détail de l'échelle.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _display({
    required double size,
    required FontWeight weight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle _ui({
    required double size,
    required FontWeight weight,
    double? height,
    double? letterSpacing,
    Color? color,
  }) {
    return GoogleFonts.archivo(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
    );
  }

  static TextStyle display = _display(size: 34, weight: FontWeight.w600, height: 1.1, letterSpacing: -0.4);
  static TextStyle h1 = _display(size: 28, weight: FontWeight.w600, height: 1.15, letterSpacing: -0.3);
  static TextStyle h2 = _display(size: 22, weight: FontWeight.w600, height: 1.2, letterSpacing: -0.2);
  static TextStyle h3 = _display(size: 18, weight: FontWeight.w600, height: 1.25);
  static TextStyle titleMd = _ui(size: 16, weight: FontWeight.w600, height: 1.3);
  static TextStyle bodyLg = _ui(size: 16, weight: FontWeight.w400, height: 1.5);
  static TextStyle bodyMd = _ui(size: 14, weight: FontWeight.w400, height: 1.5);
  static TextStyle bodySm = _ui(size: 12, weight: FontWeight.w400, height: 1.4, letterSpacing: 0.1);
  static TextStyle label = _ui(size: 13, weight: FontWeight.w600, height: 1.3, letterSpacing: 0.2);
  static TextStyle caption = _ui(size: 11, weight: FontWeight.w500, height: 1.3, letterSpacing: 0.3);
  static TextStyle button = _ui(size: 15, weight: FontWeight.w700, height: 1.2, letterSpacing: 0.1);
}
