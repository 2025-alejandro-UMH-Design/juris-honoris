import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Burbuja de mensaje para el chat IA.
///
/// Mensajes del usuario: fondo #0D5BA8, texto blanco, alineación derecha.
/// Mensajes de IA: fondo #F5F5F5, texto #212121, alineación izquierda.
class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.80,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primaryBlue
                    : AppColors.greyVeryLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(20),
                ),
              ),
              child: isLoading
                  ? const _TypingIndicator()
                  : Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isUser ? AppColors.white : AppColors.greyDark,
                        height: 1.4,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(timestamp),
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.hintGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Animación de 3 puntos mientras la IA genera respuesta.
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Offset de fase para cada punto
            final phase = ((_controller.value * 3) - i).clamp(0.0, 1.0);
            final opacity =
                (phase < 0.5 ? phase * 2 : (1 - phase) * 2).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity,
                child: const CircleAvatar(
                  radius: 4,
                  backgroundColor: AppColors.greyMedium,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
