import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/shared/widgets/app_card.dart';

import 'lawyer_marketplace_page.dart';
import 'lawyer_chat_page.dart';
import 'lawyer_profile_edit_page.dart';

// ── Main scaffold with bottom nav ──────────────────────────────────────────────

class LawyerDashboardPage extends StatefulWidget {
  const LawyerDashboardPage({super.key});

  @override
  State<LawyerDashboardPage> createState() => _LawyerDashboardPageState();
}

class _LawyerDashboardPageState extends State<LawyerDashboardPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = const [
      _DashboardHome(),
      LawyerMarketplacePage(),
      LawyerChatPage(
        clientName: 'Juan G.',
        caseType: 'Derecho de Familia',
        caseId: 'c1',
      ),
      LawyerProfileEditPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _LawyerBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}

// ── Bottom nav ─────────────────────────────────────────────────────────────────

class _LawyerBottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onTap;

  const _LawyerBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.greyMedium,
      backgroundColor: AppColors.white,
      selectedLabelStyle:
          const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio'),
        BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Casos'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Chat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil'),
      ],
    );
  }
}

// ── Home tab ───────────────────────────────────────────────────────────────────

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    final displayName = user?.name ?? 'Abogado';
    final initials = _initials(displayName);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Mi Dashboard',
          style: TextStyle(
              color: AppColors.greyDark,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSizes.md),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              radius: 18,
              child: Text(
                initials,
                style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome card ──────────────────────────────────────
            _WelcomeCard(name: displayName),
            const SizedBox(height: AppSizes.lg),

            // ── Stats grid ────────────────────────────────────────
            const Text(
              'Resumen',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyDark),
            ),
            const SizedBox(height: AppSizes.sm),
            _StatsGrid(),
            const SizedBox(height: AppSizes.lg),

            // ── New requests (placeholder) ────────────────────────
            Row(
              children: [
                const Text(
                  'Nuevas solicitudes',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyDark),
                ),
                const SizedBox(width: AppSizes.sm),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '0',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            const _EmptySection(
              icon: Icons.inbox_outlined,
              message: 'No tienes solicitudes pendientes',
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Active cases (placeholder) ────────────────────────
            const Text(
              'Casos activos',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyDark),
            ),
            const SizedBox(height: AppSizes.sm),
            const _EmptySection(
              icon: Icons.folder_open_outlined,
              message: 'No tienes casos activos',
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String name;
  const _WelcomeCard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        boxShadow: const [
          BoxShadow(
              color: Color(0x330D5BA8), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buenos días, $name',
            style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm, vertical: AppSizes.xs),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: AppColors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Verificado',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Container(
            padding: const EdgeInsets.all(AppSizes.sm),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.card_giftcard, color: AppColors.white, size: 16),
                SizedBox(width: AppSizes.sm),
                Text(
                  'Tu primer caso es GRATIS — sin comisión',
                  style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.sm,
      mainAxisSpacing: AppSizes.sm,
      childAspectRatio: 1.6,
      children: const [
        _StatCard(
          label: 'Casos activos',
          value: '0',
          icon: Icons.folder_open_outlined,
          iconColor: AppColors.primaryBlue,
        ),
        _StatCard(
          label: 'Casos total',
          value: '0',
          icon: Icons.folder_copy_outlined,
          iconColor: AppColors.secondaryOrange,
        ),
        _StatCard(
          label: 'Rating',
          value: '-',
          icon: Icons.star_outline,
          iconColor: AppColors.secondaryOrange,
        ),
        _StatCard(
          label: 'Ingresos mes',
          value: 'L. 0',
          icon: Icons.account_balance_wallet_outlined,
          iconColor: AppColors.successGreen,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const Spacer(),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.subtitleGrey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptySection({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.xl),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.greyLight),
            const SizedBox(height: AppSizes.sm),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.greyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
