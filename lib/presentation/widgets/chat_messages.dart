import 'package:flutter/material.dart';
import 'package:deepseek/domain/entities/message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:deepseek/presentation/widgets/typing_indicator.dart'; // Assuming you have or will create this

class ChatMessages extends StatefulWidget {
  final List<Message> messages;

  const ChatMessages({
    Key? key,
    required this.messages,
  }) : super(key: key);

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottomButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(jump: true));
  }

  @override
  void didUpdateWidget(ChatMessages oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.isNotEmpty) {
      final lastMessage = widget.messages.last;
      final oldLastMessage = oldWidget.messages.isNotEmpty ? oldWidget.messages.last : null;

      bool shouldScroll = false;
      // If a new message is added or the last message is being updated (partial)
      if (widget.messages.length > oldWidget.messages.length || 
          (lastMessage.isPartial && lastMessage.id == oldLastMessage?.id) ||
          (lastMessage.role == MessageRole.assistant && lastMessage.isLoading)) {
        shouldScroll = true;
      }

      if (shouldScroll) {
        bool isAtBottom = _scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 50.0; // Increased tolerance
        if (isAtBottom) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        }
      }
    }
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;

    // Show button if not at the very bottom (with a small tolerance)
    if (offset < maxScroll - 10.0) { // User has scrolled up
      if (!_showScrollToBottomButton) {
        setState(() {
          _showScrollToBottomButton = true;
        });
      }
    } else { // User is at or very near the bottom
      if (_showScrollToBottomButton) {
        setState(() {
          _showScrollToBottomButton = false;
        });
      }
    }
  }

  void _scrollToBottom({bool jump = false}) {
    if (_scrollController.hasClients && _scrollController.position.hasContentDimensions) {
      final position = _scrollController.position.maxScrollExtent;
      if (jump) {
        _scrollController.jumpTo(position);
      } else {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      // Ensure the button is hidden after scrolling to bottom
      if (_showScrollToBottomButton && position == _scrollController.position.maxScrollExtent) {
         WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _showScrollToBottomButton) {
               setState(() {
                _showScrollToBottomButton = false;
              });
            }
         });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RawScrollbar(
          thumbVisibility: false, // Hide scrollbar thumb even when scrolling
          trackVisibility: false, // Hide scrollbar track
          thickness: 0, // Set thickness to 0 to ensure it's completely hidden
          controller: _scrollController,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: widget.messages.length,
            itemBuilder: (context, index) {
              final message = widget.messages[index];
              return _buildMessageItem(context, message);
            },
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          bottom: _showScrollToBottomButton ? 24.0 : -60.0, // Move below screen when hiding
          right: 24.0,
          child: AnimatedOpacity(
            opacity: _showScrollToBottomButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: SizedBox(
              width: 32.0,
              height: 32.0,
              child: FloatingActionButton(
                onPressed: () => _scrollToBottom(),
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                tooltip: 'Scroll to bottom',
                child: Icon(
                  Icons.arrow_downward,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  size: 16.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageItem(BuildContext context, Message message) {
    final isUser = message.role == MessageRole.user;

    Widget messageContentWidget;
    if (message.isLoading && message.content.isEmpty) {
      // Show typing indicator if loading and content is empty (initial loading state for assistant)
      messageContentWidget = const TypingIndicator();
    } else if (message.role == MessageRole.system) {
        messageContentWidget = MarkdownBody(
        data: "*${message.content}*", // Italicize system messages
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 12
          ),
        ),
        selectable: true,
      );
    }
    else {
      // Show Markdown content if not loading or if it's a partial message with content
      messageContentWidget = MarkdownBody(
        data: message.content.isEmpty && message.isPartial && message.isLoading ? "..." : message.content, // Show ellipsis if content is empty but partial
        styleSheet: MarkdownStyleSheet(
          p: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 12,
          ),
          code: TextStyle(
            backgroundColor: isUser 
              ? Theme.of(context).highlightColor
              : null,
          ),
          codeblockDecoration: BoxDecoration(
            color: isUser 
              ? Colors.white.withAlpha(25) 
              : Theme.of(context).brightness == Brightness.light
                ? Colors.grey.shade200
                : Colors.grey.shade800,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        selectable: true,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser && message.role != MessageRole.system) _buildAvatar(context),
          if (message.role == MessageRole.system) const SizedBox(width: 36 + 8), // Placeholder for avatar space for system messages
          if (message.role != MessageRole.system) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser 
                    ? Theme.of(context).highlightColor
                    : null,
                borderRadius: BorderRadius.circular(18),
              ),
              child: messageContentWidget,
            ),
          ),
          if (message.role != MessageRole.system) const SizedBox(width: 8),
          //if (isUser && message.role != MessageRole.system) _buildUserAvatar(context),
          if (!isUser && message.role == MessageRole.system) const SizedBox(width: 36 + 8), // Placeholder for avatar space
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF6495ED).withAlpha(51),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CustomPaint(
            painter: _LogoPainter(),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF6495ED),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.person,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6495ED)
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // Main circle body
    path.moveTo(size.width * 0.5, size.height * 0.1);
    path.cubicTo(
      size.width * 0.3, size.height * 0.1,
      size.width * 0.2, size.height * 0.25,
      size.width * 0.2, size.height * 0.4
    );
    path.cubicTo(
      size.width * 0.2, size.height * 0.55,
      size.width * 0.3, size.height * 0.7,
      size.width * 0.5, size.height * 0.7
    );
    path.cubicTo(
      size.width * 0.7, size.height * 0.7,
      size.width * 0.8, size.height * 0.55,
      size.width * 0.8, size.height * 0.4
    );
    path.cubicTo(
      size.width * 0.8, size.height * 0.25,
      size.width * 0.7, size.height * 0.1,
      size.width * 0.5, size.height * 0.1
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
