import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';

/// Barra de acciones contextual que aparece cuando la IA determina si el
/// usuario necesita un abogado o puede gestionar el trámite por sí mismo.
///
/// - [needsLawyer] = false → botón verde full-width "Ver plan de acción"
/// - [needsLawyer] = true  → botón "Solicitar Abogado" + "Ver directorio"
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
        child: needsLawyer ? _lawyerButtons() : _planButton(),
      ),
    );
  }

  Widget _planButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: onPrimaryAction,
        icon: const Icon(Icons.article_outlined, size: 18),
        label: const Text(
          'Ver plan de accion',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.successGreen,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          ),
        ),
      ),
    );
  }

  Widget _lawyerButtons() {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'Solicitar Abogado',
            icon: Icons.gavel,
            variant: _ButtonVariant.danger,
            onPressed: onPrimaryAction,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: _ActionButton(
            label: 'Ver directorio',
            icon: Icons.people,
            variant: _ButtonVariant.secondary,
            onPressed: onSecondaryAction,
          ),
        ),
      ],
    );
  }
}

enum _ButtonVariant { danger, secondary }

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

  Color get _backgroundColor => switch (variant) {
        _ButtonVariant.danger => AppColors.errorRed,
        _ButtonVariant.secondary => AppColors.greyVeryLight,
      };

  Color get _foregroundColor => switch (variant) {
        _ButtonVariant.danger => AppColors.white,
        _ButtonVariant.secondary => AppColors.greyDark,
      };

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
