import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input_field.dart';
import 'tasks_page.dart';

class CreateTaskPage extends StatefulWidget {
  final String? initialTitle;
  final String? initialDescription;

  const CreateTaskPage({
    super.key,
    this.initialTitle,
    this.initialDescription,
  });

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _category = 'Familia';
  String _priority = 'Media';
  DateTime? _dueDate;

  final _categories = ['Familia', 'Laboral', 'Penal', 'Mercantil', 'Otro'];
  final _priorities = ['Baja', 'Media', 'Alta'];

  @override
  void initState() {
    super.initState();
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialDescription != null) {
      _descController.text = widget.initialDescription!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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
        title: const Text(
          'Nuevo Hito',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppInputField(
                controller: _titleController,
                label: 'Nombre del hito',
                hintText: 'Ej. Consulta sobre divorcio',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'El nombre es obligatorio' : null,
              ),

              const SizedBox(height: AppSizes.lg),

              AppInputField(
                controller: _descController,
                label: 'Descripción',
                hintText: 'Describe los detalles del hito...',
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'La descripción es obligatoria' : null,
              ),

              const SizedBox(height: AppSizes.xl),

              // Categoría
              const Text(
                'Categoría',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyDark,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  border: Border.all(color: AppColors.borderColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _category,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.greyMedium),
                    style: const TextStyle(fontSize: 14, color: AppColors.greyDark),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.xl),

              // Prioridad
              const Text(
                'Prioridad',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyDark,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: _priorities.map((p) {
                  final isSelected = p == _priority;
                  return GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: Container(
                      margin: const EdgeInsets.only(right: AppSizes.sm),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.lg,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _priorityColor(p)
                            : AppColors.greyVeryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? _priorityColor(p)
                              : AppColors.borderColor,
                        ),
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.greyMedium,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSizes.xl),

              // Fecha
              const Text(
                'Fecha de vencimiento',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyDark,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.md,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: AppSizes.iconSize,
                        color: AppColors.greyMedium,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        _dueDate != null
                            ? '${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year}'
                            : 'Seleccionar fecha',
                        style: TextStyle(
                          fontSize: 14,
                          color: _dueDate != null
                              ? AppColors.greyDark
                              : AppColors.greyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.xl3),

              AppButton(
                label: 'Guardar hito',
                icon: Icons.save_rounded,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(String p) {
    return switch (p) {
      'Alta' => AppColors.errorRed,
      'Media' => AppColors.secondaryOrange,
      _ => AppColors.greyMedium,
    };
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primaryBlue,
            onSurface: AppColors.greyDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una fecha de vencimiento'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    final newTask = TaskData(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      status: 'pending',
      category: _categoryKey(_category),
      priority: _priorityKey(_priority),
      dueDate:
          '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}',
    );

    Navigator.of(context).pop(newTask);
  }

  String _categoryKey(String label) {
    const map = {
      'Familia': 'family',
      'Laboral': 'labor',
      'Penal': 'criminal',
      'Mercantil': 'commercial',
      'Otro': 'other',
    };
    return map[label] ?? 'other';
  }

  String _priorityKey(String label) {
    const map = {'Alta': 'high', 'Media': 'medium', 'Baja': 'low'};
    return map[label] ?? 'medium';
  }
}
