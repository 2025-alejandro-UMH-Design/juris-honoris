import 'package:flutter/material.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/shared/widgets/message_bubble.dart';

// ── Mock messages ──────────────────────────────────────────────────────────────

final _initialMessages = [
  _ChatMessage(
    text:
        'Hola Doctor, gracias por aceptar mi caso. Tengo varias dudas sobre el proceso.',
    isLawyer: false,
    timestamp: DateTime(2026, 5, 27, 9, 15),
  ),
  _ChatMessage(
    text:
        'Buenos días. Con gusto lo ayudo. ¿Cuál es su principal preocupación en este momento?',
    isLawyer: true,
    timestamp: DateTime(2026, 5, 27, 9, 18),
  ),
  _ChatMessage(
    text:
        'Principalmente la custodia de mis hijos. ¿Cómo funciona el proceso en Honduras?',
    isLawyer: false,
    timestamp: DateTime(2026, 5, 27, 9, 20),
  ),
];

class _ChatMessage {
  final String text;
  final bool isLawyer;
  final DateTime timestamp;

  const _ChatMessage({
    required this.text,
    required this.isLawyer,
    required this.timestamp,
  });
}

// ── Page ───────────────────────────────────────────────────────────────────────

class LawyerChatPage extends StatefulWidget {
  final String clientName;
  final String caseType;
  final String caseId;

  const LawyerChatPage({
    super.key,
    required this.clientName,
    required this.caseType,
    required this.caseId,
  });

  @override
  State<LawyerChatPage> createState() => _LawyerChatPageState();
}

class _LawyerChatPageState extends State<LawyerChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = List.from(_initialMessages);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isLawyer: true,
        timestamp: DateTime.now(),
      ));
    });
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _closeCase(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Text(
          'Cerrar caso',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.greyDark,
              fontSize: 16),
        ),
        content: const Text(
          '¿Estás seguro de que deseas cerrar este caso? Esta acción no se puede deshacer.',
          style: TextStyle(
              fontSize: 14, color: AppColors.subtitleGrey, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.greyMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cerrar caso',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.greyDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.clientName,
              style: const TextStyle(
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            Text(
              'Caso: ${widget.caseType}',
              style:
                  const TextStyle(color: AppColors.subtitleGrey, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _closeCase(context),
            icon: const Icon(Icons.close, size: 16, color: AppColors.errorRed),
            label: const Text(
              'Cerrar caso',
              style: TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Confidentiality banner ──────────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg, vertical: AppSizes.sm),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline,
                    size: 12, color: AppColors.primaryBlue),
                SizedBox(width: 4),
                Text(
                  'Conversación cifrada y confidencial',
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // ── Messages ───────────────────────────────────────────
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSizes.pagePadding),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
              itemBuilder: (_, i) {
                final msg = _messages[i];
                return MessageBubble(
                  message: msg.text,
                  isUser: msg.isLawyer,
                  timestamp: msg.timestamp,
                );
              },
            ),
          ),

          // ── Input bar ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.borderColor)),
              boxShadow: [
                BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 4,
                    offset: Offset(0, -2)),
              ],
            ),
            padding: EdgeInsets.fromLTRB(
              AppSizes.pagePadding,
              AppSizes.sm,
              AppSizes.pagePadding,
              AppSizes.sm +
                  MediaQuery.of(context).viewInsets.bottom +
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.greyDark),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      hintStyle: const TextStyle(
                          color: AppColors.hintGrey, fontSize: 14),
                      filled: true,
                      fillColor: AppColors.greyVeryLight,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.lg, vertical: AppSizes.sm),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                            color: AppColors.primaryBlue, width: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.sm),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: AppColors.white, size: 20),
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
