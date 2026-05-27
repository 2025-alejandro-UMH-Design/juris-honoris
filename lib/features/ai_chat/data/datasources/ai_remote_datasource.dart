import 'package:dio/dio.dart';
import 'package:juris_honoris/features/ai_chat/domain/entities/ai_provider_type.dart';

abstract class AIRemoteDatasource {
  Future<String> sendMessage({
    required String apiKey,
    required String model,
    required String baseUrl,
    required AIProviderType providerType,
    required List<Map<String, String>> messages,
  });
}

class AIRemoteDatasourceImpl implements AIRemoteDatasource {
  final Dio _dio;

  AIRemoteDatasourceImpl({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 10),
              ),
            );

  @override
  Future<String> sendMessage({
    required String apiKey,
    required String model,
    required String baseUrl,
    required AIProviderType providerType,
    required List<Map<String, String>> messages,
  }) async {
    if (providerType == AIProviderType.anthropic) {
      return _sendAnthropicMessage(
        apiKey: apiKey,
        model: model,
        messages: messages,
      );
    } else {
      return _sendOpenAICompatibleMessage(
        apiKey: apiKey,
        model: model,
        baseUrl: baseUrl,
        messages: messages,
      );
    }
  }

  /// Formato estándar compatible con OpenAI (Groq, OpenAI, DeepSeek).
  Future<String> _sendOpenAICompatibleMessage({
    required String apiKey,
    required String model,
    required String baseUrl,
    required List<Map<String, String>> messages,
  }) async {
    try {
      final response = await _dio.post(
        baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model,
          'messages': messages,
          'max_tokens': 1024,
          'temperature': 0.7,
        },
      );

      final content = response.data['choices']?[0]?['message']?['content'];
      if (content == null) {
        throw Exception('Respuesta del proveedor sin contenido válido.');
      }
      return content as String;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Formato específico de Anthropic (Claude).
  Future<String> _sendAnthropicMessage({
    required String apiKey,
    required String model,
    required List<Map<String, String>> messages,
  }) async {
    // Anthropic espera el system prompt por separado.
    // Filtramos los mensajes de sistema del array messages.
    final systemMessages = messages
        .where((m) => m['role'] == 'system')
        .map((m) => m['content'] ?? '')
        .join('\n');

    final userMessages = messages
        .where((m) => m['role'] != 'system')
        .toList();

    try {
      final Map<String, dynamic> body = {
        'model': model,
        'messages': userMessages,
        'max_tokens': 1024,
      };

      if (systemMessages.isNotEmpty) {
        body['system'] = systemMessages;
      }

      final response = await _dio.post(
        AIProviderType.anthropic.baseUrl,
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
        ),
        data: body,
      );

      final content = response.data['content']?[0]?['text'];
      if (content == null) {
        throw Exception('Respuesta de Anthropic sin contenido válido.');
      }
      return content as String;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Traduce errores de Dio a mensajes amigables en español.
  Exception _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'La conexión tardó demasiado. Verificá tu internet e intentá de nuevo.',
        );
      case DioExceptionType.connectionError:
        return Exception(
          'No se pudo conectar al servicio de IA. Verificá tu conexión a internet.',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return Exception(
            'API Key inválida o expirada. Revisá la configuración en el panel de administración.',
          );
        }
        if (statusCode == 429) {
          return Exception(
            'Límite de solicitudes alcanzado. Esperá unos minutos e intentá de nuevo.',
          );
        }
        if (statusCode != null && statusCode >= 500) {
          return Exception(
            'El servicio de IA está temporalmente no disponible. Intentá más tarde.',
          );
        }
        final errorMsg = e.response?.data?['error']?['message'] ??
            e.response?.data?['detail'] ??
            'Error desconocido del proveedor.';
        return Exception('Error del proveedor ($statusCode): $errorMsg');
      default:
        return Exception(
          'Error inesperado al contactar el servicio de IA.',
        );
    }
  }
}
