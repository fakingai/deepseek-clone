part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class SendMessageEvent extends ChatEvent {
  final String content;
  final bool isDeepThinkingEnabled;
  final bool isWebSearchEnabled;

  const SendMessageEvent(this.content, {this.isDeepThinkingEnabled = false, this.isWebSearchEnabled = false});

  @override
  List<Object> get props => [content, isDeepThinkingEnabled, isWebSearchEnabled];
}

class ClearChatEvent extends ChatEvent {}

class CreateNewChatEvent extends ChatEvent {}

class LoadConversationEvent extends ChatEvent {
  final String conversationId;
  final String conversationTitle;
  final List<Message> messages;

  const LoadConversationEvent({
    required this.conversationId,
    required this.conversationTitle,
    required this.messages,
  });

  @override
  List<Object> get props => [conversationId, conversationTitle, messages];
}

class UpdateAssistantMessageEvent extends ChatEvent {
  final Message messageChunk;
  final String conversationId;
  final String conversationTitle;
  final String assistantLoadingMessageId;
  final bool isError;

  const UpdateAssistantMessageEvent(this.messageChunk, this.conversationId, this.conversationTitle, this.assistantLoadingMessageId, {this.isError = false});

  @override
  List<Object> get props => [messageChunk, conversationId, conversationTitle, assistantLoadingMessageId, isError];
}