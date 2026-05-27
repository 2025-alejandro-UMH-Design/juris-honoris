import 'package:juris_honoris/features/ai_chat/data/datasources/ai_local_datasource.dart';
import 'package:juris_honoris/features/ai_chat/data/datasources/ai_remote_datasource.dart';
import 'package:juris_honoris/features/ai_chat/domain/entities/ai_message.dart';
import 'package:juris_honoris/features/ai_chat/domain/entities/ai_provider_type.dart';
import 'package:juris_honoris/features/ai_chat/domain/entities/ai_response.dart';
import 'package:juris_honoris/features/ai_chat/domain/repositories/ai_repository.dart';

/// System prompt legal para Juris, el asistente de Juris Honoris.
const String _systemPrompt = '''
Eres Juris, un asistente legal especializado en el sistema jurídico de Honduras.
Tu función es orientar e informar a las personas sobre trámites legales, procesos judiciales,
derechos y obligaciones bajo la legislación hondureña.

Responde siempre en español claro y accesible. Sé preciso pero evita tecnicismos innecesarios.

Al final de CADA respuesta, incluye obligatoriamente una de estas dos líneas:
- Si el caso requiere representación legal o asesoría profesional de abogado: [NECESITA_ABOGADO: SI]
- Si el usuario puede gestionar el trámite por sí mismo: [NECESITA_ABOGADO: NO]

IMPORTANTE: No proporcionas representación legal, solo orientación informativa.
''';

/// Número máximo de mensajes del historial a enviar (para no exceder tokens).
const int _maxHistoryMessages = 10;

class AIRepositoryImpl implements AIRepository {
  final AIRemoteDatasource _remoteDatasource;
  final AILocalDatasource _localDatasource;

  bool _configLoaded = false;
  bool _isConfigured = false;

  AIRepositoryImpl({
    required AIRemoteDatasource remoteDatasource,
    required AILocalDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  @override
  bool get isConfigured => _isConfigured;

  @override
  Future<void> reloadConfiguration() async {
    _isConfigured = await _localDatasource.isAnyProviderConfigured();
    _configLoaded = true;
  }

  @override
  Future<Result<AIResponse>> sendMessage({
    required String userMessage,
    required List<AIMessage> history,
  }) async {
    // Carga la configuración si aún no se ha hecho.
    if (!_configLoaded) {
      await reloadConfiguration();
    }

    // Verifica que haya un proveedor configurado.
    final activeKey = await _localDatasource.getActiveProviderKey();
    if (activeKey == null || activeKey.isEmpty) {
      return const Result.failure(
        'No hay ningún proveedor de IA configurado. '
        'Contactá al administrador para configurar uno.',
      );
    }

    final apiKey = await _localDatasource.getApiKey(activeKey);
    if (apiKey == null || apiKey.isEmpty) {
      return const Result.failure(
        'El proveedor de IA no tiene una API Key configurada. '
        'Contactá al administrador.',
      );
    }

    final providerType = AIProviderType.fromKey(activeKey);
    if (providerType == null) {
      return Result.failure('Proveedor de IA desconocido: "$activeKey".');
    }

    // Obtiene el modelo configurado o usa el modelo por defecto del proveedor.
    final savedModel = await _localDatasource.getModel(activeKey);
    final model = (savedModel != null && savedModel.isNotEmpty)
        ? savedModel
        : providerType.defaultModel;

    // Construye el array de mensajes con el historial (últimos _maxHistoryMessages).
    final messages = _buildMessages(
      history: history,
      userMessage: userMessage,
      providerType: providerType,
    );

    try {
      final rawResponse = await _remoteDatasource.sendMessage(
        apiKey: apiKey,
        model: model,
        baseUrl: providerType.baseUrl,
        providerType: providerType,
        messages: messages,
      );

      final aiResponse = AIResponse.fromRaw(rawResponse);
      return Result.success(aiResponse);
    } catch (e) {
      return Result.failure(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  /// Construye la lista de mensajes en el formato esperado por los proveedores.
  ///
  /// Para Anthropic, el system prompt se envía también aquí como role=system
  /// pero el datasource lo separa internamente.
  List<Map<String, String>> _buildMessages({
    required List<AIMessage> history,
    required String userMessage,
    required AIProviderType providerType,
  }) {
    final messages = <Map<String, String>>[];

    // El system prompt va primero.
    messages.add({'role': 'system', 'content': _systemPrompt});

    // Incluye solo los últimos _maxHistoryMessages mensajes del historial
    // para evitar exceder el límite de tokens.
    final recentHistory = history.length > _maxHistoryMessages
        ? history.sublist(history.length - _maxHistoryMessages)
        : history;

    for (final msg in recentHistory) {
      // Omite mensajes de carga (placeholder del loading state).
      if (msg.isLoading) continue;

      messages.add({
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.content,
      });
    }

    // Agrega el mensaje actual del usuario.
    messages.add({'role': 'user', 'content': userMessage});

    return messages;
  }
}
