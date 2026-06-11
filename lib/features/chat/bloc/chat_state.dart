part of 'chat_cubit.dart';

class ChatMessage extends Equatable {
  final String id;
  final String requestId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.requestId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) {
    return ChatMessage(
      id: j['id']?.toString() ?? '',
      requestId: j['request_id']?.toString() ?? '',
      senderId: j['sender_id']?.toString() ?? '',
      senderName: j['sender_name']?.toString() ?? '',
      senderRole: j['sender_role']?.toString() ?? '',
      content: j['content']?.toString() ?? '',
      isRead: j['is_read'] == true,
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, content, isRead];
}

abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  const ChatLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);
  @override
  List<Object?> get props => [message];
}
