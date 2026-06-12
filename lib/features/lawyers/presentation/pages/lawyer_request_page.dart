import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
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

                // Archivos adjuntos (UI only)
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
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Función de adjuntos próximamente',
                          style: TextStyle(color: AppColors.white),
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.xl),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius:
                          BorderRadius.circular(AppSizes.inputRadius),
                      border: Border.all(
                        color: AppColors.borderColor,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.attach_file_rounded,
                          color: AppColors.greyMedium,
                          size: 32,
                        ),
                        SizedBox(height: AppSizes.xs),
                        Text(
                          'Adjuntar documentos',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'PDF, imágenes u otros documentos relevantes',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.greyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    context.read<LawyersCubit>().sendRequest(
          lawyerId: widget.lawyer.id,
          subject: _caseType,
          description: _descController.text.trim(),
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
