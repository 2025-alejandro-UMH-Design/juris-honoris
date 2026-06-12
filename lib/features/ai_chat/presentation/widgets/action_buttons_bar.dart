import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';

/// Barra de acciones contextual que aparece cuando la IA determina si el
/// usuario necesita un abogado o puede gestionar el trámite por sí mismo.
///
/// - [needsLawyer] = true → botón "Solicitar Abogado" + "Ver directorio"
/// - [needsLawyer] = false → botón "Ver mis documentos" + "Crear hito"
class ActionButtonsBar extends StatelessWidget {
  final bool needsLawyer;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  const ActionButtonsBar({
    super.key,
    required this.needsLawyer,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.borderColor, width: 1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: needsLawyer ? 'Solicitar Abogado' : 'Ver mis documentos',
                icon: needsLawyer ? Icons.gavel : Icons.folder_open,
                variant: needsLawyer
                    ? _ButtonVariant.danger
                    : _ButtonVariant.success,
                onPressed: onPrimaryAction,
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: _ActionButton(
                label: needsLawyer ? 'Ver directorio' : 'Crear hito',
                icon: needsLawyer ? Icons.people : Icons.flag,
                variant: _ButtonVariant.secondary,
                onPressed: onSecondaryAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _ButtonVariant { danger, success, secondary }

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final _ButtonVariant variant;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.variant,
    this.onPressed,
  });

  Color get _backgroundColor {
    switch (variant) {
      case _ButtonVariant.danger:
        return AppColors.errorRed;
      case _ButtonVariant.success:
        return AppColors.successGreen;
      case _ButtonVariant.secondary:
        return AppColors.greyVeryLight;
    }
  }

  Color get _foregroundColor {
    switch (variant) {
      case _ButtonVariant.danger:
      case _ButtonVariant.success:
        return AppColors.white;
      case _ButtonVariant.secondary:
        return AppColors.greyDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _backgroundColor,
          foregroundColor: _foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
        ),
      ),
    );
  }
}
