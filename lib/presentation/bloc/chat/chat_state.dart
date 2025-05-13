part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();
  
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoaded extends ChatState {
  final String conversationId;
  final String conversationTitle;
  final List<Message> messages;
  final String lastMessageId;

  const ChatLoaded({
    required this.conversationId,
    required this.conversationTitle,
    required this.lastMessageId,
    required this.messages,
  });

  @override
  List<Object> get props => [conversationId, conversationTitle, lastMessageId, messages];
}
