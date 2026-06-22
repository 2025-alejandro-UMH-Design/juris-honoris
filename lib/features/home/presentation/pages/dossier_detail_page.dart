import 'dart:async';
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
import 'document_viewer_page.dart';

// ─── Modelo ──────────────────────────────────────────────────────────────────

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
        createdAt: DateTime.tryParse(j['created_at'] as String? ?? '') ??
            DateTime.now(),
      );

  bool get isImage => fileType.startsWith('image/');

  bool get isNew =>
      DateTime.now().difference(createdAt).inMinutes < 10;

  String get sizeLabel {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─── Página ───────────────────────────────────────────────────────────────────

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
  String? _uploadingFileName;
  Timer? _newBadgeTimer;

  @override
  void initState() {
    super.initState();
    _loadDocs();
    // B7: hace desaparecer el badge "NUEVO" después de 10 minutos sin rebuild
    _newBadgeTimer = Timer(const Duration(minutes: 10), () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _newBadgeTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadDocs() async {
    setState(() => _loadingDocs = true);
    try {
      final res = await sl<Dio>()
          .get('${ApiConfig.cases}/${widget.task.id}/documents');
      if (mounted) {
        setState(() {
          _docs = (res.data as List)
              .map((j) => _Doc.fromJson(j as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingDocs = false);
  }

  Future<void> _uploadDoc() async {
    // ── Selector de tipo ──────────────────────────────────────────────────
    final type = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Agregar al expediente',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark)),
            const SizedBox(height: 4),
            const Text('¿Qué tipo de archivo deseas subir?',
                style:
                    TextStyle(fontSize: 13, color: AppColors.subtitleGrey)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _PickerOption(
                    icon: Icons.image_rounded,
                    color: AppColors.primaryBlue,
                    label: 'Imagen',
                    sublabel: 'Cámara o galería',
                    onTap: () => Navigator.pop(context, 'image'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerOption(
                    icon: Icons.picture_as_pdf_rounded,
                    color: AppColors.errorRed,
                    label: 'Documento',
                    sublabel: 'PDF, Word, etc.',
                    onTap: () => Navigator.pop(context, 'doc'),
                  ),
                ),
              ],
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Seleccionar imagen',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyDark)),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFFF5F7FF),
                leading: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.primaryBlue),
                title: const Text('Tomar foto',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Usar la cámara del dispositivo',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.subtitleGrey)),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: const Color(0xFFF5F7FF),
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppColors.primaryBlue),
                title: const Text('Elegir de galería',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Seleccionar imagen guardada',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.subtitleGrey)),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      if (source == null || !mounted) return;
      final img =
          await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (img == null) return;
      bytes = await img.readAsBytes();
      fileName = img.name;
      mime = img.name.endsWith('.png') ? 'image/png' : 'image/jpeg';
    } else {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.any, withData: true);
      if (result == null || result.files.isEmpty) return;
      final f = result.files.first;
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

    setState(() {
      _uploadingDoc = true;
      _uploadingFileName = fileName;
    });

    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes,
            filename: fileName,
            contentType: DioMediaType.parse(mime)),
        'name': fileName,
      });
      await sl<Dio>()
          .post('${ApiConfig.cases}/${widget.task.id}/documents', data: form);
      await _loadDocs();

      if (mounted) {
        // Nombre corto para el SnackBar
        final shortName = fileName.length > 30
            ? '${fileName.substring(0, 27)}...'
            : fileName;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 5),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"$shortName" guardado en el expediente',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            action: SnackBarAction(
              label: 'Subir otro',
              textColor: Colors.white,
              onPressed: _uploadDoc,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final msg = (e is DioException)
            ? (e.response?.data?['error']?.toString() ??
                'Error ${e.response?.statusCode ?? "de red"}')
            : e.toString().split('\n').first;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Error al subir: $msg',
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: AppColors.errorRed,
            duration: const Duration(seconds: 6),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _uploadingDoc = false;
        _uploadingFileName = null;
      });
    }
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


  Future<void> _deleteDoc(String docId, String docName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar documento',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content:
            Text('¿Eliminar "$docName" del expediente? Esta acción no se puede deshacer.',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.subtitleGrey, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await sl<Dio>().delete(
          '${ApiConfig.cases}/${widget.task.id}/documents/$docId');
      await _loadDocs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Documento eliminado'),
            duration: Duration(seconds: 2),
          ),
        );
      }
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
    final dateStr =
        task.dueDate.isNotEmpty ? '\n📅 Fecha límite: ${task.dueDate}' : '';
    final notes =
        task.notes.isNotEmpty ? '\n\n📝 Observaciones:\n${task.notes}' : '';

    String docSection = '';
    if (_docs.isNotEmpty) {
      final docList =
          _docs.asMap().entries.map((e) => '${e.key + 1}. ${e.value.name}').join('\n');
      docSection = '\n\n📂 Documentos del expediente (${_docs.length}):\n$docList';
    }

    final text = Uri.encodeComponent(
      '🗂️ *Expediente Legal — Juris Honoris*\n'
      '━━━━━━━━━━━━━━━━━━\n\n'
      '📋 *${task.title}*\n'
      '🏷️ Área: $categoryLabel\n'
      '📊 Estado: $statusLabel$dateStr'
      '$notes'
      '$docSection\n\n'
      '━━━━━━━━━━━━━━━━━━\n'
      '_Enviado desde Juris Honoris_',
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expediente',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark)),
            if (_docs.isNotEmpty)
              Text(
                '${_docs.length} documento${_docs.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.subtitleGrey),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Compartir por WhatsApp',
            icon: const Icon(Icons.share_rounded,
                color: AppColors.primaryBlue),
            onPressed: _shareWhatsApp,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_uploadingDoc ? 5 : 1),
          child: _uploadingDoc
              ? LinearProgressIndicator(
                  backgroundColor:
                      AppColors.primaryBlue.withValues(alpha: 0.15),
                  color: AppColors.primaryBlue,
                  minHeight: 4,
                )
              : Container(height: 1, color: AppColors.borderColor),
        ),
      ),
      // ── Barra inferior fija ───────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(top: BorderSide(color: AppColors.borderColor)),
          ),
          child: Row(
            children: [
              // Botón agregar
              Expanded(
                flex: 2,
                child: OutlinedButton.icon(
                  onPressed: _uploadingDoc ? null : _uploadDoc,
                  icon: _uploadingDoc
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryBlue))
                      : const Icon(Icons.attach_file_rounded, size: 18),
                  label: Text(_uploadingDoc
                      ? 'Subiendo...'
                      : 'Agregar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.buttonRadius)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Botón WhatsApp
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: _shareWhatsApp,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Compartir por WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSizes.buttonRadius)),
                    textStyle: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDocs,
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              AppSizes.pagePadding, AppSizes.lg, AppSizes.pagePadding, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner de carga ────────────────────────────────────────
              if (_uploadingDoc) ...[
                _UploadingBanner(fileName: _uploadingFileName),
                const SizedBox(height: AppSizes.md),
              ],

              // ── Info del caso ──────────────────────────────────────────
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
                            color:
                                AppColors.primaryBlue.withValues(alpha: 0.1),
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
                      const Divider(
                          height: 1, color: AppColors.borderColor),
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

              // ── Metadatos ──────────────────────────────────────────────
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

              // ── Notas ─────────────────────────────────────────────────
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

              // ── Documentos ─────────────────────────────────────────────
              const SizedBox(height: AppSizes.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                      child: _SectionTitle(title: 'Documentos adjuntos')),
                  if (_docs.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_docs.length}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Archivos guardados automáticamente en la nube',
                style: TextStyle(fontSize: 12, color: AppColors.subtitleGrey),
              ),
              const SizedBox(height: AppSizes.md),

              if (_loadingDocs)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.xl),
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue, strokeWidth: 2),
                  ),
                )
              else if (_docs.isEmpty)
                _EmptyDocs(onUpload: _uploadDoc)
              else ...[
                ..._docs.map((doc) => _DocCard(
                      doc: doc,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DocumentViewerPage(
                            doc: DocViewerArgs(
                              id: doc.id,
                              name: doc.name,
                              url: doc.filePath,
                              fileType: doc.fileType,
                            ),
                          ),
                        ),
                      ),
                      onDelete: () => _deleteDoc(doc.id, doc.name),
                    )),
                const SizedBox(height: AppSizes.md),
                // Preview de lo que se compartirá
                _SharePreview(
                  docCount: _docs.length,
                  hasNotes: task.notes.isNotEmpty,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

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
    return BadgeWidget(
        label: labels[cat] ?? cat, variant: BadgeVariant.gray);
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

class _UploadingBanner extends StatelessWidget {
  final String? fileName;
  const _UploadingBanner({this.fileName});

  @override
  Widget build(BuildContext context) {
    final name = fileName != null && fileName!.length > 28
        ? '${fileName!.substring(0, 25)}...'
        : (fileName ?? 'archivo');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2.5, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Subiendo al expediente...',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue)),
                Text(name,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.subtitleGrey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDocs extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyDocs({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
            color: AppColors.borderColor, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.cloud_upload_outlined,
                size: 32, color: AppColors.primaryBlue),
          ),
          const SizedBox(height: 16),
          const Text('Sin documentos adjuntos',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyDark)),
          const SizedBox(height: 6),
          const Text(
            'Agrega fotos o documentos relacionados\na este proceso legal.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: AppColors.subtitleGrey, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Agregar primer documento'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SharePreview extends StatelessWidget {
  final int docCount;
  final bool hasNotes;
  const _SharePreview({required this.docCount, required this.hasNotes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FBF4),
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
            color: const Color(0xFF25D366).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.send_rounded,
                  size: 14, color: Color(0xFF128C7E)),
              SizedBox(width: 6),
              Text('Resumen que se compartirá',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF128C7E))),
            ],
          ),
          const SizedBox(height: 8),
          const _PreviewLine('Información del caso (título, área, estado)'),
          if (hasNotes) const _PreviewLine('Notas del proceso'),
          _PreviewLine('Lista de $docCount documento${docCount == 1 ? '' : 's'} adjunto${docCount == 1 ? '' : 's'}'),
        ],
      ),
    );
  }
}

