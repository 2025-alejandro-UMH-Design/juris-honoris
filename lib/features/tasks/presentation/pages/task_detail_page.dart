import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/badge_widget.dart';
import '../bloc/documents_cubit.dart';
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
  final _picker = ImagePicker();

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.task.id.isNotEmpty) {
        context.read<DocumentsCubit>().loadDocuments(widget.task.id);
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ── Upload ──────────────────────────────────────────────────────

  void _showUploadSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSizes.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.md),
            const Text(
              'Agregar documento',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.camera_alt_outlined, color: AppColors.primaryBlue),
              ),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.photo_library_outlined, color: AppColors.successGreen),
              ),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(Icons.picture_as_pdf_outlined, color: Color(0xFFE65100)),
              ),
              title: const Text('Seleccionar PDF'),
              onTap: () {
                Navigator.pop(context);
                _pickPdf();
              },
            ),
            const SizedBox(height: AppSizes.md),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (file == null || !mounted) return;
    await _upload(file.path, 'image/jpeg', file.name);
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final f = result.files.first;
    if (f.path == null) return;
    await _upload(f.path!, 'application/pdf', f.name);
  }

  Future<void> _upload(String path, String mime, String name) async {
    await context.read<DocumentsCubit>().uploadDocument(
          caseId: widget.task.id,
          filePath: path,
          mimeType: mime,
          fileName: name,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Documento subido correctamente'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  Future<void> _openDocument(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmDelete(DocumentData doc) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar documento'),
        content: Text('¿Eliminar "${doc.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.errorRed)),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<DocumentsCubit>().deleteDocument(
              caseId: widget.task.id,
              docId: doc.id,
            );
      }
    });
  }

  // ── Build ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentsCubit, DocumentsState>(
      listener: (context, state) {
        if (state is DocumentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
      child: Scaffold(
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
              _SectionCard(
                title: 'Información',
                child: Column(
                  children: [
                    _InfoRow(label: 'Estado', value: _statusBadge(_currentStatus)),
                    const Divider(height: AppSizes.xl, color: AppColors.borderColor),
                    _InfoRow(label: 'Prioridad', value: _priorityBadge(widget.task.priority)),
                    const Divider(height: AppSizes.xl, color: AppColors.borderColor),
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
                    const Divider(height: AppSizes.xl, color: AppColors.borderColor),
                    _InfoRow(
                      label: 'Vencimiento',
                      value: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 14, color: AppColors.greyMedium),
                          const SizedBox(width: 4),
                          Text(widget.task.dueDate,
                              style: const TextStyle(
                                  fontSize: 14, color: AppColors.greyDark)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.lg),

              _SectionCard(
                title: 'Descripción',
                child: Text(
                  widget.task.description,
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.subtitleGrey, height: 1.5),
                ),
              ),

              const SizedBox(height: AppSizes.lg),

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

              // ── Documentos del caso ───────────────────────────
              _DocsSection(
                caseId: widget.task.id,
                onUpload: _showUploadSheet,
                onOpen: _openDocument,
                onDelete: _confirmDelete,
              ),

              const SizedBox(height: AppSizes.lg),

              _SectionCard(
                title: 'Notas',
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Agregá notas sobre este hito...',
                    hintStyle:
                        TextStyle(color: AppColors.hintGrey, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                      fontSize: 14, color: AppColors.greyDark, height: 1.5),
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
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSizes.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius:
                        BorderRadius.circular(AppSizes.buttonRadius),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.successGreen, size: 20),
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

  Widget _statusBadge(String status) => switch (status) {
        'completed' =>
          const BadgeWidget(label: 'Completado', variant: BadgeVariant.success),
        'in_progress' =>
          const BadgeWidget(label: 'En progreso', variant: BadgeVariant.info),
        _ =>
          const BadgeWidget(label: 'Pendiente', variant: BadgeVariant.gray),
      };

  Widget _priorityBadge(String priority) => switch (priority) {
        'high' =>
          const BadgeWidget(label: 'Alta', variant: BadgeVariant.danger),
        'medium' =>
          const BadgeWidget(label: 'Media', variant: BadgeVariant.warning),
        _ => const BadgeWidget(label: 'Baja', variant: BadgeVariant.gray),
      };

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

// ─────────────────────────────────────────────────────────────────────────────
// Sección de documentos reales
// ─────────────────────────────────────────────────────────────────────────────

class _DocsSection extends StatelessWidget {
  final String caseId;
  final VoidCallback onUpload;
  final Future<void> Function(String url) onOpen;
  final void Function(DocumentData doc) onDelete;

  const _DocsSection({
    required this.caseId,
    required this.onUpload,
    required this.onOpen,
    required this.onDelete,
  });

  String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentsCubit, DocumentsState>(
      builder: (context, state) {
        final docs = switch (state) {
          DocumentsLoaded() => state.docs,
          DocumentsUploading() => state.docs,
          _ => <DocumentData>[],
        };
        final isUploading = state is DocumentsUploading;
        final isLoading =
            state is DocumentsLoading || state is DocumentsInitial;

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
                  offset: Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Documentos del caso',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyDark,
                      ),
                    ),
                    if (!isUploading)
                      GestureDetector(
                        onTap: onUpload,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.sm, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add,
                                  size: 14, color: AppColors.primaryBlue),
                              SizedBox(width: 3),
                              Text(
                                'Agregar',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),

                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSizes.md),
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primaryBlue),
                    ),
                  )
                else if (docs.isEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSizes.md),
                    child: Column(
                      children: [
                        Icon(Icons.folder_open_outlined,
                            size: 36,
                            color: AppColors.greyMedium
                                .withValues(alpha: 0.5)),
                        const SizedBox(height: AppSizes.sm),
                        const Text(
                          'Sin documentos aún',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.hintGrey),
                        ),
                      ],
                    ),
                  )
                else
                  ...docs.map((doc) => _DocTile(
                        doc: doc,
                        fmtSize: _fmtSize,
                        onOpen: onOpen,
                        onDelete: onDelete,
                      )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DocTile extends StatelessWidget {
  final DocumentData doc;
  final String Function(int) fmtSize;
  final Future<void> Function(String url) onOpen;
  final void Function(DocumentData doc) onDelete;

  const _DocTile({
    required this.doc,
    required this.fmtSize,
    required this.onOpen,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md, vertical: 4),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: doc.isImage
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              doc.isImage
                  ? Icons.image_outlined
                  : Icons.picture_as_pdf_outlined,
              size: 20,
              color: doc.isImage
                  ? AppColors.primaryBlue
                  : const Color(0xFFE65100),
            ),
          ),
          title: Text(
            doc.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            fmtSize(doc.fileSizeBytes),
            style: const TextStyle(
                fontSize: 11, color: AppColors.greyMedium),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.open_in_new_rounded,
                    size: 18, color: AppColors.primaryBlue),
                tooltip: 'Abrir',
                onPressed: () => onOpen(doc.filePath),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.errorRed),
                tooltip: 'Eliminar',
                onPressed: () => onDelete(doc),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets comunes
// ─────────────────────────────────────────────────────────────────────────────

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
              color: Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2)),
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
        Text(label,
            style: const TextStyle(
                fontSize: 14, color: AppColors.greyMedium)),
        value,
      ],
    );
  }
}

class _Subtask {
  final String title;
  bool done;

  _Subtask({required this.title, required this.done});
}
