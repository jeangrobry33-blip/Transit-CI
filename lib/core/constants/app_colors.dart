import 'package:flutter/material.dart';

/// Palette de Transit CI — inspirée du drapeau ivoirien (orange, blanc, vert)
/// avec des tons premium pour une esthétique de type Uber/Bolt/Google Maps.
class AppColors {
  AppColors._();

  // Couleurs de marque
  static const Color orange = Color(0xFFFF7A00);
  static const Color orangeDark = Color(0xFFE05F00);
  static const Color orangeLight = Color(0xFFFFB870);
  // Texte accentué sur fond clair (prix, liens) : AA 5.23:1 sur blanc.
  // `orange` brut ne passe pas en texte (2.61:1) — voir docs/DESIGN.md §1.1.
  static const Color orangeInk = Color(0xFFAD5300);
  static const Color ivoryGreen = Color(0xFF0F9D58);
  static const Color ivoryGreenDark = Color(0xFF0B7A44);
  static const Color ivoryGreenLight = Color(0xFF5FCB8C);

  // Neutres
  static const Color night = Color(0xFF0B0E14);
  static const Color surfaceDark = Color(0xFF141924);
  static const Color surfaceDarkAlt = Color(0xFF1C2330);
  static const Color slate = Color(0xFF4A5568);
  static const Color mist = Color(0xFF8A94A6);
  // Texte secondaire sur fond clair : AA 7.74:1 sur blanc, contre 3.06:1
  // pour `mist` (échec AA). `mist` reste réservé aux icônes/bordures et au
  // texte secondaire en thème sombre (6.32:1 sur `night`). Voir DESIGN.md §1.1.
  static const Color textMuted = Color(0xFF4B5362);
  static const Color fog = Color(0xFFE7EAF0);
  static const Color cloud = Color(0xFFF4F6FA);
  static const Color white = Color(0xFFFFFFFF);

  // États / feedback — réservées aux fonds teintés/icônes de grande taille.
  static const Color success = Color(0xFF12B76A);
  static const Color warning = Color(0xFFF79009);
  static const Color danger = Color(0xFFF04438);
  static const Color info = Color(0xFF2E90FA);

  // Variantes texte des couleurs d'état : `success`/`warning`/`danger` en
  // texte sur fond clair échouent l'AA (2.35 à 3.76:1) — ces variantes
  // passent toutes 4.5:1+. `info` et `danger` (via `errorBorder`) restent
  // des cas à vérifier au cas par cas. Voir docs/QA_AUDIT.md.
  static const Color successInk = Color(0xFF0D844C);
  static const Color warningInk = Color(0xFFA96205);
  static const Color dangerInk = Color(0xFFE41F11);

  // Niveaux d'affluence (gbaka / wôrô-wôrô)
  static const Color affluenceLow = success;
  static const Color affluenceMedium = warning;
  static const Color affluenceHigh = danger;

  // Dégradés
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeDark],
  );

  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ivoryGreen, ivoryGreenDark],
  );

  static const LinearGradient darkGlassGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [surfaceDarkAlt, surfaceDark],
  );

  // Couleurs par mode de transport
  static const Color modeVtc = Color(0xFF6C5CE7);
  static const Color modeTaxi = Color(0xFFF7B500);
  static const Color modeGbaka = Color(0xFF0F9D58);
  static const Color modeWoroworo = Color(0xFF00B8D9);
  static const Color modeBusUrbain = Color(0xFF2E90FA);
  static const Color modeMoto = Color(0xFFF04438);
  static const Color modeInterurbain = Color(0xFFFF7A00);
}
