import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/features/chat/bloc/chat_cubit.dart';
import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/shared/widgets/message_bubble.dart';

class LawyerChatPage extends StatelessWidget {
  final String clientName;
  final String caseType;
  // caseId aquí es el request_id — nombre heredado por compatibilidad con el router
  final String caseId;

  const LawyerChatPage({
    super.key,
    required this.clientName,
    required this.caseType,
    required this.caseId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatCubit>(),
      child: _LawyerChatView(
        clientName: clientName,
        caseType: caseType,
        requestId: caseId,
      ),
    );
  }
}

class _LawyerChatView extends StatefulWidget {
  final String clientName;
  final String caseType;
  final String requestId;

  const _LawyerChatView({
    required this.clientName,
    required this.caseType,
    required this.requestId,
  });

  @override
  State<_LawyerChatView> createState() => _LawyerChatViewState();
}

class _LawyerChatViewState extends State<_LawyerChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().loadMessages(widget.requestId);
      context.read<ChatCubit>().markRead(widget.requestId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _currentUserId {
    final auth = context.read<AuthCubit>().state;
    if (auth is AuthAuthenticated) return auth.user.id;
    return '';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    context.read<ChatCubit>().sendMessage(widget.requestId, text);
    Future.delayed(const Duration(milliseconds: 200), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _closeCase() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
        title: const Text('Cerrar caso',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.greyDark,
                fontSize: 16)),
        content: const Text(
          '¿Estás seguro de que deseas cerrar este caso? Esta acción no se puede deshacer.',
          style:
              TextStyle(fontSize: 14, color: AppColors.subtitleGrey, height: 1.5),
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
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            onPressed: _closeCase,
            icon: const Icon(Icons.close, size: 16, color: AppColors.errorRed),
            label: const Text('Cerrar caso',
                style: TextStyle(
                    color: AppColors.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg, vertical: AppSizes.sm),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 12, color: AppColors.primaryBlue),
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

          Expanded(
            child: BlocConsumer<ChatCubit, ChatState>(
              listener: (context, state) {
                if (state is ChatLoaded) {
                  Future.delayed(
                      const Duration(milliseconds: 100), _scrollToBottom);
                }
              },
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primaryBlue),
                  );
                }
                if (state is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.greyMedium, size: 48),
                        const SizedBox(height: 12),
                        Text(state.message,
                            style: const TextStyle(
                                color: AppColors.subtitleGrey)),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => context
                              .read<ChatCubit>()
                              .loadMessages(widget.requestId),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }
                final messages =
                    state is ChatLoaded ? state.messages : <ChatMessage>[];
                final myId = _currentUserId;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Inicia la conversación con tu cliente',
                      style: TextStyle(
                          color: AppColors.subtitleGrey, fontSize: 14),
                    ),
                  );
                }
                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AppSizes.pagePadding),
                  itemCount: messages.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSizes.sm),
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    return MessageBubble(
                      message: msg.content,
                      isUser: msg.senderId == myId,
                      timestamp: msg.createdAt,
                    );
                  },
                );
              },
            ),
          ),

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
