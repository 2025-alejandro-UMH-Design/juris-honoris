import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Extensiones de conveniencia sobre [BuildContext].
extension ContextExtensions on BuildContext {
  // --- Theme helpers ---

  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  // --- Screen size ---

  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Dispositivo móvil: ancho menor a 600 dp.
  bool get isMobile => screenWidth < 600;

  /// Tablet: ancho entre 600 y 900 dp.
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;

  // --- SnackBars ---

  /// Muestra un SnackBar informativo o de error.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: AppColors.white),
          ),
          backgroundColor:
              isError ? AppColors.errorRed : AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  /// Atajo para mostrar un SnackBar de error.
  void showErrorSnackBar(String message) =>
      showSnackBar(message, isError: true);
}
