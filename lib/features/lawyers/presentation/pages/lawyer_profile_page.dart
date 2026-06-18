import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../home/presentation/widgets/lawyer_card.dart';
import '../bloc/lawyers_cubit.dart';
import 'lawyer_request_page.dart';
import 'package:juris_honoris/injection_container.dart';

class LawyerProfilePage extends StatelessWidget {
  final LawyerData lawyer;

  // En demo, el usuario siempre está verificado
  final bool isUserVerified;

  const LawyerProfilePage({
    super.key,
    required this.lawyer,
    this.isUserVerified = true,
  });

  @override
  Widget build(BuildContext context) {
    final specialties = _specialtiesFor(lawyer.specialization);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.primaryBlueDark,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.white,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primaryBlueDark, AppColors.primaryBlue],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSizes.xl2),
                      // Avatar hero
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          lawyer.initials,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Text(
                        lawyer.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (lawyer.verified) ...[
                        const SizedBox(height: 4),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                fontSize: 13,
                                color: AppColors.successGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info principal
                  _InfoCard(
                    children: [
                      _InfoRow(
                        icon: Icons.gavel_rounded,
                        label: lawyer.specialization,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        label: lawyer.city,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Row(
                        children: [
                          _StarRating(rating: lawyer.rating),
                          const SizedBox(width: AppSizes.sm),
                          Text(
                            '${lawyer.rating} · ${lawyer.cases} casos',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.greyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Sobre mí
                  _Section(
                    title: 'Sobre mí',
                    child: Text(
                      lawyer.about,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.subtitleGrey,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Especialidades
                  _Section(
                    title: 'Especialidades',
                    child: Wrap(
                      spacing: AppSizes.sm,
                      runSpacing: AppSizes.sm,
                      children: specialties.map((s) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.xs,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Tarifas
                  const _Section(
                    title: 'Tarifas',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TarifaRow(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Consulta inicial',
                          value: 'Gratuita',
                          valueColor: AppColors.successGreen,
                        ),
                        SizedBox(height: AppSizes.sm),
                        _TarifaRow(
                          icon: Icons.work_outline_rounded,
                          label: 'Honorarios',
                          value: 'Según caso',
                          valueColor: AppColors.greyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSizes.xl2),

                  // Botones
                  if (isUserVerified) ...[
                    AppButton(
                      label: 'Solicitar Servicio',
                      icon: Icons.send_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) => sl<LawyersCubit>(),
                            child: LawyerRequestPage(lawyer: lawyer),
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    AppButton(
                      label: 'Completa tu perfil',
                      icon: Icons.person_outline_rounded,
                      onPressed: () {},
                    ),
                  ],

                  const SizedBox(height: AppSizes.md),

                  AppButton(
                    label: 'Enviar mensaje',
                    variant: ButtonVariant.secondary,
                    icon: Icons.message_outlined,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Función de mensajería próximamente'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _specialtiesFor(String spec) {
    const map = {
      'Derecho de Familia': [
        'Divorcio',
        'Custodia de menores',
        'Pensión alimenticia',
        'Adopción',
        'Violencia doméstica',
      ],
      'Derecho Laboral': [
        'Despidos injustificados',
        'Indemnizaciones',
        'Contratos laborales',
        'Seguridad social',
      ],
      'Derecho Penal': [
        'Defensa criminal',
        'Amparo',
        'Habeas corpus',
        'Delitos económicos',
      ],
      'Derecho Mercantil': [
        'Contratos',
        'Sociedades mercantiles',
        'Derecho comercial',
        'Marcas y patentes',
      ],
    };
    return map[spec] ?? [spec];
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.cardPadding),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.cardPadding),
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
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryBlue),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.greyDark),
          ),
        ),
      ],
    );
  }
}

class _TarifaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _TarifaRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.greyMedium),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: AppColors.greyDark),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(
            Icons.star_rounded,
            size: 16,
            color: AppColors.secondaryOrange,
          );
        } else if (i < rating) {
          return const Icon(
            Icons.star_half_rounded,
            size: 16,
            color: AppColors.secondaryOrange,
          );
        } else {
          return const Icon(
            Icons.star_outline_rounded,
            size: 16,
            color: AppColors.greyLight,
          );
        }
      }),
    );
  }
}
