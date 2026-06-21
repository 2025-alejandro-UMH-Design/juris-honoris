import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';
import 'package:juris_honoris/features/tasks/presentation/bloc/cases_cubit.dart';
import 'package:juris_honoris/features/tasks/presentation/pages/task_detail_page.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/recommendations_cubit.dart';
import 'package:juris_honoris/features/ai_chat/presentation/pages/required_docs_page.dart';
import 'package:juris_honoris/injection_container.dart';

class AIResultPage extends StatefulWidget {
  final String consultaSummary;
  final bool needsLawyer;
  final String? specialty;

  const AIResultPage({
    super.key,
    required this.consultaSummary,
    required this.needsLawyer,
    this.specialty,
  });

  @override
  State<AIResultPage> createState() => _AIResultPageState();
}

class _AIResultPageState extends State<AIResultPage> {
  bool _isCreating = false;

  void _openDocGuide() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<RecommendationsCubit>(),
          child: RequiredDocsPage(
            consultaSummary: widget.consultaSummary,
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreateHito() async {
    setState(() => _isCreating = true);

    // Extrae el título de la primera línea no vacía del resumen de la IA
    final rawTitle = widget.consultaSummary
        .replaceAll(RegExp(r'[*#]+'), '')
        .split('\n')
        .map((l) => l.trim())
        .firstWhere((l) => l.isNotEmpty, orElse: () => 'Consulta legal');
    final title =
        rawTitle.length > 50 ? '${rawTitle.substring(0, 47)}...' : rawTitle;

    context.read<CasesCubit>().createCase(
          title: title,
          description: widget.consultaSummary,
          category: 'other',
          priority: 'medium',
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CasesCubit, CasesState>(
      listener: (ctx, state) {
        if (!_isCreating) return;
        if (state is CasesLoaded) {
          setState(() => _isCreating = false);
          final newTask = state.cases.first;
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Hito creado correctamente'),
              backgroundColor: AppColors.successGreen,
            ),
          );
          Navigator.of(ctx).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (_) => sl<RecommendationsCubit>(),
                child: TaskDetailPage(
                  task: newTask,
                  consultaSummary: widget.consultaSummary,
                ),
              ),
            ),
          );
        } else if (state is CasesError) {
          setState(() => _isCreating = false);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.greyDark),
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

                _ResultIcon(needsLawyer: widget.needsLawyer),
                const SizedBox(height: AppSizes.xl2),

                Text(
                  widget.needsLawyer
                      ? 'Se recomienda un abogado'
                      : 'Puedes gestionarlo solo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.greyDark,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.md),

                Text(
                  widget.needsLawyer
                      ? 'Basado en tu consulta, este caso requiere representación legal profesional.'
                      : 'Este trámite puede realizarse de forma independiente.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.subtitleGrey,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.xl),

                _ResultBadge(needsLawyer: widget.needsLawyer),
                const SizedBox(height: AppSizes.xl3),

                if (widget.consultaSummary.isNotEmpty) ...[
                  _SummaryCard(summary: widget.consultaSummary),
                  const SizedBox(height: AppSizes.xl3),
                ],

                // Botón primario
                AppButton(
                  label: widget.needsLawyer
                      ? 'Solicitar un Abogado'
                      : 'Crear hito de seguimiento',
                  icon: widget.needsLawyer
                      ? Icons.gavel
                      : Icons.flag_outlined,
                  variant: ButtonVariant.primary,
                  isLoading: _isCreating,
                  onPressed: widget.needsLawyer
                      ? () => context.go('/lawyers',
                            extra: {'specialty': widget.specialty})
                      : _handleCreateHito,
                ),
                const SizedBox(height: AppSizes.md),

                // Botón secundario
                AppButton(
                  label: widget.needsLawyer
                      ? 'Ver directorio de abogados'
                      : 'Ver guía de documentos',
                  icon: widget.needsLawyer
                      ? Icons.people_outline
                      : Icons.folder_open_outlined,
                  variant: ButtonVariant.secondary,
                  onPressed: widget.needsLawyer
                      ? () => context.go('/lawyers',
                            extra: {'specialty': widget.specialty})
                      : _openDocGuide,
                ),
                const SizedBox(height: AppSizes.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultIcon extends StatelessWidget {
  final bool needsLawyer;
  const _ResultIcon({required this.needsLawyer});

  @override
  Widget build(BuildContext context) {
    final color =
        needsLawyer ? AppColors.errorRed : AppColors.successGreen;
    final icon =
        needsLawyer ? Icons.gavel : Icons.check_circle_outline;

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 52),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final bool needsLawyer;
  const _ResultBadge({required this.needsLawyer});

  @override
  Widget build(BuildContext context) {
    final color =
        needsLawyer ? AppColors.errorRed : AppColors.successGreen;
    final label =
        needsLawyer ? 'Caso complejo' : 'Trámite autogestionable';
    final icon = needsLawyer
        ? Icons.warning_amber_rounded
        : Icons.eco_outlined;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
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
            color: AppColors.greyDark.withValues(alpha: 0.04),
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
