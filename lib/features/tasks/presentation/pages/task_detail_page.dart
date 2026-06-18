import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/recommendations_cubit.dart';
import 'package:juris_honoris/features/tasks/presentation/bloc/cases_cubit.dart';
import 'tasks_page.dart';

class TaskDetailPage extends StatefulWidget {
  final TaskData task;
  final String? consultaSummary;

  const TaskDetailPage({
    super.key,
    required this.task,
    this.consultaSummary,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  List<bool> _checked = [];
  List<bool> _expanded = [];
  late TextEditingController _notesController;

  String get _effectiveSummary =>
      widget.consultaSummary ?? widget.task.description;

  int get _checkedCount => _checked.where((v) => v).length;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.task.notes);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<RecommendationsCubit>()
          .loadRecommendations(_effectiveSummary);
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _openMaps(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveProgress() async {
    final cubit = context.read<CasesCubit>();
    final notes = _notesController.text.trim();
    final saved = await cubit.saveNotes(widget.task.id, notes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saved ? 'Progreso guardado correctamente' : 'Error al guardar, intenta de nuevo'),
        backgroundColor: saved ? AppColors.successGreen : AppColors.errorRed,
        duration: const Duration(seconds: 2),
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
          'Detalle del Hito',
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
      body: BlocConsumer<RecommendationsCubit, RecommendationsState>(
        listener: (context, state) {
          if (state is RecommendationsLoaded) {
            setState(() {
              _checked = List<bool>.filled(state.docs.length, false);
              _expanded = List<bool>.filled(state.docs.length, false);
            });
          }
        },
        builder: (context, state) {
          final docs = state is RecommendationsLoaded ? state.docs : [];
          final isLoading = state is RecommendationsLoading ||
              state is RecommendationsInitial;

          // Ajustar listas si aun no se sincronizaron
          if (_checked.length != docs.length) {
            _checked = List<bool>.filled(docs.length, false);
            _expanded = List<bool>.filled(docs.length, false);
          }

          final totalDocs = docs.length;
          final checkedCount = _checkedCount;
          final progress =
              totalDocs == 0 ? 0.0 : checkedCount / totalDocs;

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
                      // Encabezado: icono carpeta + titulo + descripcion
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSizes.cardPadding),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppSizes.cardRadius),
                          border:
                              Border.all(color: AppColors.borderColor),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0D000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.folder_outlined,
                                color: AppColors.primaryBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSizes.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.task.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.greyDark,
                                    ),
                                  ),
                                  const SizedBox(height: AppSizes.xs),
                                  Text(
                                    widget.task.description,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.subtitleGrey,
                                      height: 1.4,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.lg),

                      // Barra de progreso
                      Row(
                        children: [
                          const Text(
                            'Progreso',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.greyDark,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$checkedCount/$totalDocs Completado',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.greyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor:
                              AppColors.greyLight.withValues(alpha: 0.4),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBlue),
                        ),
                      ),

                      const SizedBox(height: AppSizes.xl),

                      // Seccion Actividades
                      const Text(
                        'Actividades',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyDark,
                        ),
                      ),
                      const SizedBox(height: AppSizes.md),

                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSizes.xl),
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      else if (state is RecommendationsError)
                        _ErrorBanner(
                          message: state.message,
                          onRetry: () => context
                              .read<RecommendationsCubit>()
                              .loadRecommendations(_effectiveSummary),
                        )
                      else if (docs.isEmpty)
                        const _EmptyActivities()
                      else
                        ...docs.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final doc = entry.value;
                          return _ActivityCard(
                            doc: doc,
                            isChecked: _checked.length > idx
                                ? _checked[idx]
                                : false,
                            isExpanded: _expanded.length > idx
                                ? _expanded[idx]
                                : false,
                            onCheck: (val) {
                              setState(() => _checked[idx] = val ?? false);
                            },
                            onToggleExpand: () {
                              setState(
                                  () => _expanded[idx] = !_expanded[idx]);
                            },
                            onOpenMaps: () => _openMaps(doc.mapsQuery),
                          );
                        }),

                      const SizedBox(height: AppSizes.xl),

                      // Notas adicionales
                      const Text(
                        'Notas adicionales',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.greyDark,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius:
                              BorderRadius.circular(AppSizes.cardRadius),
                          border:
                              Border.all(color: AppColors.borderColor),
                        ),
                        padding: const EdgeInsets.all(AppSizes.md),
                        child: TextFormField(
                          controller: _notesController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Añadir comentarios...',
                            hintStyle: TextStyle(
                              color: AppColors.hintGrey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.greyDark,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSizes.xl2),
                    ],
                  ),
                ),
              ),

              // Boton "Guardar progreso"
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
                      onPressed: _saveProgress,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text(
                        'Guardar progreso',
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
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tarjeta de actividad expandible
// ─────────────────────────────────────────────────────────────────────────────

class _ActivityCard extends StatelessWidget {
  final RequiredDoc doc;
  final bool isChecked;
  final bool isExpanded;
  final void Function(bool?) onCheck;
  final VoidCallback onToggleExpand;
  final VoidCallback onOpenMaps;

  const _ActivityCard({
    required this.doc,
    required this.isChecked,
    required this.isExpanded,
    required this.onCheck,
    required this.onToggleExpand,
    required this.onOpenMaps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Fila principal: checkbox + texto + chevron
            InkWell(
              onTap: onToggleExpand,
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.sm,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: onCheck,
                      activeColor: AppColors.successGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isChecked
                                    ? AppColors.greyLight
                                    : AppColors.greyDark,
                                decoration: isChecked
                                    ? TextDecoration.lineThrough
                                    : null,
                                decorationColor: AppColors.greyLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              doc.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: isChecked
                                    ? AppColors.greyLight
                                    : AppColors.subtitleGrey,
                              ),
                              maxLines: isExpanded ? null : 2,
                              overflow: isExpanded
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.greyMedium,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido expandido
            if (isExpanded) ...[
              const Divider(height: 1, color: AppColors.borderColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.lg,
                  AppSizes.sm,
                  AppSizes.lg,
                  AppSizes.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Institucion y direccion
                    if (doc.institution.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.business_outlined,
                            size: 14,
                            color: AppColors.greyMedium,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Expanded(
                            child: Text(
                              doc.institution,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.greyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.xs),
                    ],
                    if (doc.address.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.greyMedium,
                          ),
                          const SizedBox(width: AppSizes.xs),
                          Expanded(
                            child: Text(
                              doc.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.greyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.sm),
                    ],

                    // Enlace a Google Maps
                    if (doc.mapsQuery.isNotEmpty)
                      GestureDetector(
                        onTap: onOpenMaps,
                        child: const Row(
                          children: [
                            Icon(
                              Icons.map_outlined,
                              size: 14,
                              color: AppColors.primaryBlue,
                            ),
                            SizedBox(width: AppSizes.xs),
                            Text(
                              'Ver ubicacion en Google Maps',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Nota de advertencia
                    if (doc.note.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: AppSizes.xs,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AppColors.warningAmber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.warningAmber
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              size: 14,
                              color: AppColors.warningAmber,
                            ),
                            const SizedBox(width: AppSizes.xs),
                            Expanded(
                              child: Text(
                                'Nota importante: ${doc.note}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.warningAmber,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSizes.xs),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets de estado
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyActivities extends StatelessWidget {
  const _EmptyActivities();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.xl),
        child: Column(
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 40,
              color: AppColors.greyLight,
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'No se encontraron actividades',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.hintGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border:
            Border.all(color: AppColors.errorRed.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.errorRed,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.sm),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Reintentar',
              style: TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}
