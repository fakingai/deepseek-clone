import 'package:deepseek/domain/entities/message.dart';

class MessageModel extends Message {
  const MessageModel({
    required String id,
    required String content,
    required MessageRole role,
    required DateTime timestamp,
    bool isLoading = false,
    bool isPartial = false, // Added field
  }) : super(
          id: id,
          content: content,
          role: role,
          timestamp: timestamp,
          isLoading: isLoading,
          isPartial: isPartial, // Added field
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? '',
      role: _mapRole(json['role']),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      isLoading: json['isLoading'] ?? false,
      isPartial: json['isPartial'] ?? false, // Added field
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
      'isLoading': isLoading,
      'isPartial': isPartial, // Added field
    };
  }

  static MessageRole _mapRole(String? role) {
    switch (role) {
      case 'user':
        return MessageRole.user;
      case 'assistant':
        return MessageRole.assistant;
      case 'system':
        return MessageRole.system;
      default:
        return MessageRole.user;
    }
  }
}
