import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/conversation.dart';
import '../../../domain/usecases/get_chat_sessions.dart';
import '../../../domain/usecases/rename_chat_session.dart';
import '../../../domain/usecases/delete_conversation.dart';
import '../../../domain/usecases/get_conversation_by_id.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final GetConversations getConversations;
  final RenameConversation renameConversation;
  final DeleteConversation deleteConversation;
  final GetConversationById getConversationById;

  ConversationBloc({
    required this.getConversations,
    required this.renameConversation,
    required this.deleteConversation,
    required this.getConversationById,
  }) : super(ConversationInitial()) {
    on<GetConversationsEvent>(_onGetConversations);
    on<RenameConversationEvent>(_onRenameConversation);
    on<DeleteConversationEvent>(_onDeleteConversation);
    on<SelectConversationEvent>(_onSelectConversation);
  }

  Future<void> _onGetConversations(
    GetConversationsEvent event,
    Emitter<ConversationState> emit,
  ) async {
    String? currentSelectedId;
    List<Conversation> previousSessions = [];

    if (state is ConversationLoaded) {
      final loadedState = state as ConversationLoaded;
      currentSelectedId = loadedState.selectedSessionId;
      emit(ConversationLoading());
    } 

    final result = await getConversations(const NoParams());

    result.fold(
      (failure) {
        emit(const ConversationError(message: 'Failed to load chat sessions'));
      },
      (sessions) {
        print("GetConversationsEvent: ${sessions.length}");
        emit(ConversationLoaded(
          sessions: sessions,
          selectedSessionId: currentSelectedId,
        ));
      }
    );
  }

  Future<void> _onRenameConversation(
    RenameConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationLoaded) {
      emit(currentState.copyWith());

      final result = await renameConversation(
        RenameParams(id: event.id, newTitle: event.newTitle),
      );

      result.fold(
        (failure) {
          emit(const ConversationError(message: 'Failed to rename chat session'));
          emit(currentState);
        },
        (renamedSession) {
          final updatedSessions = currentState.sessions.map((session) {
            return session.id == renamedSession.id ? renamedSession : session;
          }).toList();
          emit(ConversationLoaded(
            sessions: updatedSessions,
            selectedSessionId: currentState.selectedSessionId,
          ));
        },
      );
    }
  }

  Future<void> _onDeleteConversation(
    DeleteConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    if (currentState is ConversationLoaded) {
      emit(currentState.copyWith());

      final result = await deleteConversation(DeleteParams(id: event.id));

      result.fold(
        (failure) {
          emit(const ConversationError(message: 'Failed to delete chat session'));
          emit(currentState);
        },
        (success) {
          final updatedSessions = currentState.sessions
              .where((session) => session.id != event.id)
              .toList();
          String? newSelectedSessionId = currentState.selectedSessionId;
          if (currentState.selectedSessionId == event.id) {
            newSelectedSessionId = null;
          }
          emit(ConversationLoaded(
            sessions: updatedSessions,
            selectedSessionId: newSelectedSessionId,
          ));
        },
      );
    }
  }

  Future<void> _onSelectConversation(
    SelectConversationEvent event,
    Emitter<ConversationState> emit,
  ) async {
    final currentState = state;
    print("_onSelectConversation: ${event.id}");
    print(currentState);
    
    if (currentState is ConversationLoaded) {
        print("_onSelectConversation: success, ${event.id}");
        emit(ConversationLoaded(
          sessions: currentState.sessions,
          selectedSessionId: event.id
        ));
    } else if (currentState is ConversationInitial || currentState is ConversationError) {
      emit(ConversationLoading());
      final sessionsResult = await getConversations(const NoParams());
      sessionsResult.fold(
        (failure) => emit(const ConversationError(message: 'Failed to load chat sessions')),
        (sessions) {
          _loadAndEmitMessages(event.id, sessions, emit);
        }
      );
    }
  }

  Future<void> _loadAndEmitMessages(String conversationId, List<Conversation> sessions, Emitter<ConversationState> emit) async {
      final conversationResult = await getConversationById(
        ConversationParams(conversationId: conversationId),
      );
      conversationResult.fold(
        (failure) {
          emit(ConversationLoaded(sessions: sessions, selectedSessionId: conversationId,)); 
        },
        (conversationInfo) {
          emit(ConversationLoaded(
            sessions: sessions,
            selectedSessionId: conversationId,
          ));
        }
      );
  }
}
