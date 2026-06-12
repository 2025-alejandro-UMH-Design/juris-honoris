import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/badge_widget.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';
import '../../../tasks/presentation/pages/task_detail_page.dart';
import '../../../tasks/presentation/pages/create_task_page.dart';
import '../../../tasks/presentation/bloc/cases_cubit.dart';

class DossierPage extends StatefulWidget {
  final int currentNavIndex;
  final void Function(int) onNavChanged;

  const DossierPage({
    super.key,
    this.currentNavIndex = 3,
    required this.onNavChanged,
  });

  @override
  State<DossierPage> createState() => _DossierPageState();
}

class _DossierPageState extends State<DossierPage> {
  String _filter = 'Todos';
  List<TaskData> _items = const [];

  final _filters = ['Todos', 'Activos', 'Completados', 'Pendientes'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CasesCubit>().loadCases();
    });
  }

  List<TaskData> get _filtered {
    return switch (_filter) {
      'Activos' => _items.where((t) => t.status == 'in_progress').toList(),
      'Completados' => _items.where((t) => t.status == 'completed').toList(),
      'Pendientes' => _items.where((t) => t.status == 'pending').toList(),
      _ => _items,
    };
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return BlocListener<CasesCubit, CasesState>(
      listener: (_, state) {
        if (state is CasesLoaded) setState(() => _items = state.cases);
      },
      child: Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mi Dossier Legal',
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
      body: Column(
        children: [
          _FilterChips(
            filters: _filters,
            selected: _filter,
            onSelect: (v) => setState(() => _filter = v),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyDossier(onCrear: _goCreate)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.pagePadding,
                      AppSizes.sm,
                      AppSizes.pagePadding,
                      80,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _TaskCard(
                      task: filtered[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailPage(task: filtered[i]),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goCreate,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Nuevo hito',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.currentNavIndex,
        onTabChanged: widget.onNavChanged,
      ),
    ),
    );
  }

  void _goCreate() async {
    final newTask = await Navigator.push<TaskData>(
      context,
      MaterialPageRoute(builder: (_) => const CreateTaskPage()),
    );
    if (newTask != null && mounted) {
      context.read<CasesCubit>().createCase(
        title: newTask.title,
        description: newTask.description,
        category: newTask.category,
        priority: newTask.priority,
        dueDate: newTask.dueDate.isNotEmpty ? newTask.dueDate : null,
      );
    }
  }
}

class _FilterChips extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final void Function(String) onSelect;

  const _FilterChips({
    required this.filters,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.pagePadding,
        vertical: AppSizes.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = f == selected;
            return GestureDetector(
              onTap: () => onSelect(f),
              child: Container(
                margin: const EdgeInsets.only(right: AppSizes.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : AppColors.greyVeryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBlue : AppColors.borderColor,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? AppColors.white : AppColors.greyMedium,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskData task;
  final VoidCallback onTap;

  const _TaskCard({required this.task, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.cardGap),
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyDark,
                      ),
                    ),
                  ),
                  _statusBadge(task.status),
                ],
              ),
              const SizedBox(height: AppSizes.xs),
              Text(
                task.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.subtitleGrey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  _categoryBadge(task.category),
                  const SizedBox(width: AppSizes.xs),
                  _priorityBadge(task.priority),
                  const Spacer(),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 12,
                    color: AppColors.greyMedium,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    task.dueDate,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.greyMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return switch (status) {
      'completed' =>
        const BadgeWidget(label: 'Completado', variant: BadgeVariant.success),
      'in_progress' =>
        const BadgeWidget(label: 'Activo', variant: BadgeVariant.info),
      _ =>
        const BadgeWidget(label: 'Pendiente', variant: BadgeVariant.gray),
    };
  }

  Widget _priorityBadge(String priority) {
    return switch (priority) {
      'high' => const BadgeWidget(label: 'Alta', variant: BadgeVariant.danger),
      'medium' =>
        const BadgeWidget(label: 'Media', variant: BadgeVariant.warning),
      _ => const BadgeWidget(label: 'Baja', variant: BadgeVariant.gray),
    };
  }

  Widget _categoryBadge(String cat) {
    const labels = {
      'family': 'Familia',
      'labor': 'Laboral',
      'criminal': 'Penal',
      'commercial': 'Mercantil',
      'other': 'Otro',
    };
    return BadgeWidget(
      label: labels[cat] ?? cat,
      variant: BadgeVariant.gray,
    );
  }
}

class _EmptyDossier extends StatelessWidget {
  final VoidCallback onCrear;

  const _EmptyDossier({required this.onCrear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.folder_special_outlined,
            size: 64,
            color: AppColors.greyLight,
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Sin expedientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'Tu dossier está vacío. Crea tu primer hito.',
            style: TextStyle(fontSize: 14, color: AppColors.greyMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.xl),
          TextButton.icon(
            onPressed: onCrear,
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryBlue),
            label: const Text(
              'Crear hito',
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
