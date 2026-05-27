import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

enum ButtonVariant { primary, secondary, danger, success }

/// Botón estándar de Juris Honoris.
///
/// Soporta 4 variantes visuales, estado de carga, ancho completo e ícono opcional.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.fullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    final Color backgroundColor = isDisabled
        ? AppColors.greyLight
        : switch (variant) {
            ButtonVariant.primary => AppColors.primaryBlue,
            ButtonVariant.secondary => Colors.transparent,
            ButtonVariant.danger => AppColors.errorRed,
            ButtonVariant.success => AppColors.successGreen,
          };

    final Color foregroundColor = isDisabled
        ? AppColors.greyMedium
        : switch (variant) {
            ButtonVariant.primary => AppColors.white,
            ButtonVariant.secondary => AppColors.primaryBlue,
            ButtonVariant.danger => AppColors.white,
            ButtonVariant.success => AppColors.white,
          };

    final BorderSide borderSide = variant == ButtonVariant.secondary
        ? const BorderSide(color: AppColors.borderColor)
        : BorderSide.none;

    final Widget content = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: AppSizes.iconSize, color: foregroundColor),
                const SizedBox(width: AppSizes.sm),
              ],
              Text(
                label,
                style: TextStyle(
                  color: foregroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );

    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      minimumSize: Size(
        fullWidth ? double.infinity : 0,
        AppSizes.buttonHeight,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
        side: borderSide,
      ),
      elevation: variant == ButtonVariant.secondary ? 0 : 2,
      shadowColor: Colors.black26,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.xl2,
        vertical: AppSizes.md,
      ),
    );

    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: style,
      child: content,
    );
  }
}
