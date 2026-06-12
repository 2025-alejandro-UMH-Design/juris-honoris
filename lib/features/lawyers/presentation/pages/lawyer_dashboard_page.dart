import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/shared/widgets/app_card.dart';

import 'accept_reject_case_page.dart';
import 'lawyer_marketplace_page.dart';
import 'lawyer_chat_page.dart';
import 'lawyer_profile_edit_page.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _mockCases = [
  {
    'id': 'c1',
    'title': 'Divorcio por mutuo acuerdo',
    'type': 'Derecho de Familia',
    'clientName': 'Juan G.',
    'date': '2026-05-27',
    'urgency': 'normal',
    'description':
        'Pareja desea separarse de mutuo acuerdo. Tienen 2 hijos menores. Necesitan acuerdo de custodia y pensión alimenticia.',
  },
  {
    'id': 'c2',
    'title': 'Demanda por despido injustificado',
    'type': 'Derecho Laboral',
    'clientName': 'María L.',
    'date': '2026-05-26',
    'urgency': 'urgent',
    'description':
        'Trabajadora despedida sin causa justificada después de 5 años. Solicita liquidación y daños.',
  },
  {
    'id': 'c3',
    'title': 'Proceso de herencia',
    'type': 'Derecho Civil',
    'clientName': 'Carlos R.',
    'date': '2026-05-25',
    'urgency': 'normal',
    'description': 'Sucesión testamentaria de bienes inmuebles. 3 herederos.',
  },
];

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

  @override
  Widget build(BuildContext context) {
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSizes.md),
            child: CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              radius: 18,
              child: Text(
                'CM',
                style: TextStyle(
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
            _WelcomeCard(),
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

            // ── New requests ──────────────────────────────────────
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
                    '3',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            ..._mockCases.take(2).map((c) => _CaseListTile(
                  caseData: c,
                  showViewButton: true,
                  context: context,
                )),
            const SizedBox(height: AppSizes.lg),

            // ── Active cases ──────────────────────────────────────
            const Text(
              'Casos activos',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyDark),
            ),
            const SizedBox(height: AppSizes.sm),
            const _ActiveCaseTile(
              title: 'Divorcio por mutuo acuerdo',
              client: 'Juan G.',
              status: 'En negociación',
              progress: 0.45,
            ),
            const _ActiveCaseTile(
              title: 'Demanda por despido',
              client: 'María L.',
              status: 'Documentación',
              progress: 0.2,
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
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
          const Text(
            'Buenos días, Dr. Mendoza',
            style: TextStyle(
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
          value: '2',
          icon: Icons.folder_open_outlined,
          iconColor: AppColors.primaryBlue,
        ),
        _StatCard(
          label: 'Casos total',
          value: '5',
          icon: Icons.folder_copy_outlined,
          iconColor: AppColors.secondaryOrange,
        ),
        _StatCard(
          label: 'Rating',
          value: '4.8',
          icon: Icons.star_outline,
          iconColor: AppColors.secondaryOrange,
          suffix: ' ★',
        ),
        _StatCard(
          label: 'Ingresos mes',
          value: 'L. 2,400',
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
  final String suffix;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.suffix = '',
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
                '$value$suffix',
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

class _CaseListTile extends StatelessWidget {
  final Map<String, dynamic> caseData;
  final bool showViewButton;
  final BuildContext context;

  const _CaseListTile({
    required this.caseData,
    required this.showViewButton,
    required this.context,
  });

  @override
  Widget build(BuildContext ctx) {
    final isUrgent = caseData['urgency'] == 'urgent';
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  caseData['title'] as String,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.greyDark),
                ),
              ),
              _UrgencyBadge(isUrgent: isUrgent),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  caseData['type'] as String,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Text(
                'Cliente: ${caseData['clientName']}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.subtitleGrey),
              ),
            ],
          ),
          if (showViewButton) ...[
            const SizedBox(height: AppSizes.sm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AcceptRejectCasePage(caseData: caseData),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: const Text('Ver detalles'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActiveCaseTile extends StatelessWidget {
  final String title;
  final String client;
  final String status;
  final double progress;

  const _ActiveCaseTile({
    required this.title,
    required this.client,
    required this.status,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.greyDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryOrange,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            'Cliente: $client',
            style: const TextStyle(fontSize: 12, color: AppColors.subtitleGrey),
          ),
          const SizedBox(height: AppSizes.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.greyLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% completado',
            style: const TextStyle(fontSize: 11, color: AppColors.subtitleGrey),
          ),
        ],
      ),
    );
  }
}

class _UrgencyBadge extends StatelessWidget {
  final bool isUrgent;
  const _UrgencyBadge({required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.errorRed : AppColors.greyLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isUrgent ? 'Urgente' : 'Normal',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isUrgent ? AppColors.white : AppColors.greyDark,
        ),
      ),
    );
  }
}
