import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'app_button.dart';

/// Pantalla de estado de error.
///
/// Icono de error rojo, mensaje descriptivo y botón de reintentar opcional.
class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 72,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.greyDark,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: AppStrings.reintentar,
                onPressed: onRetry,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
