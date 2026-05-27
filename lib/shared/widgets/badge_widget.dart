import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum BadgeVariant { success, danger, warning, info, gray }

/// Indicador de estado en forma de pill (pastilla).
///
/// 12px Bold, padding 6px horizontal / 3px vertical.
class BadgeWidget extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;

  const BadgeWidget({
    super.key,
    required this.label,
    this.variant = BadgeVariant.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors(variant);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: colors.foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeColors _resolveColors(BadgeVariant v) => switch (v) {
        BadgeVariant.success => const _BadgeColors(
            background: Color(0xFFE8F5E9),
            foreground: AppColors.successGreen,
          ),
        BadgeVariant.danger => const _BadgeColors(
            background: Color(0xFFFFEBEE),
            foreground: AppColors.errorRed,
          ),
        BadgeVariant.warning => const _BadgeColors(
            background: Color(0xFFFFF8E1),
            foreground: AppColors.secondaryOrange,
          ),
        BadgeVariant.info => const _BadgeColors(
            background: Color(0xFFE3F2FD),
            foreground: AppColors.primaryBlue,
          ),
        BadgeVariant.gray => const _BadgeColors(
            background: AppColors.greyVeryLight,
            foreground: AppColors.greyMedium,
          ),
      };
}

class _BadgeColors {
  final Color background;
  final Color foreground;

  const _BadgeColors({required this.background, required this.foreground});
}
