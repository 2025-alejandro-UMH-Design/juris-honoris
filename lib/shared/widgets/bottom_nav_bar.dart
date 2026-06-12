import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';

/// Barra de navegación inferior de Juris Honoris.
///
/// 4 tabs: Inicio, Chat IA, Tareas, Dossier.
/// Alto: 60px, fondo blanco, borde superior #DDDDDD.
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTabChanged;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
  });

  static const List<_NavItem> _items = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: AppStrings.navInicio,
    ),
    _NavItem(
      icon: Icons.smart_toy_outlined,
      activeIcon: Icons.smart_toy_rounded,
      label: AppStrings.navChatIa,
    ),
    _NavItem(
      icon: Icons.task_alt_outlined,
      activeIcon: Icons.task_alt_rounded,
      label: AppStrings.navTareas,
    ),
    _NavItem(
      icon: Icons.folder_special_outlined,
      activeIcon: Icons.folder_special_rounded,
      label: AppStrings.navDossier,
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: AppStrings.navPerfil,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.bottomNavHeight,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Row(
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final bool isActive = index == currentIndex;
          return Expanded(
            child: InkWell(
              onTap: () => onTabChanged(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActive ? item.activeIcon : item.icon,
                    size: AppSizes.iconSize,
                    color: isActive
                        ? AppColors.primaryBlue
                        : AppColors.placeholder,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isActive
                          ? AppColors.primaryBlue
                          : AppColors.placeholder,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
