import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/features/auth/domain/entities/user_entity.dart';

/// Barra de navegación superior del portal web — reemplaza la barra
/// inferior de la app móvil por una navegación horizontal institucional.
/// Solo se usa en pantallas ya migradas a web (Home, Chat IA); las demás
/// siguen con [BottomNavBar] sin cambios.
class WebTopNav extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final void Function(int) onTabChanged;
  final UserEntity? user;

  const WebTopNav({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.user,
  });

  static const _items = [
    ('Inicio', Icons.dashboard_outlined),
    ('Chat IA', Icons.forum_outlined),
    ('Mis casos', Icons.task_alt_outlined),
    ('Expediente', Icons.folder_open_outlined),
    ('Perfil', Icons.person_outline_rounded),
  ];

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final initial = (user?.name?.trim().isNotEmpty ?? false)
        ? user!.name!.trim()[0].toUpperCase()
        : (user?.email.isNotEmpty ?? false)
            ? user!.email[0].toUpperCase()
            : '?';

    return Container(
      height: preferredSize.height,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppColors.webNavyDeep,
        border: Border(
          bottom: BorderSide(color: AppColors.webAccentBrass, width: 2),
        ),
      ),
      child: Row(
        children: [
          // ── Wordmark ─────────────────────────────────────────────
          Row(
            children: [
              const Icon(Icons.balance_rounded,
                  color: AppColors.webAccentBrass, size: 22),
              const SizedBox(width: 10),
              Text(
                'JURIS HONORIS',
                style: GoogleFonts.sourceSerif4(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 48),

          // ── Nav items ────────────────────────────────────────────
          Expanded(
            child: Row(
              children: List.generate(_items.length, (i) {
                final (label, icon) = _items[i];
                final active = i == currentIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: _NavLink(
                    label: label,
                    icon: icon,
                    active: active,
                    onTap: () => onTabChanged(i),
                  ),
                );
              }),
            ),
          ),

          // ── User ─────────────────────────────────────────────────
          if (user != null)
            Row(
              children: [
                Text(
                  user!.name?.split(' ').first ?? user!.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.webAccentBrass,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.webNavyDeep,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavLink({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 17,
                    color: active ? Colors.white : Colors.white54,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    label,
                    style: TextStyle(
                      color: active ? Colors.white : Colors.white54,
                      fontSize: 13.5,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 2,
                width: active ? 28 : 0,
                color: AppColors.webAccentBrass,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
