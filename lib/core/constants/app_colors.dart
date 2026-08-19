import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Paleta de colores oficial de Juris Honoris.
/// Sincronizada con el design system de Stitch (proyecto 4533192331469825392).
///
/// En web, los tokens principales resuelven a una paleta institucional
/// (navy profundo + papel + acento bronce) en vez del azul de la app móvil.
/// `kIsWeb` es una constante de compilación: el APK móvil compila exactamente
/// a los valores originales, sin ningún cambio de comportamiento ni tamaño.
class AppColors {
  AppColors._();

  // --- Primarios ---
  static const Color primaryBlue =
      kIsWeb ? Color(0xFF0A3D66) : Color(0xFF378ADD);
  static const Color primaryBlueDark =
      kIsWeb ? Color(0xFF062A47) : Color(0xFF005EA4);
  static const Color primaryBlueLight =
      kIsWeb ? Color(0xFF2C5F8A) : Color(0xFF1777C9);

  // --- Acento institucional (solo referenciado en pantallas web) ---
  static const Color webAccentBrass = Color(0xFF9C7A3C);
  static const Color webNavyDeep = Color(0xFF071E33);

  // --- Semánticos (se mantienen universales por reconocibilidad) ---
  static const Color successGreen  = Color(0xFF639922);
  static const Color errorRed      = Color(0xFFE24B4A);
  static const Color warningAmber  = Color(0xFFBA7517);

  // --- Escala de grises (base warm neutral) ---
  static const Color greyDark =
      kIsWeb ? Color(0xFF1B2432) : Color(0xFF2C2C2A);
  static const Color greyMedium    = Color(0xFF717783);
  static const Color greyLight =
      kIsWeb ? Color(0xFFD9D4C6) : Color(0xFFB4B2A9);
  static const Color greyVeryLight =
      kIsWeb ? Color(0xFFF6F4EE) : Color(0xFFF6F3F0);

  // --- Fondos y bordes ---
  static const Color backgroundColor =
      kIsWeb ? Color(0xFFF6F4EE) : Color(0xFFF1EFE8);
  static const Color borderColor =
      kIsWeb ? Color(0xFFDDD8C9) : Color(0xFFB4B2A9);

  // --- Básicos ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // --- Tipografía secundaria ---
  static const Color subtitleGrey =
      kIsWeb ? Color(0xFF3D4658) : Color(0xFF5F5E5A);
  static const Color hintGrey     = Color(0xFF717783);
  static const Color placeholder  = Color(0xFF9E9E9E);

  // --- Alias semántico (para compatibilidad) ---
  static const Color secondaryOrange = warningAmber;
}
