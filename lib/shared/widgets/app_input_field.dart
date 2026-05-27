import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Campo de texto estándar de Juris Honoris.
///
/// Estilo: fondo blanco, borde #DDDDDD, foco borde #0D5BA8, radius 8px.
class AppInputField extends StatelessWidget {
  final String? label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffixWidget;
  final bool enabled;

  const AppInputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixWidget,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          enabled: enabled,
          style: TextStyle(
            fontSize: 14,
            color: enabled ? AppColors.greyDark : AppColors.greyMedium,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.hintGrey,
              fontSize: 14,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
            constraints: BoxConstraints(
              minHeight: maxLines > 1 ? 0 : AppSizes.inputHeight,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: AppSizes.iconSize,
                    color: AppColors.greyMedium,
                  )
                : null,
            suffixIcon: suffixWidget,
            filled: true,
            fillColor: enabled ? AppColors.white : AppColors.greyVeryLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(color: AppColors.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(
                color: AppColors.errorRed,
                width: 1.5,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSizes.inputRadius),
              borderSide: const BorderSide(color: AppColors.greyLight),
            ),
          ),
        ),
      ],
    );
  }
}
