import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:juris_honoris/features/ai_chat/domain/entities/ai_message.dart';
import 'package:juris_honoris/features/ai_chat/domain/repositories/ai_repository.dart';

part 'chat_ia_state.dart';

const _uuid = Uuid();

class ChatIACubit extends Cubit<ChatIAState> {
  final AIRepository _repository;

  ChatIACubit({required AIRepository repository})
      : _repository = repository,
        super(const ChatIAInitial());

  bool get isConfigured => _repository.isConfigured;

  /// Envía un mensaje del usuario y espera la respuesta de la IA.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Obtiene la lista actual de mensajes.
    final currentMessages = state is ChatIALoaded
        ? List<AIMessage>.from((state as ChatIALoaded).messages)
        : <AIMessage>[];

    final bool? currentNeedsLawyer =
        state is ChatIALoaded ? (state as ChatIALoaded).lastNeedsLawyer : null;

    // 1. Agrega el mensaje del usuario.
    final userMessage = AIMessage(
      id: _uuid.v4(),
      content: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );
    currentMessages.add(userMessage);

    // 2. Agrega el placeholder de carga.
    final loadingMessage = AIMessage(
      id: _uuid.v4(),
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );
    currentMessages.add(loadingMessage);

    emit(ChatIALoaded(
      messages: List.unmodifiable(currentMessages),
      lastNeedsLawyer: currentNeedsLawyer,
    ));

    // 3. Recarga la configuración (puede haber cambiado desde el admin).
    await _repository.reloadConfiguration();

    // 4. Llama al repositorio.
    final result = await _repository.sendMessage(
      userMessage: trimmed,
      // Enviamos el historial sin el placeholder de loading.
      history: currentMessages
          .where((m) => !m.isLoading)
          .toList(),
    );

    // 5. Reemplaza el placeholder con la respuesta real o un error.
    final updatedMessages = List<AIMessage>.from(currentMessages)
      ..removeWhere((m) => m.id == loadingMessage.id);

    if (result.isSuccess) {
      final aiResponse = result.data!;
      final responseMessage = AIMessage(
        id: _uuid.v4(),
        content: aiResponse.cleanMessage,
        isUser: false,
        timestamp: DateTime.now(),
      );
      updatedMessages.add(responseMessage);

      emit(ChatIALoaded(
        messages: List.unmodifiable(updatedMessages),
        lastNeedsLawyer: aiResponse.needsLawyer,
      ));
    } else {
      emit(ChatIAError(
        error: result.error!,
        previousMessages: List.unmodifiable(updatedMessages),
      ));
    }
  }

  /// Limpia toda la conversación.
  void clearChat() {
    emit(const ChatIAInitial());
  }

  /// Recarga la configuración del proveedor activo.
  Future<void> reloadConfiguration() async {
    await _repository.reloadConfiguration();
  }
}
