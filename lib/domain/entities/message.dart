import 'package:equatable/equatable.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

class Message extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final bool isLoading;
  final bool isPartial; // Added field

  const Message({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.isLoading = false,
    this.isPartial = false, // Added field
  });

  @override
  List<Object?> get props => [id, content, role, timestamp, isLoading, isPartial]; // Updated props

  Message copyWith({ // Added copyWith
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    bool? isLoading,
    bool? isPartial,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isLoading: isLoading ?? this.isLoading,
      isPartial: isPartial ?? this.isPartial,
    );
  }
}
