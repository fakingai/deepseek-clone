import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deepseek/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:deepseek/domain/entities/message.dart';
import 'package:deepseek/domain/usecases/send_message.dart';
import 'package:deepseek/data/datasources/conversation_local_data_source.dart';
import 'package:deepseek/data/models/conversation_model.dart';
import 'package:deepseek/core/services/logger_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final SendMessage sendMessage;
  final ConversationLocalDataSource conversationLocalDataSource;
  final ConversationBloc conversationBloc;
  StreamSubscription<Message>? _messageStreamSubscription;

  ChatBloc({
    required this.sendMessage,
    required this.conversationLocalDataSource,
    required this.conversationBloc,
  }) : super(ChatInitial()) {
    on<SendMessageEvent>(_onSendMessage);
    on<ClearChatEvent>(_onClearChat);
    on<CreateNewChatEvent>(_onCreateNewChat);
    on<LoadConversationEvent>(_onLoadConversation);
    on<UpdateAssistantMessageEvent>(_onUpdateAssistantMessage);
  }

  @override
  Future<void> close() {
    _messageStreamSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    await _messageStreamSubscription?.cancel(); // Cancel any existing stream

    String conversationId;
    String conversationTitle;
    List<Message> currentMessages;

    if (state is ChatLoaded) {
      final loadedState = state as ChatLoaded;
      conversationId = loadedState.conversationId;
      conversationTitle = loadedState.conversationTitle;
      currentMessages = List<Message>.from(loadedState.messages);
    } else {
      final newConversation = ConversationModel.createNew();
      conversationId = newConversation.id;
      // Generate a temporary title or leave it to be updated later
      conversationTitle = "New Conversation"; // Placeholder, will be updated
      currentMessages = [];
      await conversationLocalDataSource.saveConversation(newConversation);
      // Notify ConversationBloc about the new conversation
    }

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: event.content,
      role: MessageRole.user,
      timestamp: DateTime.now(),
    );
    currentMessages.add(userMessage);

    // Emit state with user message and a loading indicator for assistant message
    final assistantLoadingMessageId = 'assistant_loading_${DateTime.now().millisecondsSinceEpoch}';
    final assistantLoadingMessage = Message(
      id: assistantLoadingMessageId,
      content: '', // Initially empty
      role: MessageRole.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
      isPartial: true, // Mark as partial initially
    );
    currentMessages.add(assistantLoadingMessage);

    emit(ChatLoaded(
      messages: List<Message>.from(currentMessages),
      conversationId: conversationId,
      conversationTitle: conversationTitle,
      lastMessageId: assistantLoadingMessageId,
    ));
    await _saveConversation(conversationId, conversationTitle, currentMessages);

    final messageHistoryForAPI = List<Message>.from(currentMessages.where((m) => m.id != assistantLoadingMessageId && !m.isLoading));

    _messageStreamSubscription = sendMessage(messageHistoryForAPI, isDeepThinkingEnabled: event.isDeepThinkingEnabled, isWebSearchEnabled: event.isWebSearchEnabled)
        .listen(
      (Message assistantMessageChunk) {
        add(UpdateAssistantMessageEvent(
            assistantMessageChunk, conversationId, conversationTitle, assistantLoadingMessageId));
      },
      onError: (error, stackTrace) {
        LoggerService().logError('Error in SSE stream', error: error, stackTrace: stackTrace);
        final errorMessage = Message(
          id: "error-${DateTime.now().millisecondsSinceEpoch}",
          content: 'Sorry, an error occurred: ${error.toString()}',
          role: MessageRole.assistant,
          timestamp: DateTime.now(),
          isLoading: false,
          isPartial: false,
        );
        add(UpdateAssistantMessageEvent(errorMessage, conversationId, conversationTitle, assistantLoadingMessageId, isError: true));
      },
      onDone: () {
        LoggerService().logInfo('SSE stream completed for conversation $conversationId');
        // The last partial message is considered final when onDone is called
        // Or handle finalization within _onUpdateAssistantMessage if a specific [DONE] marker is used
      },
    );
  }

  Future<void> _onUpdateAssistantMessage(UpdateAssistantMessageEvent event, Emitter<ChatState> emit) async {
    if (state is! ChatLoaded) return;

    final loadedState = state as ChatLoaded;
    List<Message> updatedMessages = List<Message>.from(loadedState.messages);
    String newConversationTitle = loadedState.conversationTitle;

    final assistantMessageChunk = event.messageChunk;

    // Find the existing assistant message (it might be the loading one or a partial one)
    final existingAssistantMessageIndex = updatedMessages.indexWhere(
        (m) => m.role == MessageRole.assistant && (m.id == event.assistantLoadingMessageId || m.isPartial));

    if (existingAssistantMessageIndex != -1) {
      final currentAssistantMessage = updatedMessages[existingAssistantMessageIndex];
      if (event.isError) {
         updatedMessages[existingAssistantMessageIndex] = assistantMessageChunk.copyWith(isLoading: false, isPartial: false);
      } else if (assistantMessageChunk.isPartial) {
        // Update existing partial message
        updatedMessages[existingAssistantMessageIndex] = currentAssistantMessage.copyWith(
          content: assistantMessageChunk.content, // Accumulate content
          timestamp: assistantMessageChunk.timestamp,
          isLoading: true, // Still loading as it's partial
          isPartial: true,
        );
      } else {
        // Final message chunk
        updatedMessages[existingAssistantMessageIndex] = assistantMessageChunk.copyWith(
          isLoading: false,
          isPartial: false,
        );
      }
    } else if (!event.isError) { 
      // Should not happen if loading message was added, but as a fallback:
      updatedMessages.add(assistantMessageChunk.copyWith(isLoading: !assistantMessageChunk.isPartial, isPartial: assistantMessageChunk.isPartial));
    }
    
    // Update conversation title if it's the first proper exchange and title hasn't been set meaningfully
    if (updatedMessages.where((m) => m.role == MessageRole.user || (m.role == MessageRole.assistant && !m.isPartial && !m.isLoading)).length == 2 &&
        (newConversationTitle == "New Conversation" || newConversationTitle.startsWith("Chat on"))) {
      final userMessageContent = updatedMessages.firstWhere((m) => m.role == MessageRole.user, orElse: () => Message(id: '', content: 'Untitled', role: MessageRole.user, timestamp: DateTime.now())).content;
      newConversationTitle = userMessageContent.length > 20
          ? '${userMessageContent.substring(0, 20)}...'
          : userMessageContent;
      if (newConversationTitle.isEmpty) newConversationTitle = "Chat"; // Fallback for empty user message
    }

    emit(ChatLoaded(
      messages: updatedMessages,
      conversationId: event.conversationId,
      conversationTitle: newConversationTitle,
      lastMessageId: assistantMessageChunk.id,
    ));

    // Save conversation after each update (or consider saving only onDone/onError for efficiency)
    await _saveConversation(event.conversationId, newConversationTitle, updatedMessages); 
  }

  void _onClearChat(ClearChatEvent event, Emitter<ChatState> emit) {
    _messageStreamSubscription?.cancel();
    emit(ChatInitial());
  }

  Future<void> _onCreateNewChat(CreateNewChatEvent event, Emitter<ChatState> emit) async {
    _messageStreamSubscription?.cancel();
    emit(ChatInitial());
    // Potentially trigger a new conversation creation in local storage if needed immediately
    // or let _onSendMessage handle it.
  }

  Future<void> _saveConversation(
    String id,
    String title,
    List<Message> messages,
  ) async {
    // Filter out any purely loading messages before saving
    final messagesToSave = messages.where((m) => !(m.isLoading && m.content.isEmpty)).toList();

    ConversationModel? existingConversationModel = await conversationLocalDataSource.getConversation(id);
    DateTime createdAtTime = existingConversationModel?.createdAt ?? DateTime.now();
    
    final conversationToSave = ConversationModel(
      id: id,
      title: title,
      messages: messagesToSave,
      createdAt: createdAtTime,
      updatedAt: DateTime.now(),
    );
    await conversationLocalDataSource.saveConversation(conversationToSave);
  }

  void _onLoadConversation(
    LoadConversationEvent event,
    Emitter<ChatState> emit,
  ) {
    _messageStreamSubscription?.cancel();
    // Ensure no messages are marked as loading or partial when loading a conversation
    final cleanedMessages = event.messages.map((m) => m.copyWith(isLoading: false, isPartial: false)).toList();
    emit(ChatLoaded(
      messages: cleanedMessages,
      conversationId: event.conversationId,
      conversationTitle: event.conversationTitle,
      lastMessageId: cleanedMessages.isNotEmpty ? cleanedMessages.last.id : '',
    ));
  }
}
