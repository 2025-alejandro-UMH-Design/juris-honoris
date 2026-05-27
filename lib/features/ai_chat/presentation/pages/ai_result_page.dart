import 'package:flutter/material.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';

/// Pantalla de resultado de consulta.
///
/// Muestra si el caso requiere un abogado ([needsLawyer]=true)
/// o si el usuario puede gestionarlo de forma independiente ([needsLawyer]=false).
class AIResultPage extends StatelessWidget {
  final String consultaSummary;
  final bool needsLawyer;

  const AIResultPage({
    super.key,
    required this.consultaSummary,
    required this.needsLawyer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.greyDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Resultado del análisis',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.greyDark,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSizes.xl3),

              // ── Main icon ─────────────────────────────────────────
              _ResultIcon(needsLawyer: needsLawyer),
              const SizedBox(height: AppSizes.xl2),

              // ── Title ─────────────────────────────────────────────
              Text(
                needsLawyer
                    ? 'Se recomienda un abogado'
                    : 'Puedes gestionarlo solo',
                style:
                    Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.greyDark,
                          fontWeight: FontWeight.bold,
                        ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.md),

              // ── Description ───────────────────────────────────────
              Text(
                needsLawyer
                    ? 'Basado en tu consulta, este caso requiere representación legal profesional.'
                    : 'Este trámite puede realizarse de forma independiente.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.subtitleGrey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.xl),

              // ── Badge ─────────────────────────────────────────────
              _ResultBadge(needsLawyer: needsLawyer),
              const SizedBox(height: AppSizes.xl3),

              // ── Summary card ──────────────────────────────────────
              if (consultaSummary.isNotEmpty) ...[
                _SummaryCard(summary: consultaSummary),
                const SizedBox(height: AppSizes.xl3),
              ],

              // ── Primary action ────────────────────────────────────
              AppButton(
                label: needsLawyer
                    ? 'Solicitar un Abogado'
                    : 'Crear hito de seguimiento',
                icon: needsLawyer ? Icons.gavel : Icons.flag_outlined,
                variant: ButtonVariant.primary,
                onPressed: () {
                  // TODO: navegar a la pantalla correspondiente
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        needsLawyer
                            ? 'Próximamente: directorio de abogados'
                            : 'Próximamente: gestión de hitos',
                      ),
                      backgroundColor: AppColors.primaryBlue,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.md),

              // ── Secondary action ──────────────────────────────────
              AppButton(
                label: needsLawyer
                    ? 'Ver directorio de abogados'
                    : 'Ver guía de documentos',
                icon: needsLawyer
                    ? Icons.people_outline
                    : Icons.folder_open_outlined,
                variant: ButtonVariant.secondary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        needsLawyer
                            ? 'Próximamente: directorio de abogados'
                            : 'Próximamente: guía de documentos',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Widgets locales
// ─────────────────────────────────────────────────────────────────────────────

class _ResultIcon extends StatelessWidget {
  final bool needsLawyer;

  const _ResultIcon({required this.needsLawyer});

  @override
  Widget build(BuildContext context) {
    final color = needsLawyer ? AppColors.errorRed : AppColors.successGreen;
    final icon = needsLawyer ? Icons.gavel : Icons.check_circle_outline;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 52,
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final bool needsLawyer;

  const _ResultBadge({required this.needsLawyer});

  @override
  Widget build(BuildContext context) {
    final color = needsLawyer ? AppColors.errorRed : AppColors.successGreen;
    final label = needsLawyer ? 'Caso complejo' : 'Trámite autogestionable';
    final icon = needsLawyer ? Icons.warning_amber_rounded : Icons.eco_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSizes.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyDark.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Consulta analizada',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.greyMedium,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: AppSizes.sm),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.greyDark,
                  height: 1.5,
                ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
