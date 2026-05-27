import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// Tarjeta estándar de Juris Honoris.
///
/// Fondo blanco, borde #DDDDDD, radius 10px, sombra sutil.
/// Si se provee [onTap], la tarjeta es tappable con ripple effect.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets? margin;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSizes.cardPadding),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSizes.cardRadius),
      border: Border.all(color: AppColors.borderColor),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000), // rgba(0,0,0,0.10)
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    );

    final inner = Padding(padding: padding, child: child);

    if (onTap != null) {
      return Container(
        margin: margin,
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            child: inner,
          ),
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: decoration,
      child: inner,
    );
  }
}
