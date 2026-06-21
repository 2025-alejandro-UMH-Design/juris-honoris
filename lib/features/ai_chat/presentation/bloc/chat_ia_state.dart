part of 'chat_ia_cubit.dart';

sealed class ChatIAState extends Equatable {
  const ChatIAState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial — no hay mensajes, bienvenida vacía.
final class ChatIAInitial extends ChatIAState {
  const ChatIAInitial();
}

/// Estado de carga inicial (primera vez que se abre el chat).
final class ChatIALoading extends ChatIAState {
  const ChatIALoading();
}

/// Estado con mensajes cargados.
final class ChatIALoaded extends ChatIAState {
  final List<AIMessage> messages;

  /// null si la IA aún no respondió, true/false según la última respuesta.
  final bool? lastNeedsLawyer;

  /// Especialidad jurídica detectada por la IA (solo cuando lastNeedsLawyer == true).
  final String? lastSpecialty;

  const ChatIALoaded({
    required this.messages,
    this.lastNeedsLawyer,
    this.lastSpecialty,
  });

  @override
  List<Object?> get props => [messages, lastNeedsLawyer, lastSpecialty];
}

/// Estado de error — conserva los mensajes anteriores para no limpiar el chat.
final class ChatIAError extends ChatIAState {
  final String error;
  final List<AIMessage> previousMessages;

  const ChatIAError({
    required this.error,
    this.previousMessages = const [],
  });

  @override
  List<Object?> get props => [error, previousMessages];
}
