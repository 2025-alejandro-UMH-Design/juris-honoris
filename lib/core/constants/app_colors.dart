import 'package:flutter/material.dart';

/// Paleta de colores oficial de Juris Honoris.
/// Todos los colores deben tomarse desde aquí — nunca hardcoded.
class AppColors {
  AppColors._();

  // --- Primarios ---
  static const Color primaryBlue = Color(0xFF0D5BA8);
  static const Color primaryBlueDark = Color(0xFF1F4E78);
  static const Color primaryBlueLight = Color(0xFF2E75B6);

  // --- Secundarios ---
  static const Color secondaryOrange = Color(0xFFFF9800);

  // --- Semánticos ---
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);

  // --- Escala de grises ---
  static const Color greyDark = Color(0xFF212121);
  static const Color greyMedium = Color(0xFF757575);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyVeryLight = Color(0xFFF5F5F5);

  // --- Fondos y bordes ---
  static const Color backgroundColor = Color(0xFFFAFAFA);
  static const Color borderColor = Color(0xFFDDDDDD);

  // --- Básicos ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color placeholder = Color(0xFFA8A8A8);

  // --- Categorías de tareas ---
  static const Color categoryWork = Color(0xFF2196F3);
  static const Color categoryPersonal = Color(0xFFFF9800);
  static const Color categoryHealth = Color(0xFF4CAF50);
  static const Color categoryOther = Color(0xFF9C27B0);

  // --- Tipografía secundaria ---
  static const Color subtitleGrey = Color(0xFF666666);
  static const Color hintGrey = Color(0xFF999999);
}
