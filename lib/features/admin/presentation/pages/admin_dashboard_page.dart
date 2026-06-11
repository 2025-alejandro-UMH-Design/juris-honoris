import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/admin/data/datasources/admin_local_datasource.dart';
import 'package:juris_honoris/features/admin/presentation/bloc/admin_cubit.dart';
import 'package:juris_honoris/features/admin/presentation/pages/ai_providers_page.dart';
import 'package:juris_honoris/features/admin/presentation/pages/lawyers_verification_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return BlocProvider(
          create: (_) => AdminCubit(
            datasource: AdminLocalDatasource(prefs: snapshot.data!),
          )..loadProviders(),
          child: const _AdminDashboardView(),
        );
      },
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Panel Admin — Juris Honoris',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            tooltip: 'Cerrar sesión admin',
            onPressed: () => _confirmLogout(context),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bienvenida
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.cardPadding),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, Color(0xFF1565C0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSizes.lg),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenido, Admin',
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Panel de control del sistema',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl2),

              // Estadísticas
              const Text(
                'Estadísticas',
                style: TextStyle(
                  color: AppColors.greyDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSizes.cardGap,
                crossAxisSpacing: AppSizes.cardGap,
                childAspectRatio: 1.6,
                children: const [
                  _StatCard(
                    icon: Icons.people,
                    label: 'Usuarios Registrados',
                    value: '0',
                    color: AppColors.primaryBlue,
                  ),
                  _StatCard(
                    icon: Icons.gavel,
                    label: 'Abogados Verificados',
                    value: '0',
                    color: AppColors.successGreen,
                  ),
                  _StatCard(
                    icon: Icons.smart_toy,
                    label: 'Consultas IA Hoy',
                    value: '0',
                    color: AppColors.secondaryOrange,
                  ),
                  _StatCard(
                    icon: Icons.folder_open,
                    label: 'Casos Activos',
                    value: '0',
                    color: Color(0xFF9C27B0),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl2),

              // Configuración
              const Text(
                'Configuración',
                style: TextStyle(
                  color: AppColors.greyDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.md),
              _buildConfigCard(context),
              const SizedBox(height: AppSizes.xl3),

              // Versión
              const Center(
                child: Text(
                  'Juris Honoris v1.0.0',
                  style: TextStyle(
                    color: AppColors.greyMedium,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildConfigTile(
            context,
            icon: Icons.bolt,
            iconColor: AppColors.secondaryOrange,
            title: 'Proveedores de IA',
            subtitle: 'Gestionar APIs de inteligencia artificial',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AdminCubit>(),
                  child: const AIProvidersPage(),
                ),
              ),
            ),
          ),
          _divider(),
          _buildConfigTile(
            context,
            icon: Icons.people,
            iconColor: AppColors.primaryBlue,
            title: 'Usuarios',
            subtitle: 'Ver y gestionar usuarios registrados',
            onTap: () => _showComingSoon(context, 'Gestión de Usuarios'),
          ),
          _divider(),
          _buildConfigTile(
            context,
            icon: Icons.gavel,
            iconColor: AppColors.successGreen,
            title: 'Abogados',
            subtitle: 'Verificar credenciales de abogados',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const LawyersVerificationPage(),
              ),
            ),
          ),
          _divider(),
          _buildConfigTile(
            context,
            icon: Icons.bar_chart,
            iconColor: const Color(0xFF9C27B0),
            title: 'Reportes',
            subtitle: 'Analytics y reportes del sistema',
            onTap: () => _showComingSoon(context, 'Reportes'),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? const BorderRadius.vertical(
              bottom: Radius.circular(AppSizes.cardRadius))
          : BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.sm),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: AppSizes.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.greyDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.greyMedium,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.greyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      color: AppColors.borderColor,
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — Próximamente disponible'),
        backgroundColor: AppColors.greyDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.sm),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas salir del panel de administración?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.greyMedium),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
              ),
            ),
            child: const Text(
              'Salir',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.xs),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.xs),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.greyMedium,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
