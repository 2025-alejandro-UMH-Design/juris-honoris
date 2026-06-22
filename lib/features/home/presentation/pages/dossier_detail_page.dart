import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/api_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/badge_widget.dart';
import '../../../tasks/presentation/pages/tasks_page.dart';

// ─── Modelo de documento ────────────────────────────────────────────────────

class _Doc {
  final String id, name, filePath, fileType, uploadedByName;
  final int fileSizeBytes;
  final DateTime createdAt;

  _Doc({
    required this.id,
    required this.name,
    required this.filePath,
    required this.fileType,
    required this.fileSizeBytes,
    required this.uploadedByName,
    required this.createdAt,
  });

  factory _Doc.fromJson(Map<String, dynamic> j) => _Doc(
        id: j['id']?.toString() ?? '',
        name: j['name'] as String? ?? 'Documento',
        filePath: j['file_path'] as String? ?? '',
        fileType: j['file_type'] as String? ?? '',
        fileSizeBytes: (j['file_size_bytes'] as num?)?.toInt() ?? 0,
        uploadedByName: j['uploaded_by_name'] as String? ?? '',
        createdAt:
            DateTime.tryParse(j['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  bool get isImage => fileType.startsWith('image/');

  String get sizeLabel {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─── Página principal ────────────────────────────────────────────────────────

class DossierDetailPage extends StatefulWidget {
  final TaskData task;

  const DossierDetailPage({super.key, required this.task});

  @override
  State<DossierDetailPage> createState() => _DossierDetailPageState();
}

class _DossierDetailPageState extends State<DossierDetailPage> {
  List<_Doc> _docs = [];
  bool _loadingDocs = true;
  bool _uploadingDoc = false;

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    setState(() => _loadingDocs = true);
    try {
      final res =
          await sl<Dio>().get('${ApiConfig.cases}/${widget.task.id}/documents');
      setState(() {
        _docs = (res.data as List)
            .map((j) => _Doc.fromJson(j as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {}
    if (mounted) setState(() => _loadingDocs = false);
  }

  Future<void> _uploadDoc() async {
    // Selector de tipo de archivo
    final type = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('¿Qué deseas subir?',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined, color: AppColors.primaryBlue),
              title: const Text('Imagen (cámara o galería)'),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.errorRed),
              title: const Text('Documento (PDF, Word, etc.)'),
              onTap: () => Navigator.pop(context, 'doc'),
            ),
          ],
        ),
      ),
    );
    if (type == null || !mounted) return;

    Uint8List? bytes;
    String fileName = 'archivo';
    String mime = 'application/octet-stream';

    if (type == 'image') {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tomar foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Elegir de galería'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (source == null || !mounted) return;
      final img = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (img == null) return;
      bytes = await img.readAsBytes();
      fileName = img.name;
      mime = img.name.endsWith('.png') ? 'image/png' : 'image/jpeg';
    } else {
      // Documento: usa FileType.any para máxima compatibilidad Android
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;
      final f = result.files.first;
      // Intenta bytes primero, luego lee desde path si es null
      bytes = f.bytes;
      if (bytes == null && f.path != null) {
        bytes = await File(f.path!).readAsBytes();
      }
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo leer el archivo. Intenta con otro.'),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
        return;
      }
      fileName = f.name;
      mime = _mimeFor(f.extension ?? 'pdf');
    }

    setState(() => _uploadingDoc = true);
    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName,
            contentType: DioMediaType.parse(mime)),
        'name': fileName,
      });
      await sl<Dio>().post(
          '${ApiConfig.cases}/${widget.task.id}/documents', data: form);
      await _loadDocs();
    } catch (e) {
      if (mounted) {
        final msg = (e is DioException)
            ? (e.response?.data?['error']?.toString() ??
                'Error ${e.response?.statusCode ?? "de red"}')
            : e.toString().split('\n').first;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al subir: $msg'),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }
    if (mounted) setState(() => _uploadingDoc = false);
  }

  String _mimeFor(String ext) => switch (ext.toLowerCase()) {
        'pdf' => 'application/pdf',
        'doc' => 'application/msword',
        'docx' =>
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'png' => 'image/png',
        'webp' => 'image/webp',
        _ => 'image/jpeg',
      };

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _deleteDoc(String docId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar documento'),
        content: const Text('¿Seguro que deseas eliminar este documento?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar',
                  style: TextStyle(color: AppColors.errorRed))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await sl<Dio>()
          .delete('${ApiConfig.cases}/${widget.task.id}/documents/$docId');
      await _loadDocs();
    } catch (_) {}
  }

  Future<void> _shareWhatsApp() async {
    final task = widget.task;
    final statusLabel = switch (task.status) {
      'completed' => 'Completado ✅',
      'in_progress' => 'En progreso 🔄',
      _ => 'Pendiente ⏳',
    };
    final categoryLabel = switch (task.category) {
      'family' => 'Familia',
      'labor' => 'Laboral',
      'criminal' => 'Penal',
      'commercial' => 'Mercantil',
      _ => 'Otro',
    };
    final dateStr = task.dueDate.isNotEmpty ? '\n📅 Fecha límite: ${task.dueDate}' : '';
    final notes =
        task.notes.isNotEmpty ? '\n📝 Notas: ${task.notes}' : '';
    final docLines = _docs.isEmpty
        ? ''
        : '\n\n📁 Documentos adjuntos:\n${_docs.map((d) => '  • ${d.name}').join('\n')}';

    final text = Uri.encodeComponent(
      '🗂️ *Expediente Legal - Juris Honoris*\n\n'
      '📋 *${task.title}*\n'
      '🏷️ Área: $categoryLabel\n'
      '📊 Estado: $statusLabel$dateStr$notes$docLines\n\n'
      '──────────────────\n'
      'Compartido desde Juris Honoris',
    );

    final uri = Uri.parse('https://wa.me/?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryBlue, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Expediente',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark),
        ),
        actions: [
          IconButton(
            tooltip: 'Compartir por WhatsApp',
            icon: const Icon(Icons.share_rounded, color: AppColors.primaryBlue),
            onPressed: _shareWhatsApp,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDocs,
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding, AppSizes.lg, AppSizes.pagePadding, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────────────
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.folder_special_rounded,
                              color: AppColors.primaryBlue, size: 24),
                        ),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.title,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.greyDark)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  _statusBadge(task.status),
                                  const SizedBox(width: 6),
                                  _categoryBadge(task.category),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.md),
                      const Divider(height: 1, color: AppColors.borderColor),
                      const SizedBox(height: AppSizes.md),
                      Text(task.description,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.subtitleGrey,
                              height: 1.55)),
                    ],
                  ],
                ),
              ),

              // ── Metadatos ────────────────────────────────────────────────
              const SizedBox(height: AppSizes.md),
              _SectionCard(
                child: Column(
                  children: [
                    _MetaRow(
                      icon: Icons.flag_outlined,
                      label: 'Prioridad',
                      value: _priorityLabel(task.priority),
                      valueColor: _priorityColor(task.priority),
                    ),
                    if (task.dueDate.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.sm),
                      _MetaRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Fecha límite',
                        value: task.dueDate,
                      ),
                    ],
                  ],
                ),
              ),

              // ── Notas del proceso ────────────────────────────────────────
              if (task.notes.isNotEmpty) ...[
                const SizedBox(height: AppSizes.md),
                const _SectionTitle(title: 'Notas del proceso'),
                const SizedBox(height: AppSizes.sm),
                _SectionCard(
                  child: Text(task.notes,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.subtitleGrey,
                          height: 1.55)),
                ),
              ],

              // ── Documentos ───────────────────────────────────────────────
              const SizedBox(height: AppSizes.md),
              Row(
                children: [
                  const Expanded(child: _SectionTitle(title: 'Documentos')),
                  TextButton.icon(
                    onPressed: _uploadingDoc ? null : _uploadDoc,
                    icon: _uploadingDoc
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primaryBlue))
                        : const Icon(Icons.upload_file_outlined,
                            size: 16, color: AppColors.primaryBlue),
                    label: Text(
                      _uploadingDoc ? 'Subiendo...' : 'Subir',
                      style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sm),
              if (_loadingDocs)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.xl),
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue, strokeWidth: 2),
                  ),
                )
              else if (_docs.isEmpty)
                _SectionCard(
                  child: Column(
                    children: [
                      Icon(Icons.folder_open_rounded,
                          size: 40,
                          color: AppColors.greyLight.withValues(alpha: 0.8)),
                      const SizedBox(height: AppSizes.sm),
                      const Text('Sin documentos adjuntos',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.greyMedium)),
                      const SizedBox(height: AppSizes.xs),
                      const Text(
                          'Sube documentos relacionados a este proceso.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: AppColors.hintGrey)),
                    ],
                  ),
                )
              else
                ..._docs.map((doc) => _DocCard(
                      doc: doc,
                      onOpen: () => _openFile(doc.filePath),
                      onDelete: () => _deleteDoc(doc.id),
                    )),

              // ── Botón compartir ──────────────────────────────────────────
              const SizedBox(height: AppSizes.xl),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _shareWhatsApp,
                  icon: const Icon(Icons.send_rounded, size: 20),
                  label: const Text('Compartir expediente',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.buttonRadius)),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: _shareWhatsApp,
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Compartir con abogado',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.buttonRadius)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _statusBadge(String status) => switch (status) {
        'completed' =>
          const BadgeWidget(label: 'Completado', variant: BadgeVariant.success),
        'in_progress' =>
          const BadgeWidget(label: 'Activo', variant: BadgeVariant.info),
        _ => const BadgeWidget(label: 'Pendiente', variant: BadgeVariant.gray),
      };

  Widget _categoryBadge(String cat) {
    const labels = {
      'family': 'Familia',
      'labor': 'Laboral',
      'criminal': 'Penal',
      'commercial': 'Mercantil',
      'other': 'Otro',
    };
    return BadgeWidget(label: labels[cat] ?? cat, variant: BadgeVariant.gray);
  }

  String _priorityLabel(String p) =>
      switch (p) { 'high' => 'Alta', 'medium' => 'Media', _ => 'Baja' };

  Color _priorityColor(String p) => switch (p) {
        'high' => AppColors.errorRed,
        'medium' => AppColors.warningAmber,
        _ => AppColors.greyMedium,
      };
}

// ─── Widgets auxiliares ──────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.greyDark));
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSizes.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: child,
      );
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: AppColors.greyMedium),
          const SizedBox(width: AppSizes.sm),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.subtitleGrey)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? AppColors.greyDark)),
        ],
      );
}

class _DocCard extends StatelessWidget {
  final _Doc doc;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _DocCard(
      {required this.doc, required this.onOpen, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy').format(doc.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md, vertical: AppSizes.xs),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: doc.isImage
                ? const Color(0xFFE3F2FD)
                : const Color(0xFFFCE4EC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            doc.isImage
                ? Icons.image_outlined
                : Icons.picture_as_pdf_outlined,
            color: doc.isImage ? AppColors.primaryBlue : AppColors.errorRed,
            size: 20,
          ),
        ),
        title: Text(doc.name,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.greyDark),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Text('${doc.sizeLabel} · $dateStr',
            style: const TextStyle(
                fontSize: 11, color: AppColors.subtitleGrey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded,
                  size: 18, color: AppColors.primaryBlue),
              onPressed: onOpen,
              tooltip: 'Abrir',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.errorRed),
              onPressed: onDelete,
              tooltip: 'Eliminar',
            ),
          ],
        ),
      ),
    );
  }
}
