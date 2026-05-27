import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/ai_chat/domain/entities/ai_message.dart';
import 'package:juris_honoris/features/ai_chat/presentation/widgets/typing_indicator.dart';

/// Burbuja de mensaje del chat IA.
///
/// Parámetros:
/// - [message]: el mensaje a mostrar
/// - [needsLawyer]: null si no aplica (es mensaje del usuario o aún no hay análisis),
///   true/false si es la última respuesta de la IA con análisis de necesidad de abogado.
class AIMessageBubble extends StatelessWidget {
  final AIMessage message;
  final bool? needsLawyer;

  const AIMessageBubble({
    super.key,
    required this.message,
    this.needsLawyer,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.xs,
      ),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            _AIAvatar(),
            const SizedBox(width: AppSizes.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.isLoading)
                  const TypingIndicator()
                else
                  _BubbleContent(message: message, isUser: isUser),

                // Badge de análisis legal — solo para respuestas de IA con análisis
                if (!isUser && !message.isLoading && needsLawyer != null) ...[
                  const SizedBox(height: AppSizes.xs),
                  _NeedsLawyerBadge(needsLawyer: needsLawyer!),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppSizes.sm),
            _UserAvatar(),
          ],
        ],
      ),
    );
  }
}

class _BubbleContent extends StatelessWidget {
  final AIMessage message;
  final bool isUser;

  const _BubbleContent({required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: isUser ? AppColors.primaryBlue : AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft:
              isUser ? const Radius.circular(16) : const Radius.circular(4),
          bottomRight:
              isUser ? const Radius.circular(4) : const Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message.content,
        style: TextStyle(
          color: isUser ? AppColors.white : AppColors.greyDark,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}

class _NeedsLawyerBadge extends StatelessWidget {
  final bool needsLawyer;

  const _NeedsLawyerBadge({required this.needsLawyer});

  @override
  Widget build(BuildContext context) {
    final color = needsLawyer ? AppColors.errorRed : AppColors.successGreen;
    final bgColor = needsLawyer
        ? AppColors.errorRed.withOpacity(0.1)
        : AppColors.successGreen.withOpacity(0.1);
    final icon = needsLawyer ? Icons.gavel : Icons.check_circle_outline;
    final label = needsLawyer
        ? 'Recomendamos un abogado'
        : 'Puedes gestionarlo solo';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSizes.xs),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AIAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.balance,
        color: AppColors.white,
        size: 18,
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(
        Icons.person,
        color: AppColors.greyMedium,
        size: 18,
      ),
    );
  }
}
