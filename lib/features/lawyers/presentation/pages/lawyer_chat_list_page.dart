import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/api_config.dart';
import 'package:juris_honoris/core/constants/app_colors.dart';
import 'package:juris_honoris/core/constants/app_sizes.dart';
import 'package:juris_honoris/features/chat/bloc/chat_cubit.dart';
import 'package:juris_honoris/injection_container.dart';
import 'package:juris_honoris/shared/widgets/app_card.dart';

import 'lawyer_chat_page.dart';

class LawyerChatListPage extends StatefulWidget {
  const LawyerChatListPage({super.key});

  @override
  State<LawyerChatListPage> createState() => _LawyerChatListPageState();
}

class _LawyerChatListPageState extends State<LawyerChatListPage> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final dio = sl<Dio>();
      final res = await dio.get(
        ApiConfig.requests,
        queryParameters: {'status': 'accepted'},
      );
      if (!mounted) return;
      setState(() {
        _conversations = List<Map<String, dynamic>>.from(res.data as List);
        _isLoading = false;
      });
    } on DioException catch (_) {
      if (mounted) setState(() { _isLoading = false; _errorMsg = 'Error al cargar conversaciones'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(
              color: AppColors.greyDark,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
            onPressed: _loadConversations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMsg!,
                          style: const TextStyle(color: AppColors.greyMedium)),
                      const SizedBox(height: AppSizes.md),
                      TextButton(
                          onPressed: _loadConversations,
                          child: const Text('Reintentar')),
                    ],
                  ),
                )
              : _conversations.isEmpty
                  ? const _EmptyChats()
                  : RefreshIndicator(
                      onRefresh: _loadConversations,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.pagePadding),
                        itemCount: _conversations.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSizes.sm),
                        itemBuilder: (_, i) =>
                            _ConversationCard(data: _conversations[i]),
                      ),
                    ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ConversationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final clientName = data['client_name'] as String? ?? 'Cliente';
    final caseType = data['case_type'] as String? ?? 'Caso legal';
    final requestId = data['id'] as String;
    final rawDate =
        (data['responded_at'] as String?) ?? (data['created_at'] as String? ?? '');
    final date = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
    final initials = clientName.isNotEmpty ? clientName[0].toUpperCase() : '?';

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<ChatCubit>(),
            child: LawyerChatPage(
              caseId: requestId,
              clientName: clientName,
              caseType: caseType,
            ),
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
            radius: 26,
            child: Text(
              initials,
              style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clientName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greyDark),
                ),
                const SizedBox(height: 3),
                Text(
                  caseType,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.subtitleGrey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(date,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.greyMedium)),
              const SizedBox(height: 6),
              const Icon(Icons.arrow_forward_ios,
                  size: 13, color: AppColors.primaryBlue),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyChats extends StatelessWidget {
  const _EmptyChats();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline_rounded,
                size: 64, color: AppColors.greyLight),
            SizedBox(height: AppSizes.md),
            Text(
              'Sin conversaciones activas',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.greyMedium),
            ),
            SizedBox(height: AppSizes.sm),
            Text(
              'Cuando aceptes una solicitud, el chat con el cliente aparecerá aquí.',
              style: TextStyle(fontSize: 13, color: AppColors.subtitleGrey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
