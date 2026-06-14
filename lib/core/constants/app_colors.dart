import 'package:flutter/material.dart';

/// Paleta de colores oficial de Juris Honoris.
/// Sincronizada con el design system de Stitch (proyecto 4533192331469825392).
class AppColors {
  AppColors._();

  // --- Primarios (Trust Blue) ---
  static const Color primaryBlue      = Color(0xFF378ADD);
  static const Color primaryBlueDark  = Color(0xFF005EA4);
  static const Color primaryBlueLight = Color(0xFF1777C9);

  // --- Semánticos ---
  static const Color successGreen  = Color(0xFF639922);
  static const Color errorRed      = Color(0xFFE24B4A);
  static const Color warningAmber  = Color(0xFFBA7517);

  // --- Escala de grises (base warm neutral) ---
  static const Color greyDark      = Color(0xFF2C2C2A);
  static const Color greyMedium    = Color(0xFF717783);
  static const Color greyLight     = Color(0xFFB4B2A9);
  static const Color greyVeryLight = Color(0xFFF6F3F0);

  // --- Fondos y bordes ---
  static const Color backgroundColor = Color(0xFFF1EFE8);
  static const Color borderColor     = Color(0xFFB4B2A9);

  // --- Básicos ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // --- Tipografía secundaria ---
  static const Color subtitleGrey = Color(0xFF5F5E5A);
  static const Color hintGrey     = Color(0xFF717783);
  static const Color placeholder  = Color(0xFF9E9E9E);

  // --- Alias semántico (para compatibilidad) ---
  static const Color secondaryOrange = warningAmber;
}
