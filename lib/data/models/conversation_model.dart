import 'package:deepseek/domain/entities/conversation.dart';
import 'package:deepseek/data/models/message_model.dart';
import 'package:deepseek/domain/entities/message.dart';

class ConversationModel extends Conversation {
  ConversationModel({
    required String id,
    required String title,
    required List<Message> messages,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          title: title,
          messages: messages,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List)
          .map((message) => MessageModel.fromJson(message))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((message) {
        if (message is MessageModel) {
          return message.toJson();
        }
        // Convert domain entity to model
        return MessageModel(
          id: message.id,
          content: message.content,
          role: message.role,
          timestamp: message.timestamp,
          isLoading: message.isLoading,
        ).toJson();
      }).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a new empty conversation
  factory ConversationModel.createNew() {
    final DateTime now = DateTime.now();
    return ConversationModel(
      id: now.millisecondsSinceEpoch.toString(),
      title: '新对话', // Default title - "New Conversation"
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
  }
  
  // Convert from domain entity to model
  factory ConversationModel.fromEntity(Conversation conversation) {
    return ConversationModel(
      id: conversation.id,
      title: conversation.title,
      messages: conversation.messages,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
    );
  }
}
