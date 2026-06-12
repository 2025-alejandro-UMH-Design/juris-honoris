import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/ai_chat/domain/entities/ai_message.dart';
import 'package:juris_honoris/features/ai_chat/presentation/bloc/chat_ia_cubit.dart';
import 'package:juris_honoris/features/ai_chat/presentation/widgets/action_buttons_bar.dart';
import 'package:juris_honoris/features/ai_chat/presentation/widgets/ai_message_bubble.dart';
import 'package:juris_honoris/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:juris_honoris/shared/widgets/bottom_nav_bar.dart';

import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/features/tasks/presentation/bloc/cases_cubit.dart';

import 'ai_result_page.dart';

class ChatIAPage extends StatefulWidget {
  const ChatIAPage({super.key});

  @override
  State<ChatIAPage> createState() => _ChatIAPageState();
}

class _ChatIAPageState extends State<ChatIAPage> {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final _focusNode = FocusNode();

  static const _suggestions = [
    '¿Qué documentos necesito para un divorcio?',
    '¿Cómo tramitar la custodia de mis hijos?',
    'Proceso de herencia en Honduras',
    'Mis derechos como trabajador',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ChatIACubit>().reloadConfiguration();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
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

  void _sendMessage([String? text]) {
    final content = (text ?? _inputController.text).trim();
    if (content.isEmpty) return;
    _inputController.clear();
    _focusNode.unfocus();
    context.read<ChatIACubit>().sendMessage(content);
    _scrollToBottom();
  }

  void _clearChat(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar conversación'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar todo el historial del chat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Limpiar',
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<ChatIACubit>().clearChat();
      }
    });
  }

  void _onNavChanged(int index) {
    switch (index) {
      case 0: context.go('/home');
      case 2: context.go('/tasks');
      case 3: context.go('/dossier');
      default: break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.greyVeryLight,
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTabChanged: _onNavChanged,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.balance, color: AppColors.white, size: 18),
            ),
            const SizedBox(width: AppSizes.sm),
            const Text(
              'Chat con Juris IA',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Limpiar conversación',
            onPressed: () => _clearChat(context),
          ),
        ],
      ),
      body: BlocConsumer<ChatIACubit, ChatIAState>(
        listener: (context, state) {
          if (state is ChatIALoaded) {
            _scrollToBottom();
          }
          if (state is ChatIAError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.errorRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isConfigured = context.read<ChatIACubit>().isConfigured;
          final isAdmin = context.read<AuthCubit>().isAdmin;

          // ── Not configured banner ──────────────────────────────────
          if (!isConfigured) {
            return _NotConfiguredView(isAdmin: isAdmin);
          }

          // ── Derive messages and typing state ───────────────────────
          final List<AIMessage> messages;
          final bool isTyping;
          final bool? lastNeedsLawyer;

          if (state is ChatIALoaded) {
            messages = state.messages;
            isTyping = state.messages.any((m) => m.isLoading);
            lastNeedsLawyer = state.lastNeedsLawyer;
          } else if (state is ChatIAError) {
            messages = state.previousMessages;
            isTyping = false;
            lastNeedsLawyer = null;
          } else {
            messages = const [];
            isTyping = false;
            lastNeedsLawyer = null;
          }

          // ── All messages including the static welcome ──────────────
          final allMessages = [
            AIMessage(
              id: 'welcome',
              content:
                  'Hola, soy Juris, tu asistente legal. ¿En qué puedo ayudarte hoy?',
              isUser: false,
              timestamp: DateTime(2020),
            ),
            ...messages,
          ];

          final showSuggestions = messages.isEmpty;

          return Column(
            children: [
              // ── Message list ───────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.md,
                  ),
                  itemCount: allMessages.length + (showSuggestions ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Suggestions row at the bottom of the initial state
                    if (showSuggestions && index == allMessages.length) {
                      return _SuggestionsRow(
                        suggestions: _suggestions,
                        onTap: _sendMessage,
                      );
                    }

                    final msg = allMessages[index];
                    final isLast = index == allMessages.length - 1;
                    return AIMessageBubble(
                      message: msg,
                      needsLawyer:
                          isLast && !msg.isUser ? lastNeedsLawyer : null,
                    );
                  },
                ),
              ),

              // ── Action buttons bar ─────────────────────────────────
              if (lastNeedsLawyer != null && !isTyping)
                ActionButtonsBar(
                  needsLawyer: lastNeedsLawyer,
                  onPrimaryAction: () => _navigateToResult(
                    context,
                    needsLawyer: lastNeedsLawyer!,
                    summary: messages.isNotEmpty ? messages.last.content : '',
                  ),
                  onSecondaryAction: () => _navigateToResult(
                    context,
                    needsLawyer: lastNeedsLawyer!,
                    summary: messages.isNotEmpty ? messages.last.content : '',
                  ),
                ),

              // ── Input bar ──────────────────────────────────────────
              _InputBar(
                controller: _inputController,
                focusNode: _focusNode,
                isTyping: isTyping,
                onSend: _sendMessage,
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToResult(
    BuildContext context, {
    required bool needsLawyer,
    required String summary,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => sl<CasesCubit>(),
          child: AIResultPage(
            consultaSummary: summary,
            needsLawyer: needsLawyer,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Widgets locales
// ─────────────────────────────────────────────────────────────────────────────

class _NotConfiguredView extends StatelessWidget {
  final bool isAdmin;

  const _NotConfiguredView({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFF57F17),
                  size: 22,
                ),
                const SizedBox(width: AppSizes.sm),
                Expanded(
                  child: Text(
                    'El Chat IA no está configurado. El administrador debe activar un proveedor de IA.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFF57F17),
                        ),
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: AppSizes.xl),
            ElevatedButton.icon(
              onPressed: () {
                // Navegar al panel admin — el router lo gestiona
                context.go('/admin');
              },
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: const Text('Ir al panel admin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SuggestionsRow extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onTap;

  const _SuggestionsRow({
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: AppSizes.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preguntas frecuentes',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.greyMedium,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.sm,
            runSpacing: AppSizes.sm,
            children: suggestions.map((s) {
              return GestureDetector(
                onTap: () => onTap(s),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.greyDark.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    s,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isTyping;
  final ValueChanged<String?> onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isTyping,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: const Border(
          top: BorderSide(color: AppColors.borderColor),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyDark.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSizes.inputHeight,
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  maxLines: 4,
                  minLines: 1,
                  enabled: !isTyping,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.greyDark,
                  ),
                  decoration: InputDecoration(
                    hintText: isTyping
                        ? 'Juris está escribiendo...'
                        : 'Escribe tu consulta legal...',
                    hintStyle: const TextStyle(
                      color: AppColors.placeholder,
                      fontSize: 14,
                    ),
                    filled: true,
                    fillColor: AppColors.greyVeryLight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.md,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.inputRadius * 3),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.inputRadius * 3),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSizes.inputRadius * 3),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSizes.sm),
            _SendButton(
              isTyping: isTyping,
              onPressed: () => onSend(null),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isTyping;
  final VoidCallback onPressed;

  const _SendButton({required this.isTyping, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isTyping ? AppColors.greyLight : AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: isTyping ? null : onPressed,
          child: Center(
            child: isTyping
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.greyMedium),
                    ),
                  )
                : const Icon(
                    Icons.send_rounded,
                    color: AppColors.white,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