class _PreviewLine extends StatelessWidget {
  final String text;
  const _PreviewLine(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: [
            const Icon(Icons.check_rounded,
                size: 13, color: Color(0xFF25D366)),
            const SizedBox(width: 6),
            Text(text,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.subtitleGrey)),
          ],
        ),
      );
}

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
                color: Color(0x0D000000),
                blurRadius: 4,
                offset: Offset(0, 2))
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
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DocCard(
      {required this.doc, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(doc.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.sm),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        border: Border.all(
            color: doc.isNew
                ? AppColors.successGreen.withValues(alpha: 0.4)
                : AppColors.borderColor),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 4,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.md, vertical: 6),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: doc.isImage
                    ? const Color(0xFFE3F2FD)
                    : const Color(0xFFFCE4EC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                doc.isImage
                    ? Icons.image_rounded
                    : Icons.picture_as_pdf_rounded,
                color:
                    doc.isImage ? AppColors.primaryBlue : AppColors.errorRed,
                size: 22,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(doc.name,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.greyDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                if (doc.isNew) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('NUEVO',
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5)),
                  ),
                ],
              ],
            ),
            subtitle: Text('${doc.sizeLabel} · $dateStr',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.subtitleGrey)),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  size: 20, color: AppColors.greyMedium),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (v) {
                if (v == 'view') onTap();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility_rounded,
                          size: 18, color: AppColors.primaryBlue),
                      SizedBox(width: 10),
                      Text('Ver / descargar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded,
                          size: 18, color: AppColors.errorRed),
                      SizedBox(width: 10),
                      Text('Eliminar',
                          style: TextStyle(color: AppColors.errorRed)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Picker card bonito ────────────────────────────────────────────────────────

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 2),
              Text(sublabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.subtitleGrey)),
            ],
          ),
        ),
      );
}
