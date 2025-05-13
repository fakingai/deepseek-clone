import 'package:equatable/equatable.dart';

class ChatSession extends Equatable {
  final String id;
  final String title;
  final DateTime lastUpdated;
  final List<String> messageIds; // Reference to messages in this session

  const ChatSession({
    required this.id,
    required this.title,
    required this.lastUpdated,
    required this.messageIds,
  });

  @override
  List<Object> get props => [id, title, lastUpdated, messageIds];
  
  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? lastUpdated,
    List<String>? messageIds,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      messageIds: messageIds ?? this.messageIds,
    );
  }
}
