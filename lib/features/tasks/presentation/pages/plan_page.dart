import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/recommendations_cubit.dart';
import 'package:juris_honoris/injection_container.dart';
import '../bloc/plan_cubit.dart';
import 'task_detail_page.dart';
import 'tasks_page.dart';

class PlanPage extends StatefulWidget {
  final String consultaSummary;

  const PlanPage({super.key, required this.consultaSummary});

  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlanCubit>().loadPlan(widget.consultaSummary);
    });
  }

  void _openStep(BuildContext context, PlanStep step, String planTitle) {
    final taskData = TaskData(
      id: '',
      title: step.title,
      description: step.description,
      status: step.status,
      category: 'other',
      priority: 'medium',
      dueDate: '',
    );
    final effectiveSummary =
        '$planTitle — ${step.title}: ${widget.consultaSummary}';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<RecommendationsCubit>(),
          child: TaskDetailPage(
            task: taskData,
            consultaSummary: effectiveSummary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Plan de Accion',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: BlocBuilder<PlanCubit, PlanState>(
        builder: (context, state) {
          if (state is PlanLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryBlue),
                  SizedBox(height: AppSizes.md),
                  Text(
                    'Generando tu plan de accion...',
                    style: TextStyle(
                      color: AppColors.greyMedium,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is PlanError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.pagePadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.errorRed,
                      size: 48,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.greyDark,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xl),
                    ElevatedButton(
                      onPressed: () => context
                          .read<PlanCubit>()
                          .loadPlan(widget.consultaSummary),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSizes.buttonRadius),
                        ),
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is PlanLoaded) {
            final plan = state.plan;
            final progressPct =
                (plan.progress * 100).toStringAsFixed(0);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.pagePadding,
                      AppSizes.lg,
                      AppSizes.pagePadding,
                      AppSizes.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titulo del plan
                        Text(
                          'Tu plan: ${plan.title}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.greyDark,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xs),
                        Text(
                          '${plan.steps.length} pasos para completar',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.greyMedium,
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),

                        // Barra de progreso
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: plan.progress,
                                  minHeight: 8,
                                  backgroundColor:
                                      AppColors.greyLight.withValues(alpha: 0.4),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryBlue),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Text(
                              '$progressPct% Completado',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.xl2),

                        // Lista de pasos con linea vertical conectora
                        ...plan.steps.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final step = entry.value;
                          final isLast = idx == plan.steps.length - 1;
                          return _PlanStepItem(
                            step: step,
                            isLast: isLast,
                            onTap: () =>
                                _openStep(context, step, plan.title),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // Boton "Ver dossier"
                Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.pagePadding,
                    AppSizes.sm,
                    AppSizes.pagePadding,
                    AppSizes.lg,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      top: BorderSide(color: AppColors.borderColor),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: () => context.go('/dossier'),
                        icon: const Icon(Icons.folder_outlined, size: 18),
                        label: const Text(
                          'Ver dossier',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSizes.buttonRadius),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Item de paso con linea vertical conectora
// ─────────────────────────────────────────────────────────────────────────────

class _PlanStepItem extends StatelessWidget {
  final PlanStep step;
  final bool isLast;
  final VoidCallback onTap;

  const _PlanStepItem({
    required this.step,
    required this.isLast,
    required this.onTap,
  });

  Color get _circleColor {
    switch (step.status) {
      case 'completed':
        return AppColors.successGreen;
      case 'in_progress':
        return AppColors.primaryBlue;
      default:
        return AppColors.greyLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = step.status == 'completed';
    final isInProgress = step.status == 'in_progress';
    final isPending = step.status == 'pending';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Columna izquierda: circulo + linea vertical
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Circulo de estado
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _circleColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppColors.white,
                            size: 18,
                          )
                        : Text(
                            '${step.order}',
                            style: TextStyle(
                              color: isPending
                                  ? AppColors.greyDark
                                  : AppColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
                // Linea vertical conectora (excepto el ultimo)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.borderColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),

          // Tarjeta del paso
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSizes.md),
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.circular(AppSizes.cardRadius),
                    border: Border.all(
                      color: isInProgress
                          ? AppColors.primaryBlue
                          : AppColors.borderColor,
                      width: isInProgress ? 1.5 : 1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isPending
                                    ? AppColors.greyMedium
                                    : AppColors.greyDark,
                              ),
                            ),
                          ),
                          if (isCompleted)
                            const _StatusBadge(
                              label: 'Completado',
                              color: AppColors.successGreen,
                            )
                          else if (isInProgress)
                            const _StatusBadge(
                              label: 'En Tramite',
                              color: AppColors.primaryBlue,
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        step.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: isPending
                              ? AppColors.greyLight
                              : AppColors.subtitleGrey,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
