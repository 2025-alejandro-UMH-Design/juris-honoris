import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../injection_container.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_input_field.dart';
import '../../../home/presentation/widgets/lawyer_card.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../bloc/lawyers_cubit.dart';

class LawyerRequestPage extends StatefulWidget {
  final LawyerData lawyer;

  const LawyerRequestPage({
    super.key,
    required this.lawyer,
  });

  @override
  State<LawyerRequestPage> createState() => _LawyerRequestPageState();
}

class _LawyerRequestPageState extends State<LawyerRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();

  String _caseType = 'Consulta general';
  String _urgency = 'Normal';
  bool _isLoading = false;

  int _solicitationsUsed = 0;
  bool _isPlanFree = true;

  final List<({String name, Uint8List bytes, String mime})> _attachments = [];

  final _caseTypes = [
    'Consulta general',
    'Asesoría de urgencia',
    'Representación legal',
    'Revisión de documentos',
    'Negociación',
    'Otro',
  ];

  static const int _maxFree = 3;

  bool get _limitReached => _isPlanFree && _solicitationsUsed >= _maxFree;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = context.read<AuthCubit>().currentUser;
      setState(() {
        _solicitationsUsed = user?.solicitationsThisMonth ?? 0;
        _isPlanFree = user?.plan != UserPlan.premium;
      });
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LawyersCubit, LawyersState>(
      listener: (ctx, state) {
        if (state is LawyerRequestSent) {
          setState(() => _isLoading = false);
          _showSuccessDialog();
        } else if (state is LawyersError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(state.message)),
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
          title: const Text(
            'Solicitar Servicio Legal',
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
                // Abogado seleccionado (read-only)
                _ReadOnlyField(
                  label: 'Abogado seleccionado',
                  value: widget.lawyer.name,
                  icon: Icons.person_outline_rounded,
                ),

                const SizedBox(height: AppSizes.lg),

                // Tipo de caso
                const Text(
                  'Tipo de caso',
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
                      value: _caseType,
                      isExpanded: true,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.greyMedium,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.greyDark,
                      ),
                      items: _caseTypes.map((t) {
                        return DropdownMenuItem(value: t, child: Text(t));
                      }).toList(),
                      onChanged: (v) => setState(() => _caseType = v!),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // Descripción
                AppInputField(
                  controller: _descController,
                  label: 'Descripción del caso',
                  hintText:
                      'Describe brevemente tu situación legal y qué tipo de ayuda necesitas...',
                  maxLines: 5,
                  validator: (v) => (v == null || v.trim().length < 20)
                      ? 'Por favor describe el caso (mín. 20 caracteres)'
                      : null,
                ),

                const SizedBox(height: AppSizes.xl),

                // Urgencia
                const Text(
                  'Urgencia',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                Row(
                  children: ['Normal', 'Urgente'].map((u) {
                    final isSelected = u == _urgency;
                    final color = u == 'Urgente'
                        ? AppColors.errorRed
                        : AppColors.primaryBlue;
                    return GestureDetector(
                      onTap: () => setState(() => _urgency = u),
                      child: Container(
                        margin: const EdgeInsets.only(right: AppSizes.sm),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.lg,
                          vertical: AppSizes.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color : AppColors.greyVeryLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? color : AppColors.borderColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (u == 'Urgente')
                              Icon(
                                Icons.priority_high_rounded,
                                size: 14,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.errorRed,
                              ),
                            if (u == 'Urgente') const SizedBox(width: 4),
                            Text(
                              u,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.greyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSizes.xl),

                // Archivos adjuntos
                const Text(
                  'Documentos adjuntos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.greyDark,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                GestureDetector(
                  onTap: _isLoading ? null : _pickFiles,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.attach_file_rounded,
                            color: AppColors.greyMedium, size: 32),
                        SizedBox(height: AppSizes.xs),
                        Text('Adjuntar documentos',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500)),
                        SizedBox(height: 2),
                        Text('PDF, Word, imágenes (máx. 5 archivos)',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.greyMedium)),
                      ],
                    ),
                  ),
                ),
                if (_attachments.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _attachments.asMap().entries.map((e) {
                      final isImg = e.value.mime.startsWith('image/');
                      return Chip(
                        avatar: Icon(
                            isImg ? Icons.image_outlined : Icons.picture_as_pdf_outlined,
                            size: 14,
                            color: AppColors.primaryBlue),
                        label: Text(e.value.name,
                            style: const TextStyle(fontSize: 11),
                            overflow: TextOverflow.ellipsis),
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () => setState(() => _attachments.removeAt(e.key)),
                        backgroundColor: const Color(0xFFE3F2FD),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                ],

                // Nota de plan free
                if (_isPlanFree) ...[
                  const SizedBox(height: AppSizes.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius:
                          BorderRadius.circular(AppSizes.inputRadius),
                      border: Border.all(
                          color: AppColors.secondaryOrange
                              .withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: AppColors.secondaryOrange,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Expanded(
                          child: Text(
                            'Esta será tu solicitud ${_solicitationsUsed + 1}/$_maxFree del mes (Plan Gratuito).',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.greyDark,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: AppSizes.xl2),

                AppButton(
                  label: _limitReached
                      ? 'Actualizar a Premium'
                      : 'Enviar solicitud',
                  icon: _limitReached
                      ? Icons.star_rounded
                      : Icons.send_rounded,
                  isLoading: _isLoading,
                  onPressed: _limitReached ? _showUpgradeModal : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result == null) return;
    for (final f in result.files) {
      if (f.bytes == null) continue;
      if (_attachments.length >= 5) break;
      setState(() => _attachments.add((name: f.name, bytes: f.bytes!, mime: _mimeFor(f.extension ?? ''))));
    }
  }

  String _mimeFor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':  return 'application/pdf';
      case 'doc':  return 'application/msword';
      case 'docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'png':  return 'image/png';
      case 'webp': return 'image/webp';
      default:     return 'image/jpeg';
    }
  }

  Future<List<String>> _uploadAttachments() async {
    final dio = sl<Dio>();
    final urls = <String>[];
    for (final a in _attachments) {
      try {
        final form = FormData.fromMap({
          'file': MultipartFile.fromBytes(a.bytes, filename: a.name,
              contentType: DioMediaType.parse(a.mime)),
        });
        final res = await dio.post('${ApiConfig.upload}/temp', data: form);
        urls.add(res.data['url'] as String);
      } catch (_) {}
    }
    return urls;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    String description = _descController.text.trim();
    if (_attachments.isNotEmpty) {
      final urls = await _uploadAttachments();
      if (urls.isNotEmpty) {
        final lines = urls.asMap().entries.map((e) => '• ${_attachments[e.key].name}: ${e.value}').join('\n');
        description += '\n\n📎 Documentos adjuntos:\n$lines';
      }
    }
    if (!mounted) return;
    context.read<LawyersCubit>().sendRequest(
          lawyerId: widget.lawyer.id,
          subject: _caseType,
          description: description,
        );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.successGreen),
            SizedBox(width: AppSizes.sm),
            Text(
              'Solicitud enviada',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Tu solicitud ha sido enviada a ${widget.lawyer.name}. Te contactará pronto.',
          style: const TextStyle(fontSize: 14, color: AppColors.subtitleGrey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Entendido',
              style: TextStyle(
                  color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeModal() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        title: const Row(
          children: [
            Icon(Icons.star_rounded, color: AppColors.secondaryOrange),
            SizedBox(width: AppSizes.sm),
            Text(
              'Límite alcanzado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: const Text(
          'Alcanzaste el límite de 3 solicitudes del mes con el Plan Gratuito. Actualiza a Premium para solicitudes ilimitadas.',
          style: TextStyle(
              fontSize: 14, color: AppColors.subtitleGrey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.greyMedium),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Próximamente: integración con pasarela de pago',
                  ),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text(
              'Ver Premium',
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

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.greyDark,
          ),
        ),
        const SizedBox(height: AppSizes.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.greyVeryLight,
            borderRadius: BorderRadius.circular(AppSizes.inputRadius),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppColors.greyMedium),
              const SizedBox(width: AppSizes.sm),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.greyMedium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
