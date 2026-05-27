import 'package:equatable/equatable.dart';

class AIMessage extends Equatable {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  const AIMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.isLoading = false,
  });

  AIMessage copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    bool? isLoading,
  }) {
    return AIMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [id, content, isUser, timestamp, isLoading];
}
