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
                  onTap: () => _showNotificationsSheet(context),
                ),
                const Divider(height: 1, color: AppColors.borderColor),
                _SettingRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Privacidad',
                  onTap: () => _showPrivacySheet(context),
                ),
                const Divider(height: 1, color: AppColors.borderColor),
                _SettingRow(
                  icon: Icons.help_outline_rounded,
                  label: 'Ayuda',
                  onTap: () => _showHelpSheet(context),
                ),
                const Divider(height: 1, color: AppColors.borderColor),
                _SettingRow(
                  icon: Icons.description_outlined,
                  label: 'Términos y condiciones',
                  onTap: () => _showTermsSheet(context),
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

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _NotificationsSheet(),
    );
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _InfoSheet(
        title: 'Política de Privacidad',
        icon: Icons.lock_outline_rounded,
        sections: [
          _InfoSection(
            heading: 'Datos que recopilamos',
            body:
                'Recopilamos tu nombre, correo electrónico, DNI y teléfono para identificarte dentro de la plataforma. Esta información nunca es vendida a terceros.',
          ),
          _InfoSection(
            heading: 'Uso de la información',
            body:
                'Usamos tus datos para conectarte con abogados verificados, personalizar las recomendaciones de la IA y enviarte notificaciones relacionadas con tus casos.',
          ),
          _InfoSection(
            heading: 'Seguridad',
            body:
                'Tu información se almacena cifrada. Las contraseñas nunca se guardan en texto plano. Las claves de IA operan exclusivamente en nuestros servidores.',
          ),
          _InfoSection(
            heading: 'Contacto',
            body:
                'Para ejercer tus derechos ARCO (Acceso, Rectificación, Cancelación u Oposición), escríbenos a privacidad@jurishonoris.hn.',
          ),
        ],
      ),
    );
  }

  void _showHelpSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _InfoSheet(
        title: 'Ayuda',
        icon: Icons.help_outline_rounded,
        sections: [
          _InfoSection(
            heading: '¿Cómo consulto con la IA legal?',
            body:
                'Ve a la pestaña "Chat IA" en la barra inferior y escribe tu consulta jurídica. La IA analizará tu situación y, si es necesario, te recomendará un abogado.',
          ),
          _InfoSection(
            heading: '¿Cómo solicito un abogado?',
            body:
                'Accede al Directorio de Abogados, selecciona un perfil y presiona "Solicitar Servicio". Con el Plan Gratuito puedes enviar hasta 3 solicitudes por mes.',
          ),
          _InfoSection(
            heading: '¿Qué son los hitos?',
            body:
                'Los hitos son tareas o casos legales que puedes crear para hacer seguimiento de tus trámites. Puedes marcar actividades completadas y añadir notas.',
          ),
          _InfoSection(
            heading: 'Soporte técnico',
            body:
                'Si tienes problemas técnicos, escríbenos a soporte@jurishonoris.hn o al WhatsApp +504 9999-0000. Atendemos de lunes a viernes de 8 a.m. a 5 p.m.',
          ),
        ],
      ),
    );
  }

  void _showTermsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _InfoSheet(
        title: 'Términos y Condiciones',
        icon: Icons.description_outlined,
        sections: [
          _InfoSection(
            heading: '1. Uso del servicio',
            body:
                'Juris Honoris es una plataforma de orientación legal en Honduras. No sustituye el consejo de un abogado colegiado. La IA proporciona información general, no asesoramiento legal vinculante.',
          ),
          _InfoSection(
            heading: '2. Responsabilidades del usuario',
            body:
                'El usuario es responsable de la veracidad de la información proporcionada y del uso adecuado de la plataforma. Está prohibido el uso para fines ilícitos.',
          ),
          _InfoSection(
            heading: '3. Relación con abogados',
            body:
                'Juris Honoris actúa como intermediario entre clientes y abogados. No garantiza resultados legales. Los honorarios y acuerdos son directamente entre el cliente y el abogado.',
          ),
          _InfoSection(
            heading: '4. Modificaciones',
            body:
                'Nos reservamos el derecho de modificar estos términos. Los cambios serán notificados con al menos 15 días de anticipación mediante la aplicación.',
          ),
          _InfoSection(
            heading: '5. Jurisdicción',
            body:
                'Estos términos se rigen por las leyes de la República de Honduras. Cualquier controversia se resolverá ante los tribunales competentes de Tegucigalpa, M.D.C.',
          ),
        ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Sheet de notificaciones
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationsSheet extends StatefulWidget {
  const _NotificationsSheet();

  @override
  State<_NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<_NotificationsSheet> {
  bool _mensajes = true;
  bool _solicitudes = true;
  bool _actualizaciones = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.pagePadding, AppSizes.xl, AppSizes.pagePadding, AppSizes.xl2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          const Text(
            'Notificaciones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.greyDark),
          ),
          const SizedBox(height: AppSizes.lg),
          _SwitchRow(
            label: 'Nuevos mensajes',
            subtitle: 'Cuando un abogado te escribe',
            value: _mensajes,
            onChanged: (v) => setState(() => _mensajes = v),
          ),
          const Divider(height: AppSizes.xl, color: AppColors.borderColor),
          _SwitchRow(
            label: 'Solicitudes',
            subtitle: 'Respuestas a tus solicitudes de servicio',
            value: _solicitudes,
            onChanged: (v) => setState(() => _solicitudes = v),
          ),
          const Divider(height: AppSizes.xl, color: AppColors.borderColor),
          _SwitchRow(
            label: 'Actualizaciones de la app',
            subtitle: 'Novedades y mejoras de Juris Honoris',
            value: _actualizaciones,
            onChanged: (v) => setState(() => _actualizaciones = v),
          ),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            width: double.infinity,
            height: AppSizes.buttonHeight,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.buttonRadius)),
              ),
              child: const Text('Guardar preferencias', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.greyDark)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.greyMedium)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primaryBlue,
          activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet genérico de información (Privacidad, Ayuda, Términos)
// ─────────────────────────────────────────────────────────────────────────────

class _InfoSection {
  final String heading;
  final String body;
  const _InfoSection({required this.heading, required this.body});
}

class _InfoSheet extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<_InfoSection> sections;

  const _InfoSheet({
    required this.title,
    required this.icon,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSizes.pagePadding, 0, AppSizes.pagePadding, AppSizes.md),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryBlue, size: 22),
                const SizedBox(width: AppSizes.sm),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.greyDark),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderColor),
          Expanded(
            child: ListView.separated(
              controller: controller,
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              itemCount: sections.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.lg),
              itemBuilder: (_, i) {
                final s = sections[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.heading,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.greyDark),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Text(
                      s.body,
                      style: const TextStyle(fontSize: 13, color: AppColors.subtitleGrey, height: 1.5),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
