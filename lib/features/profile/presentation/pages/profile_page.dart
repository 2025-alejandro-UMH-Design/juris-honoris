import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/domain/entities/user_entity.dart';
import 'upgrade_page.dart';
import 'verify_identity_page.dart';

class ProfilePage extends StatelessWidget {
  final int currentNavIndex;
  final void Function(int) onNavChanged;

  const ProfilePage({
    super.key,
    this.currentNavIndex = 0,
    required this.onNavChanged,
  });

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthCubit>().currentUser;
    final userName = user?.name ?? user?.email.split('@').first ?? 'Usuario';
    final userEmail = user?.email ?? '';
    final isPremium = user?.plan == UserPlan.premium;
    final isVerified = user?.isVerified ?? false;
    final dni = user?.dni;
    final phone = user?.phone;
    final solicitationsUsed = user?.solicitationsThisMonth ?? 0;

    final parts = userName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : parts[0][0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.xl,
          AppSizes.pagePadding,
          80,
        ),
        child: Column(
          children: [
            // Avatar y datos principales
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.greyMedium,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  _PlanBadge(isPremium: isPremium),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.xl2),

            // Mis datos
            _SectionCard(
              title: 'Mis datos',
              children: [
                _DataRow(
                  icon: Icons.badge_outlined,
                  label: 'DNI',
                  value: dni ?? '',
                  isEmpty: dni == null || dni.isEmpty,
                  onComplete: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VerifyIdentityPage(),
                    ),
                  ),
                ),
                const Divider(
                    height: AppSizes.xl, color: AppColors.borderColor),
                _DataRow(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  value: phone ?? '',
                  isEmpty: phone == null || phone.isEmpty,
                  onComplete: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VerifyIdentityPage(),
                    ),
                  ),
                ),
                const Divider(
                    height: AppSizes.xl, color: AppColors.borderColor),
                _DataRow(
                  icon: Icons.email_outlined,
                  label: 'Correo',
                  value: userEmail,
                  isVerified: isVerified,
                ),
              ],
            ),

            const SizedBox(height: AppSizes.lg),

            // Mi suscripción
            _SectionCard(
              title: 'Mi suscripción',
              children: isPremium
                  ? [
                      const Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: AppColors.secondaryOrange,
                            size: 20,
                          ),
                          SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Plan Premium activo',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.greyDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.md),
                      _OutlineButton(
                        label: 'Gestionar suscripción',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Próximamente'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                    ]
                  : [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Plan Gratuito',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.greyDark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$solicitationsUsed de 3 solicitudes usadas este mes',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.greyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: solicitationsUsed / 3,
                          backgroundColor: AppColors.greyLight,
                          color: AppColors.primaryBlue,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UpgradePage(),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSizes.md,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primaryBlue,
                                AppColors.primaryBlueDark,
                              ],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppSizes.buttonRadius),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 18,
                              ),
                              SizedBox(width: AppSizes.sm),
                              Text(
                                'Actualizar a Premium',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
            ),

            const SizedBox(height: AppSizes.lg),

            // Configuración
            _SectionCard(
              title: 'Configuración',
              children: [
                _SettingRow(
                  icon: Icons.notifications_outlined,
                  label: 'Notificaciones',
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.borderColor),
                _SettingRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Privacidad',
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.borderColor),
                _SettingRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Ayuda',
                  onTap: () {},
                ),
                const Divider(height: 1, color: AppColors.borderColor),
                _SettingRow(
                  icon: Icons.description_outlined,
                  label: 'Términos y condiciones',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: AppSizes.xl2),

            // Cerrar sesión
            GestureDetector(
              onTap: () => _confirmLogout(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                  border: Border.all(
                    color: AppColors.errorRed.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color: AppColors.errorRed,
                      size: 20,
                    ),
                    SizedBox(width: AppSizes.sm),
                    Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.errorRed,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: currentNavIndex,
        onTabChanged: onNavChanged,
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        title: const Text(
          'Cerrar sesión',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          '¿Estás seguro/a de que querés cerrar sesión?',
          style: TextStyle(color: AppColors.subtitleGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.greyMedium),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await context.read<AuthCubit>().logout();
            },
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(
                color: AppColors.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final bool isPremium;

  const _PlanBadge({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 4),
      decoration: BoxDecoration(
        color: isPremium
            ? AppColors.primaryBlue.withValues(alpha: 0.12)
            : AppColors.secondaryOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.star_rounded : Icons.person_outline_rounded,
            size: 14,
            color:
                isPremium ? AppColors.primaryBlue : AppColors.secondaryOrange,
          ),
          const SizedBox(width: 4),
          Text(
            isPremium ? 'Premium' : 'Gratuito',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color:
                  isPremium ? AppColors.primaryBlue : AppColors.secondaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEmpty;
  final bool isVerified;
  final VoidCallback? onComplete;

  const _DataRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isEmpty = false,
    this.isVerified = false,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.greyMedium),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.greyMedium,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isEmpty ? 'No registrado' : value,
                style: TextStyle(
                  fontSize: 14,
                  color: isEmpty ? AppColors.greyMedium : AppColors.greyDark,
                  fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
        if (isVerified)
          const Row(
            children: [
              Icon(
                Icons.verified_rounded,
                size: 16,
                color: AppColors.successGreen,
              ),
              SizedBox(width: 4),
              Text(
                'Verificado',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.successGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          )
        else if (isEmpty && onComplete != null)
          TextButton(
            onPressed: onComplete,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.primaryBlue,
            ),
            child: const Text(
              'Completar',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.greyMedium),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.greyDark,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.greyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          border: Border.all(color: AppColors.primaryBlue),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue,
          ),
        ),
      ),
    );
  }
}
