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
import '../../../home/presentation/pages/document_viewer_page.dart';

// ─── Modelo documento ────────────────────────────────────────────────────────

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

  String get sizeLabel {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─── Página principal ─────────────────────────────────────────────────────────

class LawyerCaseDossierPage extends StatefulWidget {
  final String caseId;
  final String caseTitle;
  final String clientName;
  final String description;
  final String status;

  const LawyerCaseDossierPage({
    super.key,
    required this.caseId,
    required this.caseTitle,
    required this.clientName,
    required this.description,
    required this.status,
  });

  @override
  State<LawyerCaseDossierPage> createState() => _LawyerCaseDossierPageState();
}

class _LawyerCaseDossierPageState extends State<LawyerCaseDossierPage> {
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
      final res = await sl<Dio>()
          .get('${ApiConfig.cases}/${widget.caseId}/documents');
      setState(() {
        _docs = (res.data as List)
            .map((j) => _Doc.fromJson(j as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {}
    if (mounted) setState(() => _loadingDocs = false);
  }

  Future<void> _uploadDoc() async {
    final type = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('¿Qué deseas subir?',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined,
                  color: AppColors.primaryBlue),
              title: const Text('Imagen (cámara o galería)'),
              onTap: () => Navigator.pop(context, 'image'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined,
                  color: AppColors.errorRed),
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
      final img = await ImagePicker()
          .pickImage(source: source, imageQuality: 85);
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
              content: Text('No se pudo leer el archivo.'),
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
        'file': MultipartFile.fromBytes(bytes,
            filename: fileName,
            contentType: DioMediaType.parse(mime)),
        'name': fileName,
      });
      await sl<Dio>()
          .post('${ApiConfig.cases}/${widget.caseId}/documents', data: form);
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



  Future<void> _shareWhatsApp() async {
    final docLines = _docs.isEmpty
        ? ''
        : '\n\n📁 Documentos adjuntos:\n${_docs.map((d) => '  • ${d.name}').join('\n')}';

    final text = Uri.encodeComponent(
      '🗂️ *Expediente Legal - Juris Honoris*\n\n'
      '📋 *${widget.caseTitle}*\n'
      '👤 Cliente: ${widget.clientName}$docLines\n\n'
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
        title: const Text('Expediente del caso',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark)),
        actions: [
          IconButton(
            tooltip: 'Compartir',
            icon:
                const Icon(Icons.share_rounded, color: AppColors.primaryBlue),
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
              // ── Info del caso ────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(color: AppColors.borderColor),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0D000000),
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue
                                .withValues(alpha: 0.1),
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
                              Text(widget.caseTitle,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.greyDark)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline_rounded,
                                      size: 14,
                                      color: AppColors.subtitleGrey),
                                  const SizedBox(width: 4),
                                  Text(widget.clientName,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.subtitleGrey)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.description.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.md),
                      const Divider(
                          height: 1, color: AppColors.borderColor),
                      const SizedBox(height: AppSizes.md),
                      Text(widget.description,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.subtitleGrey,
                              height: 1.55)),
                    ],
                  ],
                ),
              ),

              // ── Documentos ───────────────────────────────────────────
              const SizedBox(height: AppSizes.lg),
              Row(
                children: [
                  const Expanded(
                    child: Text('Documentos del expediente',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.greyDark)),
                  ),
                  TextButton.icon(
                    onPressed: _uploadingDoc ? null : _uploadDoc,
                    icon: _uploadingDoc
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryBlue))
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

              // Banner informativo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14, color: AppColors.primaryBlue),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Los documentos que subas aquí son visibles para el cliente.',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.md),

              if (_loadingDocs)
                const Center(
                    child: Padding(
                  padding: EdgeInsets.all(AppSizes.xl),
                  child: CircularProgressIndicator(
                      color: AppColors.primaryBlue, strokeWidth: 2),
                ))
              else if (_docs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.xl),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius:
                        BorderRadius.circular(AppSizes.cardRadius),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.folder_open_rounded,
                          size: 40,
                          color: AppColors.greyLight
                              .withValues(alpha: 0.8)),
                      const SizedBox(height: AppSizes.sm),
                      const Text('Sin documentos aún',
                          style: TextStyle(
                              fontSize: 13,
                              color: AppColors.greyMedium)),
                      const SizedBox(height: AppSizes.xs),
                      const Text(
                          'Sube documentos para compartir con el cliente.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, color: AppColors.hintGrey)),
                    ],
                  ),
                )
              else
                ..._docs.map((doc) {
                  final dateStr =
                      DateFormat('dd/MM/yyyy').format(doc.createdAt);
                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.sm),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppSizes.cardRadius),
                      border: Border.all(color: AppColors.borderColor),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 4,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: ListTile(
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
                          color: doc.isImage
                              ? AppColors.primaryBlue
                              : AppColors.errorRed,
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
                      subtitle: Text(
                          '${doc.sizeLabel} · $dateStr · ${doc.uploadedByName}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.subtitleGrey)),
                      trailing: const Icon(Icons.chevron_right_rounded,
                          size: 20, color: AppColors.greyMedium),
                    ),
                  );
                }),

              // ── Botón compartir ──────────────────────────────────────
              const SizedBox(height: AppSizes.xl),
              SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: _shareWhatsApp,
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Compartir expediente con cliente',
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
            ],
          ),
        ),
      ),
    );
  }
}
