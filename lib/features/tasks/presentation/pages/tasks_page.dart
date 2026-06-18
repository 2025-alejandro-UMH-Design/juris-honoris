import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/recommendations_cubit.dart';
import 'package:juris_honoris/injection_container.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/badge_widget.dart';
import '../bloc/cases_cubit.dart';
import 'task_detail_page.dart';
import 'create_task_page.dart';

/// Modelo local de tarea (mock).
class TaskData {
  final String id;
  final String title;
  final String description;
  String status; // pending | in_progress | completed
  final String category;
  final String priority;
  final String dueDate;
  bool checked;
  String notes;

  TaskData({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.priority,
    required this.dueDate,
    this.checked = false,
    this.notes = '',
  });

  factory TaskData.fromJson(Map<String, dynamic> j) {
    return TaskData(
      id: j['id']?.toString() ?? '',
      title: j['title']?.toString() ?? '',
      description: j['description']?.toString() ?? '',
      status: j['status']?.toString() ?? 'pending',
      category: j['category']?.toString() ?? 'other',
      priority: j['priority']?.toString() ?? 'medium',
      dueDate: j['due_date']?.toString() ?? j['dueDate']?.toString() ?? '',
      checked: j['status'] == 'completed',
      notes: j['notes']?.toString() ?? '',
    );
  }
}

/// Datos mock globales de tareas.
final mockTasks = [
  TaskData(
    id: 't1',
    title: 'Consulta divorcio',
    description: 'Reunir documentos para proceso de divorcio',
    status: 'in_progress',
    category: 'family',
    priority: 'high',
    dueDate: '2026-06-15',
  ),
  TaskData(
    id: 't2',
    title: 'Herencia proceso',
    description: 'Trámite sucesoral bienes inmuebles',
    status: 'pending',
    category: 'other',
    priority: 'medium',
    dueDate: '2026-07-01',
  ),
  TaskData(
    id: 't3',
    title: 'Contrato revisión',
    description: 'Revisar contrato de arrendamiento',
    status: 'completed',
    category: 'commercial',
    priority: 'low',
    dueDate: '2026-05-20',
    checked: true,
  ),
];

class TasksPage extends StatefulWidget {
  final int currentNavIndex;
  final void Function(int) onNavChanged;

  const TasksPage({
    super.key,
    this.currentNavIndex = 2,
    required this.onNavChanged,
  });

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _filterCategory = 'Todos';
  String _filterPriority = 'Todas';
  late List<TaskData> _tasks;

  final _categories = ['Todos', 'Familia', 'Laboral', 'Penal', 'Mercantil', 'Otro'];
  final _priorities = ['Todas', 'Alta', 'Media', 'Baja'];

  @override
  void initState() {
    super.initState();
    _tasks = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CasesCubit>().loadCases();
    });
  }

  List<TaskData> get _filtered {
    return _tasks.where((t) {
      final catMatch = _filterCategory == 'Todos' ||
          _categoryMatch(t.category, _filterCategory);
      final priMatch = _filterPriority == 'Todas' ||
          _priorityMatch(t.priority, _filterPriority);
      return catMatch && priMatch;
    }).toList();
  }

  bool _categoryMatch(String cat, String filter) {
    const map = {
      'Familia': 'family',
      'Laboral': 'labor',
      'Penal': 'criminal',
      'Mercantil': 'commercial',
      'Otro': 'other',
    };
    return cat == (map[filter] ?? '');
  }

  bool _priorityMatch(String pri, String filter) {
    const map = {'Alta': 'high', 'Media': 'medium', 'Baja': 'low'};
    return pri == (map[filter] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return BlocListener<CasesCubit, CasesState>(
      listener: (context, state) {
        if (state is CasesLoaded) setState(() => _tasks = state.cases);
      },
      child: Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mis Tareas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: AppColors.greyMedium),
            onPressed: _showFilterSheet,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: Column(
        children: [
          _FilterRow(
            categories: _categories,
            selected: _filterCategory,
            onSelect: (v) => setState(() => _filterCategory = v),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyTasks(onCrear: _goCreate)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.pagePadding,
                      AppSizes.sm,
                      AppSizes.pagePadding,
                      80,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final task = filtered[i];
                      return _TaskListItem(
                        task: task,
                        onCheck: (v) {
                          final newStatus = (v ?? false) ? 'completed' : 'pending';
                          setState(() {
                            task.checked = v ?? false;
                            task.status = newStatus;
                          });
                          context.read<CasesCubit>().updateStatus(task.id, newStatus);
                        },
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider(create: (_) => sl<RecommendationsCubit>()),
                                BlocProvider(create: (_) => sl<CasesCubit>()),
                              ],
                              child: TaskDetailPage(task: task),
                            ),
                          ),
                        ),
                      );
                    },
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
          'Nueva tarea',
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
      await context.read<CasesCubit>().createCase(
        title: newTask.title,
        description: newTask.description,
        category: newTask.category,
        priority: newTask.priority,
        dueDate: newTask.dueDate.isNotEmpty ? newTask.dueDate : null,
      );
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _FilterSheet(
        selectedPriority: _filterPriority,
        priorities: _priorities,
        onSelectPriority: (v) {
          setState(() => _filterPriority = v);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final void Function(String) onSelect;

  const _FilterRow({
    required this.categories,
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
          children: categories.map((cat) {
            final isSelected = cat == selected;
            return GestureDetector(
              onTap: () => onSelect(cat),
              child: Container(
                margin: const EdgeInsets.only(right: AppSizes.sm),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: AppSizes.xs,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryBlue
                      : AppColors.greyVeryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryBlue
                        : AppColors.borderColor,
                  ),
                ),
                child: Text(
                  cat,
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

class _TaskListItem extends StatelessWidget {
  final TaskData task;
  final void Function(bool?) onCheck;
  final VoidCallback onTap;

  const _TaskListItem({
    required this.task,
    required this.onCheck,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.checked || task.status == 'completed';
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
          child: Row(
            children: [
              Checkbox(
                value: isCompleted,
                onChanged: onCheck,
                activeColor: AppColors.successGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyDark,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.greyMedium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      task.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.greyMedium,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.greyLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _statusBadge(task.status),
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
        const BadgeWidget(label: 'En progreso', variant: BadgeVariant.info),
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
}

class _EmptyTasks extends StatelessWidget {
  final VoidCallback onCrear;

  const _EmptyTasks({required this.onCrear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.task_alt_rounded,
            size: 64,
            color: AppColors.greyLight,
          ),
          const SizedBox(height: AppSizes.md),
          const Text(
            'Sin tareas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          const Text(
            'No tenés tareas para este filtro.',
            style: TextStyle(fontSize: 14, color: AppColors.greyMedium),
          ),
          const SizedBox(height: AppSizes.xl),
          TextButton.icon(
            onPressed: onCrear,
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryBlue),
            label: const Text(
              'Crear tarea',
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

class _FilterSheet extends StatelessWidget {
  final List<String> priorities;
  final String selectedPriority;
  final void Function(String) onSelectPriority;

  const _FilterSheet({
    required this.priorities,
    required this.selectedPriority,
    required this.onSelectPriority,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por prioridad',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Wrap(
            spacing: AppSizes.sm,
            children: priorities.map((p) {
              final sel = p == selectedPriority;
              return ChoiceChip(
                label: Text(p),
                selected: sel,
                onSelected: (_) => onSelectPriority(p),
                selectedColor: AppColors.primaryBlue,
                labelStyle: TextStyle(
                  color: sel ? AppColors.white : AppColors.greyDark,
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSizes.lg),
        ],
      ),
    );
  }
}
