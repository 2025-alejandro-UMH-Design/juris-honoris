import 'package:dio/dio.dart';
import 'package:juris_honoris/core/constants/api_config.dart';
import 'package:juris_honoris/features/ai_chat/domain/entities/ai_message.dart';
import 'package:juris_honoris/features/ai_chat/domain/entities/ai_response.dart';
import 'package:juris_honoris/features/ai_chat/domain/repositories/ai_repository.dart';

class AIRepositoryImpl implements AIRepository {
  final Dio _dio;

  bool _isConfigured = false;

  AIRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  bool get isConfigured => _isConfigured;

  @override
  Future<void> reloadConfiguration() async {
    try {
      final res = await _dio.get('${ApiConfig.aiChat}/status');
      _isConfigured = res.data['configured'] == true;
    } catch (_) {
      _isConfigured = false;
    }
  }

  @override
  Future<Result<AIResponse>> sendMessage({
    required String userMessage,
    required List<AIMessage> history,
  }) async {
    try {
      final historyPayload = history
          .where((m) => !m.isLoading)
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.content})
          .toList();

      final res = await _dio.post(
        '${ApiConfig.aiChat}/message',
        data: {'message': userMessage, 'history': historyPayload},
      );

      final raw = '${res.data['response']}'
          '${res.data['needs_lawyer'] == true ? ' [NECESITA_ABOGADO: SI]' : res.data['needs_lawyer'] == false ? ' [NECESITA_ABOGADO: NO]' : ''}';

      return Result.success(AIResponse.fromRaw(raw));
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] ?? 'Error de conexión con el servidor';
      return Result.failure(msg.toString());
    } catch (e) {
      return Result.failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
