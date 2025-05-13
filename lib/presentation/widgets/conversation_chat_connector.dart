import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/conversation/conversation_bloc.dart';
import '../bloc/conversation/conversation_state.dart';
import '../bloc/chat/chat_bloc.dart';

class ConversationChatConnector extends StatelessWidget {
  final Widget child;
  
  const ConversationChatConnector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConversationBloc, ConversationState>(
      listener: (context, state) {
        if (state is ConversationLoaded) {
            
            if (state.selectedSessionId != null) {
              // Dispatch event to ChatBloc to load the conversation
              BlocProvider.of<ChatBloc>(context).add(
                LoadConversationEvent(
                  conversationId: state.selectedSessionId!,
                  conversationTitle: state.sessions
                      .firstWhere((session) => session.id == state.selectedSessionId!)
                      .title,
                  messages: state.sessions
                      .firstWhere((session) => session.id == state.selectedSessionId!)
                      .messages,
                ),
              );
            } else {
              // Handle the case where no conversation is selected
              BlocProvider.of<ChatBloc>(context).add(
                ClearChatEvent(),
              );
            }
        }
      },
      child: child,
    );
  }
}
