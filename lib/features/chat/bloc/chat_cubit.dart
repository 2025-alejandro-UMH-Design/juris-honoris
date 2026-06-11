import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:juris_honoris/core/constants/api_config.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final Dio _dio;
  Timer? _pollTimer;

  ChatCubit({required Dio dio})
      : _dio = dio,
        super(const ChatInitial());

  Future<void> loadMessages(String requestId) async {
    emit(const ChatLoading());
    await _fetchMessages(requestId);
    _startPolling(requestId);
  }

  Future<void> sendMessage(String requestId, String content) async {
    try {
      final res = await _dio.post(
        '${ApiConfig.chat}/$requestId/messages',
        data: {'content': content},
      );
      final msg = ChatMessage.fromJson(res.data as Map<String, dynamic>);
      final current = state is ChatLoaded ? (state as ChatLoaded).messages : <ChatMessage>[];
      emit(ChatLoaded([...current, msg]));
    } catch (_) {}
  }

  Future<void> markRead(String requestId) async {
    try {
      await _dio.put('${ApiConfig.chat}/$requestId/messages/read');
    } catch (_) {}
  }

  void _startPolling(String requestId) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!isClosed) _fetchMessages(requestId);
    });
  }

  Future<void> _fetchMessages(String requestId) async {
    try {
      final res = await _dio.get('${ApiConfig.chat}/$requestId/messages');
      final messages = (res.data as List)
          .map((j) => ChatMessage.fromJson(j as Map<String, dynamic>))
          .toList();
      if (!isClosed) emit(ChatLoaded(messages));
    } on DioException catch (e) {
      if (!isClosed) {
        final msg = e.response?.data?['error'] ?? 'Error al cargar mensajes';
        emit(ChatError(msg.toString()));
      }
    } catch (_) {
      if (!isClosed) emit(const ChatError('Error al cargar mensajes'));
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
