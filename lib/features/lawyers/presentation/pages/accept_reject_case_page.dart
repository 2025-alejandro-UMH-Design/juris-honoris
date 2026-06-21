import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/api_config.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/shared/widgets/app_button.dart';
import 'package:juris_honoris/shared/widgets/app_card.dart';

import 'lawyer_chat_page.dart';

class AcceptRejectCasePage extends StatelessWidget {
  final Map<String, dynamic> caseData;

  // Demo flag: treat first case as no commission
  final bool isFirstCase;

  const AcceptRejectCasePage({
    super.key,
    required this.caseData,
    this.isFirstCase = true,
  });

  Future<void> _acceptRequest() async {
    final dio = sl<Dio>();
    await dio.put('${ApiConfig.requests}/${caseData['id']}/accept');
  }

  Future<void> _rejectRequest(String? reason) async {
    final dio = sl<Dio>();
    await dio.put(
      '${ApiConfig.requests}/${caseData['id']}/reject',
      data: {'reason': reason},
    );
  }

  void _onAccept(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline,
                color: AppColors.successGreen, size: 22),
            SizedBox(width: AppSizes.sm),
            Text('Aceptar caso',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark)),
          ],
        ),
        content: Text(
          '¿Confirmas que deseas aceptar el caso "${caseData['title']}"? Se te pondrá en contacto con el cliente.',
          style: const TextStyle(
              fontSize: 14, color: AppColors.subtitleGrey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.greyMedium)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await _acceptRequest();
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => LawyerChatPage(
                        clientName: (caseData['clientName'] as String?) ?? 'Cliente',
                        caseType: (caseData['type'] as String?) ?? 'Caso legal',
                        caseId: (caseData['id'] as String?) ?? '',
                      ),
                    ),
                  );
                }
              } on DioException catch (e) {
                if (context.mounted) {
                  final msg = e.response?.data?['error']?.toString() ??
                      'Error al aceptar el caso';
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(msg)));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirmar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _onReject(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.errorRed, size: 22),
            SizedBox(width: AppSizes.sm),
            Text('Rechazar caso',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.greyDark)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indica el motivo del rechazo (opcional):',
              style: TextStyle(fontSize: 13, color: AppColors.subtitleGrey),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13, color: AppColors.greyDark),
              decoration: InputDecoration(
                hintText:
                    'Ej. Conflicto de interés, fuera de mi especialidad...',
                hintStyle:
                    const TextStyle(fontSize: 13, color: AppColors.hintGrey),
                filled: true,
                fillColor: AppColors.greyVeryLight,
                contentPadding: const EdgeInsets.all(AppSizes.md),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  borderSide: const BorderSide(color: AppColors.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.inputRadius),
                  borderSide: const BorderSide(
                      color: AppColors.primaryBlue, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.greyMedium)),
          ),
          ElevatedButton(
            onPressed: () async {
              final reason = reasonController.text.trim();
              Navigator.of(ctx).pop();
              try {
                await _rejectRequest(reason.isEmpty ? null : reason);
                if (context.mounted) Navigator.of(context).pop();
              } on DioException catch (e) {
                if (context.mounted) {
                  final msg = e.response?.data?['error']?.toString() ??
                      'Error al rechazar el caso';
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(msg)));
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Rechazar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = caseData['urgency'] == 'urgent';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.greyDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detalles del Caso',
          style: TextStyle(
              color: AppColors.greyDark,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Commission banner ──────────────────────────────────
            if (isFirstCase)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: AppSizes.md),
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  border: Border.all(
                      color: AppColors.successGreen.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.card_giftcard,
                        color: AppColors.successGreen, size: 20),
                    SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Text(
                        'Este es tu primer caso — sin comisión para ti',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.successGreen,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Main case card ─────────────────────────────────────
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type chip + urgency
                  Row(
                    children: [
                      _TypeChip(label: (caseData['type'] as String?) ?? 'Legal'),
                      const SizedBox(width: AppSizes.sm),
                      _UrgencyBadge(isUrgent: isUrgent),
                    ],
                  ),
                  const SizedBox(height: AppSizes.md),

                  // Title
                  Text(
                    (caseData['title'] as String?) ?? 'Solicitud legal',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.greyDark),
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Date
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: AppColors.greyMedium),
                      const SizedBox(width: 4),
                      Text(
                        'Fecha de solicitud: ${caseData['date']}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.subtitleGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),

                  // Description
                  const Text(
                    'Descripción del caso',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Text(
                    (caseData['description'] as String?) ?? '',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.greyDark, height: 1.6),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  const Divider(color: AppColors.borderColor),
                  const SizedBox(height: AppSizes.md),

                  // Client info
                  const Text(
                    'Información del cliente',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: AppColors.greyMedium),
                      const SizedBox(width: AppSizes.sm),
                      Text(
                        '${caseData['clientName']} (información completa disponible al aceptar)',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.greyDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),

                  const Divider(color: AppColors.borderColor),
                  const SizedBox(height: AppSizes.md),

                  // Fees
                  const Text(
                    'Estimado de honorarios',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Row(
                    children: [
                      Icon(Icons.attach_money,
                          size: 16, color: AppColors.greyMedium),
                      SizedBox(width: AppSizes.xs),
                      Text(
                        'L. 1,500 - 3,000 según complejidad',
                        style: TextStyle(
                            fontSize: 14,
                            color: AppColors.greyDark,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.sm),

                  // Commission line
                  if (isFirstCase)
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 14, color: AppColors.successGreen),
                        SizedBox(width: AppSizes.xs),
                        Text(
                          'Sin comisión (primer caso)',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    )
                  else
                    const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 14, color: AppColors.subtitleGrey),
                        SizedBox(width: AppSizes.xs),
                        Text(
                          'Comisión estimada: L. 225 (15%)',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.subtitleGrey),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // ── Action buttons ─────────────────────────────────────
            AppButton(
              label: 'Aceptar caso',
              variant: ButtonVariant.success,
              onPressed: () => _onAccept(context),
              icon: Icons.check,
            ),
            const SizedBox(height: AppSizes.md),
            AppButton(
              label: 'Rechazar',
              variant: ButtonVariant.danger,
              onPressed: () => _onReject(context),
              icon: Icons.close,
            ),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  const _TypeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
            fontSize: 11,
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _UrgencyBadge extends StatelessWidget {
  final bool isUrgent;
  const _UrgencyBadge({required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 3),
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.errorRed : AppColors.greyLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isUrgent ? 'Urgente' : 'Normal',
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isUrgent ? AppColors.white : AppColors.greyDark),
      ),
    );
  }
}
