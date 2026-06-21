import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/api_config.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/shared/widgets/app_card.dart';

import 'accept_reject_case_page.dart';
import 'lawyer_chat_list_page.dart';
import 'lawyer_marketplace_page.dart';
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
      LawyerChatListPage(),
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

class _DashboardHome extends StatefulWidget {
  const _DashboardHome();

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  List<Map<String, dynamic>> _pending = [];
  int _totalCases = 0;
  double _rating = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dio = sl<Dio>();
      final results = await Future.wait([
        dio.get(ApiConfig.requests, queryParameters: {'status': 'pending'}),
        dio.get('${ApiConfig.lawyers}/me/profile'),
      ]);
      if (!mounted) return;
      setState(() {
        _pending = List<Map<String, dynamic>>.from(results[0].data as List);
        final profile = results[1].data as Map<String, dynamic>;
        _totalCases = (profile['total_cases'] as num?)?.toInt() ?? 0;
        _rating = (profile['rating'] as num?)?.toDouble() ?? 0;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
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
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeCard(name: displayName),
              const SizedBox(height: AppSizes.lg),

              const Text(
                'Resumen',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark),
              ),
              const SizedBox(height: AppSizes.sm),
              _isLoading
                  ? const SizedBox(
                      height: 120,
                      child: Center(child: CircularProgressIndicator()))
                  : _StatsGrid(
                      pendingCount: _pending.length,
                      totalCases: _totalCases,
                      rating: _rating,
                    ),
              const SizedBox(height: AppSizes.lg),

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
                      color: _pending.isEmpty
                          ? AppColors.greyLight
                          : AppColors.errorRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_pending.length}',
                      style: TextStyle(
                          color: _pending.isEmpty
                              ? AppColors.greyDark
                              : AppColors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              if (_isLoading)
                const _EmptySection(
                    icon: Icons.inbox_outlined,
                    message: 'Cargando solicitudes...')
              else if (_pending.isEmpty)
                const _EmptySection(
                  icon: Icons.inbox_outlined,
                  message: 'No tienes solicitudes pendientes',
                )
              else
                ..._pending.take(3).map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.sm),
                      child: _PendingRequestCard(data: r),
                    )),
              const SizedBox(height: AppSizes.lg),

              const Text(
                'Estadísticas',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark),
              ),
              const SizedBox(height: AppSizes.sm),
              _EmptySection(
                icon: Icons.folder_open_outlined,
                message: _totalCases == 0
                    ? 'Sin casos registrados aún'
                    : 'Total: $_totalCases casos',
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PendingRequestCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isUrgent = data['urgency'] == 'urgent';
    final mapped = {
      'id': data['id'],
      'title': (data['case_title'] as String?)?.isNotEmpty == true
          ? data['case_title']
          : data['case_type'] ?? 'Solicitud',
      'type': data['case_type'] ?? '',
      'clientName': data['client_name'] ?? 'Cliente',
      'date': (data['created_at'] as String? ?? '').length >= 10
          ? (data['created_at'] as String).substring(0, 10)
          : '',
      'urgency': data['urgency'] ?? 'normal',
      'description': data['description'] ?? '',
    };
    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AcceptRejectCasePage(caseData: mapped),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mapped['title'] as String,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Cliente: ${mapped['clientName']}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.subtitleGrey),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          if (isUrgent)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.errorRed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Urgente',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.white,
                      fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: AppSizes.sm),
          const Icon(Icons.arrow_forward_ios,
              size: 14, color: AppColors.primaryBlue),
        ],
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
  final int pendingCount;
  final int totalCases;
  final double rating;

  const _StatsGrid({
    required this.pendingCount,
    required this.totalCases,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSizes.sm,
      mainAxisSpacing: AppSizes.sm,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          label: 'Solicitudes',
          value: '$pendingCount',
          icon: Icons.inbox_outlined,
          iconColor: AppColors.primaryBlue,
        ),
        _StatCard(
          label: 'Casos total',
          value: '$totalCases',
          icon: Icons.folder_copy_outlined,
          iconColor: AppColors.secondaryOrange,
        ),
        _StatCard(
          label: 'Rating',
          value: rating > 0 ? rating.toStringAsFixed(1) : '-',
          icon: Icons.star_outline,
          iconColor: AppColors.secondaryOrange,
        ),
        const _StatCard(
          label: 'Ingresos mes',
          value: 'N/A',
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
