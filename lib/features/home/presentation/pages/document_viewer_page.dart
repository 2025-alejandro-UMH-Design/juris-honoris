import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';

// ─── Modelo mínimo para que esta página sea autónoma ─────────────────────────

class DocViewerArgs {
  final String id;
  final String name;
  final String url;
  final String fileType;

  const DocViewerArgs({
    required this.id,
    required this.name,
    required this.url,
    required this.fileType,
  });

  bool get isImage => fileType.startsWith('image/');
}

// ─── Página ───────────────────────────────────────────────────────────────────

class DocumentViewerPage extends StatefulWidget {
  final DocViewerArgs doc;

  const DocumentViewerPage({super.key, required this.doc});

  @override
  State<DocumentViewerPage> createState() => _DocumentViewerPageState();
}

class _DocumentViewerPageState extends State<DocumentViewerPage> {
  bool _downloading = false;
  bool _appBarVisible = true;

  // B3: sanitiza el nombre del archivo antes de usarlo como path
  String get _safeFileName {
    return widget.doc.name
        .split(RegExp(r'[/\\:*?"<>|]'))
        .last
        .replaceAll(RegExp(r'[^\w\s.\-]'), '_')
        .trim()
        .replaceAll(' ', '_');
  }

  // ── Descargar archivo y compartir con sistema ─────────────────────────────
  Future<void> _downloadAndShare() async {
    setState(() => _downloading = true);
    try {
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/$_safeFileName';

      // B6: Dio sin auth — OK porque las URLs de Cloudinary son públicas
      final dio = Dio();
      await dio.download(widget.doc.url, savePath);

      if (!mounted) return;
      await Share.shareXFiles(
        [XFile(savePath, mimeType: widget.doc.fileType)],
        subject: widget.doc.name,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().split('\n').first}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      // B2: siempre resetea _downloading, incluso si !mounted en el try
      if (mounted) setState(() => _downloading = false);
    }
  }

  // ── Guardar en descargas del dispositivo ─────────────────────────────────
  Future<void> _saveToDownloads() async {
    setState(() => _downloading = true);
    try {
      // B4: cadena de fallbacks para máxima compatibilidad Android 10+
      final dir = await getDownloadsDirectory()
          ?? await getExternalStorageDirectory()
          ?? await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/$_safeFileName';

      final dio = Dio();
      await dio.download(widget.doc.url, savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successGreen,
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Guardado: ${widget.doc.name}',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo guardar: ${e.toString().split('\n').first}'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      // B2: siempre resetea _downloading
      if (mounted) setState(() => _downloading = false);
    }
  }

  // ── Abrir en app externa ──────────────────────────────────────────────────
  Future<void> _openExternal() async {
    final uri = Uri.parse(widget.doc.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _toggleAppBar() {
    setState(() => _appBarVisible = !_appBarVisible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: widget.doc.isImage,
      appBar: widget.doc.isImage
          ? (_appBarVisible
              ? AppBar(
                  backgroundColor: Colors.black.withValues(alpha: 0.6),
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  title: Text(
                    widget.doc.name,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  actions: [
                    if (_downloading)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ),
                      )
                    else ...[
                      IconButton(
                        tooltip: 'Compartir',
                        icon: const Icon(Icons.share_rounded,
                            color: Colors.white),
                        onPressed: _downloadAndShare,
                      ),
                      IconButton(
                        tooltip: 'Descargar',
                        icon: const Icon(Icons.download_rounded,
                            color: Colors.white),
                        onPressed: _saveToDownloads,
                      ),
                    ],
                  ],
                )
              : null)
          : AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                widget.doc.name,
                style:
                    const TextStyle(color: Colors.white, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: [
                if (_downloading)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                  )
                else ...[
                  IconButton(
                    tooltip: 'Compartir',
                    icon: const Icon(Icons.share_rounded,
                        color: Colors.white),
                    onPressed: _downloadAndShare,
                  ),
                  IconButton(
                    tooltip: 'Descargar',
                    icon: const Icon(Icons.download_rounded,
                        color: Colors.white),
                    onPressed: _saveToDownloads,
                  ),
                ],
              ],
            ),
      body: widget.doc.isImage
          ? _ImageViewer(
              url: widget.doc.url,
              onTap: _toggleAppBar,
            )
          : _DocPreview(
              doc: widget.doc,
              onOpenExternal: _openExternal,
              onShare: _downloadAndShare,
              onDownload: _saveToDownloads,
              downloading: _downloading,
            ),
    );
  }
}

// ─── Visor de imagen ─────────────────────────────────────────────────────────

class _ImageViewer extends StatelessWidget {
  final String url;
  final VoidCallback onTap;

  const _ImageViewer({required this.url, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 5.0,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (_, __) => const Center(
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            ),
            errorWidget: (_, __, ___) => const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_rounded,
                      color: Colors.white54, size: 48),
                  SizedBox(height: 12),
                  Text('No se pudo cargar la imagen',
                      style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Vista para PDFs / documentos no-imagen ───────────────────────────────────

class _DocPreview extends StatelessWidget {
  final DocViewerArgs doc;
  final VoidCallback onOpenExternal;
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final bool downloading;

  const _DocPreview({
    required this.doc,
    required this.onOpenExternal,
    required this.onShare,
    required this.onDownload,
    required this.downloading,
  });

  IconData get _icon {
    if (doc.fileType == 'application/pdf') return Icons.picture_as_pdf_rounded;
    if (doc.fileType.contains('word')) return Icons.description_rounded;
    return Icons.insert_drive_file_rounded;
  }

  Color get _iconColor {
    if (doc.fileType == 'application/pdf') return const Color(0xFFE53935);
    if (doc.fileType.contains('word')) return const Color(0xFF1565C0);
    return Colors.white70;
  }

  String get _typeName {
    if (doc.fileType == 'application/pdf') return 'Documento PDF';
    if (doc.fileType.contains('word')) return 'Documento Word';
    return 'Documento';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            // ── Ícono del tipo ──────────────────────────────────────────
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(_icon, size: 52, color: _iconColor),
            ),
            const SizedBox(height: 20),

            Text(doc.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Text(_typeName,
                style: const TextStyle(
                    color: Colors.white60, fontSize: 13)),

            const Spacer(),

            // ── Acciones ────────────────────────────────────────────────
            if (downloading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text('Procesando...',
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              )
            else ...[
              // Abrir en app externa (navegador, lector PDF, etc.)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onOpenExternal,
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Abrir con otra aplicación'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  // Descargar
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDownload,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Descargar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Colors.white38),
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Compartir
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onShare,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Compartir'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Colors.white38),
                        padding:
                            const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
