import 'package:juris_honoris/features/ai_chat/domain/entities/ai_message.dart';
import 'package:juris_honoris/features/ai_chat/domain/entities/ai_response.dart';

/// Resultado genérico para operaciones que pueden fallar.
class Result<T> {
  final T? data;
  final String? error;

  const Result.success(T this.data) : error = null;
  const Result.failure(this.error) : data = null;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

abstract class AIRepository {
  Future<Result<AIResponse>> sendMessage({
    required String userMessage,
    required List<AIMessage> history,
  });

  /// Retorna true si hay un proveedor activo con API key configurada.
  bool get isConfigured;

  /// Fuerza la recarga de la configuración desde SharedPreferences.
  Future<void> reloadConfiguration();
}
