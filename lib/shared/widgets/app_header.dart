import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';

/// AppBar estándar de Juris Honoris.
///
/// Fondo blanco, borde inferior #DDDDDD, título centrado Bold 20px.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final String? subtitle;

  const AppHeader({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.subtitle,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        subtitle != null
            ? AppSizes.headerHeight + 20
            : AppSizes.headerHeight,
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.primaryBlue,
                size: 20,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.subtitleGrey,
              ),
            ),
          ],
        ],
      ),
      actions: actions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.borderColor,
        ),
      ),
    );
  }
}
