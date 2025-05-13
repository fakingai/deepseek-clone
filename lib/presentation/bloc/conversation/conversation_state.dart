import 'package:equatable/equatable.dart';
import '../../../domain/entities/conversation.dart';

abstract class ConversationState extends Equatable {
  const ConversationState();

  @override
  List<Object> get props => [];
}

class ConversationInitial extends ConversationState {}

class ConversationLoading extends ConversationState {}

class ConversationLoaded extends ConversationState {
  final List<Conversation> sessions;
  final String? selectedSessionId;

  const ConversationLoaded({
    required this.sessions,
    this.selectedSessionId,
  });

  @override
  List<Object> get props => [sessions, selectedSessionId ?? ''];

  ConversationLoaded copyWith({
    List<Conversation>? sessions,
    String? selectedSessionId,
    bool clearSelectedSession = false,
  }) {
    return ConversationLoaded(
      sessions: sessions ?? this.sessions,
      selectedSessionId: clearSelectedSession ? null : (selectedSessionId ?? this.selectedSessionId),
    );
  }
}

class ConversationError extends ConversationState {
  final String message;

  const ConversationError({required this.message});

  @override
  List<Object> get props => [message];
}
