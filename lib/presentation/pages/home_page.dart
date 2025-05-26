import 'package:deepseek/presentation/bloc/conversation/conversation_bloc.dart';
import 'package:deepseek/presentation/bloc/conversation/conversation_event.dart';
import 'package:deepseek/presentation/widgets/conversation_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deepseek/core/di/injection_container.dart';
import 'package:deepseek/presentation/bloc/chat/chat_bloc.dart';
import 'package:deepseek/presentation/widgets/chat_input.dart';
import 'package:deepseek/presentation/widgets/logo.dart';
import 'package:deepseek/presentation/widgets/chat_messages.dart';
import 'package:deepseek/presentation/widgets/bottom_toolbar.dart';
import '../widgets/conversation_chat_connector.dart'; // Add this import
// Add this import for SettingsPage

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  bool _isToolbarVisible = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Add state for deep thinking and web search if needed at this level,
  // or manage it within ChatInput and pass via onSendPressed.
  // For this example, we'll assume ChatInput manages its own state for these toggles
  // and passes them in the onSendPressed callback.

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ChatBloc>(),
      child: Builder(
        builder: (builderContext) { // This context has access to the BlocProvider
          return Scaffold(
            key: _scaffoldKey,
            drawerEnableOpenDragGesture: true,
            drawer: Drawer(
              child: Column(
                children: [
                  const Expanded(
                  child: ConversationList(),
                  ),
                  //const Divider(),
                  ListTile(
                  leading: const CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white, size: 16),
                  ),
                  title: const Text('用户', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.more_horiz, size: 16),
                  onTap: () {
                    // Handle user profile tap
                    Navigator.pop(context); // Close the drawer
                    Navigator.pushNamed(context, '/settings'); // Navigate to SettingsPage
                  },
                  ),
                ],
              ),
            ),
            appBar: AppBar(
                title: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoaded) {
                  return Text(state.conversationTitle);
                  }
                  return const Text('新对话');
                },
                ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  // Open drawer with conversation list using the scaffold key
                  _scaffoldKey.currentState?.openDrawer();
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    builderContext.read<ConversationBloc>().add(GetConversationsEvent());
                  });
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // Create a new conversation
                    builderContext.read<ChatBloc>().add(CreateNewChatEvent());
                    
                    // Reset the text controller
                    _textController.clear();
                    
                    // Close toolbar if open
                    if (_isToolbarVisible) {
                      setState(() {
                        _isToolbarVisible = false;
                      });
                    }
                  },
                ),
              ],
            ),
            body: ConversationChatConnector( // Wrap the body's content
              child: Column(
                children: [
                  Expanded(
                    child: BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        if (state is ChatInitial) {
                          return _buildWelcomeScreen();
                        } else if (state is ChatLoaded) {
                          return ChatMessages(messages: state.messages);
                        }
                        return _buildWelcomeScreen();
                      },
                    ),
                  ),
                  ChatInput(
                    textController: _textController,
                    onSendPressed: (message, {bool isDeepThinkingEnabled = false, bool isWebSearchEnabled = false}) { // Updated signature
                      print("isDeepThinkingEnabled: $isDeepThinkingEnabled");
                      if (message.trim().isNotEmpty) {
                        // Use the builderContext which has access to the BlocProvider
                        builderContext.read<ChatBloc>().add(SendMessageEvent(
                          message,
                          isDeepThinkingEnabled: isDeepThinkingEnabled, // Pass the flag
                          isWebSearchEnabled: isWebSearchEnabled,     // Pass the flag
                        ));
                        _textController.clear();
                      }
                    },
                    onToggleToolbar: () {
                      setState(() {
                        _isToolbarVisible = !_isToolbarVisible;
                      });
                    },
                    isToolbarVisible: _isToolbarVisible,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isToolbarVisible ? 100 : 0,
                    child: _isToolbarVisible ? const BottomToolbar() : const SizedBox(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const DeepSeekLogo(size: 80),
          const SizedBox(height: 30),
          Text(
            '嗨！我是 智雅(Zhiya)',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              '我可以帮你搜索、答疑、写作，请把你的任务交给我吧~',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
