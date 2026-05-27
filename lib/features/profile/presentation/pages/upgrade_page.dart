import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

class UpgradePage extends StatelessWidget {
  const UpgradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
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
                    colors: [AppColors.primaryBlueDark, Color(0xFF1565C0)],
                  ),
                ),
                child: const SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: AppSizes.xl2),
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 48,
                      ),
                      SizedBox(height: AppSizes.sm),
                      Text(
                        'Juris Honoris Premium',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Acceso ilimitado a todos los servicios',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xCCFFFFFF),
                        ),
                      ),
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
                children: [
                  // Tabla comparativa
                  _ComparisonTable(),

                  const SizedBox(height: AppSizes.xl2),

                  // Botón mensual
                  _PriceButton(
                    label: 'Mensual',
                    price: 'L. 99',
                    subtitle: 'por mes',
                    isPrimary: false,
                    onTap: () => _showComingSoon(context),
                  ),

                  const SizedBox(height: AppSizes.md),

                  // Botón anual (destacado)
                  _PriceButton(
                    label: 'Anual',
                    price: 'L. 990',
                    subtitle: 'por año · Ahorra 10%',
                    isPrimary: true,
                    badge: 'MEJOR VALOR',
                    onTap: () => _showComingSoon(context),
                  ),

                  const SizedBox(height: AppSizes.lg),

                  // Nota demo
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.greyVeryLight,
                      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.greyMedium,
                        ),
                        SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            'Modo demo — no se realizará ningún cobro.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
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

  void _showComingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        title: const Row(
          children: [
            Icon(Icons.rocket_launch_rounded, color: AppColors.primaryBlue),
            SizedBox(width: AppSizes.sm),
            Text(
              'Próximamente',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Próximamente: integración con pasarela de pago para activar tu suscripción.',
          style: TextStyle(
            color: AppColors.subtitleGrey,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const features = [
      _Feature('Solicitudes al mes', '3', 'Ilimitadas'),
      _Feature('Chat con IA', true, true),
      _Feature('Hitos ilimitados', true, true),
      _Feature('Historial permanente', false, true),
      _Feature('Prioridad en respuestas', false, true),
      _Feature('Soporte prioritario', false, true),
    ];

    return Container(
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
        children: [
          // Encabezado
          Container(
            decoration: const BoxDecoration(
              color: AppColors.greyVeryLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSizes.cardRadius),
                topRight: Radius.circular(AppSizes.cardRadius),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.md),
                    child: Text(
                      'Características',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyMedium,
                      ),
                    ),
                  ),
                ),
                _HeaderCell(
                  label: 'GRATUITO',
                  subtitle: 'L. 0',
                  isPrimary: false,
                ),
                _HeaderCell(
                  label: 'PREMIUM',
                  subtitle: 'L. 99/mes',
                  isPrimary: true,
                ),
              ],
            ),
          ),
          // Filas
          ...features.asMap().entries.map((e) {
            final i = e.key;
            final f = e.value;
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.borderColor),
                ),
                color: i.isOdd ? AppColors.greyVeryLight.withOpacity(0.5) : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Text(
                        f.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.greyDark,
                        ),
                      ),
                    ),
                  ),
                  _ValueCell(value: f.free),
                  _ValueCell(value: f.premium, isPrimary: true),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Feature {
  final String name;
  final Object free;
  final Object premium;

  const _Feature(this.name, this.free, this.premium);
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isPrimary;

  const _HeaderCell({
    required this.label,
    required this.subtitle,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.md,
          horizontal: AppSizes.sm,
        ),
        decoration: isPrimary
            ? const BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppSizes.cardRadius),
                ),
              )
            : null,
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isPrimary ? AppColors.white : AppColors.greyMedium,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isPrimary
                    ? AppColors.white.withOpacity(0.85)
                    : AppColors.greyMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  final Object value;
  final bool isPrimary;

  const _ValueCell({required this.value, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (value is bool) {
      final v = value as bool;
      content = Icon(
        v ? Icons.check_rounded : Icons.close_rounded,
        size: 18,
        color: v
            ? (isPrimary ? AppColors.successGreen : AppColors.greyMedium)
            : AppColors.greyLight,
      );
    } else {
      content = Text(
        value.toString(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isPrimary ? AppColors.primaryBlue : AppColors.greyDark,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
        alignment: Alignment.center,
        child: content,
      ),
    );
  }
}

class _PriceButton extends StatelessWidget {
  final String label;
  final String price;
  final String subtitle;
  final bool isPrimary;
  final String? badge;
  final VoidCallback onTap;

  const _PriceButton({
    required this.label,
    required this.price,
    required this.subtitle,
    required this.isPrimary,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryBlue : AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
          border: Border.all(
            color: isPrimary ? AppColors.primaryBlue : AppColors.borderColor,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isPrimary ? AppColors.white : AppColors.greyDark,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: AppSizes.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greyDark,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isPrimary
                          ? AppColors.white.withOpacity(0.8)
                          : AppColors.greyMedium,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isPrimary ? AppColors.white : AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
