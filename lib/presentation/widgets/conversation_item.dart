import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/conversation.dart';
import '../bloc/conversation/conversation_bloc.dart';
import '../bloc/conversation/conversation_event.dart';

class ConversationItem extends StatelessWidget {
  final Conversation session;
  final bool isSelected;
  final VoidCallback onTap;

  const ConversationItem({
    Key? key,
    required this.session,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showContextMenu(context),
      onSecondaryTap: () => _showContextMenu(context), // For right-click
      child: Container(
        width: double.infinity, // Make container take full width
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Add some margin
        decoration: BoxDecoration(
          //color: isSelected ? Theme.of(context).highlightColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0), // Add rounded corners
          
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Text(
          session.title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color, // Blue color for selected item
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
  void _showContextMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        position.dx + size.width,
        position.dy + size.height,
      ),
      items: [
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('重命名'),
            ],
          ),
          onTap: () {
            // Using Future.delayed because showMenu closes the popup before executing onTap
            Future.delayed(
              const Duration(milliseconds: 10),
              () => _showRenameDialog(context),
            );
          },
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.delete, size: 20),
              SizedBox(width: 8),
              Text('删除'),
            ],
          ),
          onTap: () {
            Future.delayed(
              const Duration(milliseconds: 10),
              () => _showDeleteConfirmation(context),
            );
          },
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context) {
    final textController = TextEditingController(text: session.title);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('重命名会话'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: '输入新的会话名称',
            ),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('确认'),
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  context.read<ConversationBloc>().add(
                    RenameConversationEvent(
                      id: session.id,
                      newTitle: textController.text,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除会话'),
          content: Text('你确定要删除 "${session.title}" 会话吗？'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('删除'),
              onPressed: () {
                context.read<ConversationBloc>().add(
                  DeleteConversationEvent(id: session.id),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
