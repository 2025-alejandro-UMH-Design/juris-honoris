import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/badge_widget.dart';
import 'tasks_page.dart';

class TaskDetailPage extends StatefulWidget {
  final TaskData task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late List<_Subtask> _subtasks;
  late TextEditingController _notesController;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task.status;
    _notesController = TextEditingController();
    _subtasks = [
      _Subtask(title: 'Reunir documentos de identidad', done: true),
      _Subtask(title: 'Obtener copias certificadas', done: false),
      _Subtask(title: 'Agendar cita con el abogado', done: false),
    ];
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
        title: Text(
          widget.task.title,
          style: const TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.pagePadding,
          AppSizes.lg,
          AppSizes.pagePadding,
          80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección info
            _SectionCard(
              title: 'Información',
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Estado',
                    value: _statusBadge(_currentStatus),
                  ),
                  const Divider(
                      height: AppSizes.xl, color: AppColors.borderColor),
                  _InfoRow(
                    label: 'Prioridad',
                    value: _priorityBadge(widget.task.priority),
                  ),
                  const Divider(
                      height: AppSizes.xl, color: AppColors.borderColor),
                  _InfoRow(
                    label: 'Categoría',
                    value: Text(
                      _categoryLabel(widget.task.category),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.greyDark,
                      ),
                    ),
                  ),
                  const Divider(
                      height: AppSizes.xl, color: AppColors.borderColor),
                  _InfoRow(
                    label: 'Vencimiento',
                    value: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.greyMedium,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.task.dueDate,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.greyDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Descripción
            _SectionCard(
              title: 'Descripción',
              child: Text(
                widget.task.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.subtitleGrey,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Subtareas
            _SectionCard(
              title: 'Subtareas',
              child: Column(
                children: _subtasks.asMap().entries.map((e) {
                  final i = e.key;
                  final sub = e.value;
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: sub.done,
                    onChanged: (v) =>
                        setState(() => _subtasks[i].done = v ?? false),
                    title: Text(
                      sub.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.greyDark,
                        decoration:
                            sub.done ? TextDecoration.lineThrough : null,
                        decorationColor: AppColors.greyMedium,
                      ),
                    ),
                    activeColor: AppColors.successGreen,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Documentos requeridos
            const _SectionCard(
              title: 'Documentos requeridos',
              child: Column(
                children: [
                  _DocItem(name: 'DNI o Pasaporte'),
                  _DocItem(name: 'Partida de nacimiento'),
                  _DocItem(name: 'Constancia de domicilio'),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.lg),

            // Notas
            _SectionCard(
              title: 'Notas',
              child: TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Agregá notas sobre este hito...',
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

            if (_currentStatus != 'completed')
              AppButton(
                label: 'Marcar completado',
                variant: ButtonVariant.success,
                icon: Icons.check_circle_outline_rounded,
                onPressed: _markCompleted,
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.successGreen,
                      size: 20,
                    ),
                    SizedBox(width: AppSizes.sm),
                    Text(
                      'Tarea completada',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _markCompleted() {
    setState(() => _currentStatus = 'completed');
    widget.task.status = 'completed';
    widget.task.checked = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tarea marcada como completada'),
        backgroundColor: AppColors.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _statusBadge(String status) {
    return switch (status) {
      'completed' =>
        const BadgeWidget(label: 'Completado', variant: BadgeVariant.success),
      'in_progress' =>
        const BadgeWidget(label: 'En progreso', variant: BadgeVariant.info),
      _ => const BadgeWidget(label: 'Pendiente', variant: BadgeVariant.gray),
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

  String _categoryLabel(String cat) {
    const map = {
      'family': 'Derecho de Familia',
      'labor': 'Derecho Laboral',
      'criminal': 'Derecho Penal',
      'commercial': 'Derecho Mercantil',
      'other': 'Otro',
    };
    return map[cat] ?? cat;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

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
            child,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final Widget value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.greyMedium),
        ),
        value,
      ],
    );
  }
}

class _DocItem extends StatelessWidget {
  final String name;

  const _DocItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          const Icon(
            Icons.description_outlined,
            size: 18,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: AppSizes.sm),
          Text(
            name,
            style: const TextStyle(fontSize: 14, color: AppColors.greyDark),
          ),
        ],
      ),
    );
  }
}

class _Subtask {
  final String title;
  bool done;

  _Subtask({required this.title, required this.done});
}
