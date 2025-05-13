import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget { // Changed to StatefulWidget
  final TextEditingController textController;
  final Function(String, {bool isDeepThinkingEnabled, bool isWebSearchEnabled}) onSendPressed; // Updated signature
  final VoidCallback onToggleToolbar;
  final bool isToolbarVisible;

  const ChatInput({
    Key? key,
    required this.textController,
    required this.onSendPressed,
    required this.onToggleToolbar,
    required this.isToolbarVisible,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState(); // Create state
}

class _ChatInputState extends State<ChatInput> { // State class
  bool _isDeepThinkingEnabled = false;
  final bool _isWebSearchEnabled = false; // Currently disabled, but state is managed

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      // decoration: BoxDecoration(
      //   color: Theme.of(context).scaffoldBackgroundColor,
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withAlpha(12),
      //       blurRadius: 5,
      //       offset: const Offset(0, -1),
      //     ),
      //   ],
      // ),
      child: Column(
        children: [
          // Message input field
            Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                ? const Color(0xFFF5F5F5)
                : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 6 * 24.0), // Approximately 6 lines of text
              child: TextField(
                controller: widget.textController, // Use widget.textController
                maxLines: null,
                minLines: 1,
                maxLength: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                hintText: '给 DeepSeek 发送消息',
                hintStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black54
                    : Colors.white54,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                counterText: '',
                ),
                style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black87
                  : Colors.white,
                ),
                onChanged: (text) {
                // Force rebuild to adjust height based on content
                (context as Element).markNeedsBuild();
                },
                onSubmitted: (text) {
                if (text.isNotEmpty) {
                  widget.onSendPressed(text, // Use widget.onSendPressed
                    isDeepThinkingEnabled: _isDeepThinkingEnabled,
                    isWebSearchEnabled: _isWebSearchEnabled,
                  );
                  widget.textController.clear(); // Use widget.textController
                }
                },
                scrollPhysics: const BouncingScrollPhysics(),
                keyboardType: TextInputType.multiline,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              ),
            ),
            ),
          const SizedBox(height: 16),
          
          // Function buttons
          Row(
            children: [
              // Deep thinking button
              _buildFunctionButton(
                context: context,
                icon: Icons.access_time,
                label: '深度思考(R1)',
                isSelected: _isDeepThinkingEnabled, // Pass selected state
                onPressed: () {
                  setState(() {
                    _isDeepThinkingEnabled = !_isDeepThinkingEnabled;
                  });
                },
              ),
              
                // Web search button
                _buildFunctionButton(
                context: context,
                icon: Icons.public,
                label: '联网搜索',
                isSelected: _isWebSearchEnabled, // Pass selected state
                onPressed: null, // Still disabled for now, but can be enabled by changing this
                // onPressed: () {
                //   setState(() {
                //     _isWebSearchEnabled = !_isWebSearchEnabled;
                //   });
                // },
                isDisabled: true, // New parameter to indicate disabled state
                ),
                const Spacer(),
                // Toggle tools button
                _buildFunctionButton(
                context: context,
                icon: widget.isToolbarVisible ? Icons.close : Icons.add, // Use widget.isToolbarVisible
                label: '',
                isSelected: false, // Not a toggle switch in the same way
                onPressed: widget.onToggleToolbar, // Use widget.onToggleToolbar
                flex: 1,
                ),
                
                // Send button
                _buildSendButton(context),
              ],
              ),
            ],
            ),
          );
          }

          Widget _buildFunctionButton({
          required BuildContext context,
          required IconData icon,
          required String label,
          required VoidCallback? onPressed,
          required bool isSelected, // New parameter for selection state
          bool isDisabled = false,
          int flex = 2,
          }) {
          final Color activeColor = Theme.of(context).colorScheme.primary;
          final Color inactiveColor = Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
          final Color iconColor = isDisabled 
            ? Theme.of(context).disabledColor 
            : (isSelected ? activeColor : inactiveColor);
          final Color labelColor = isDisabled
            ? Theme.of(context).disabledColor
            : (isSelected ? activeColor : inactiveColor);
            
          return Expanded(
            flex: flex,
            child: TextButton.icon(
            onPressed: isDisabled ? null : onPressed, // Disable if isDisabled is true
            icon: Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
            label: Text(
              label,
              style: TextStyle(
              fontSize: 12,
              color: labelColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              alignment: Alignment.center,
            ),
            ),
          );
          }

  Widget _buildSendButton(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF6495ED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.arrow_upward,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () {
          if (widget.textController.text.isNotEmpty) { // Use widget.textController
            widget.onSendPressed(widget.textController.text, // Use widget.onSendPressed
              isDeepThinkingEnabled: _isDeepThinkingEnabled,
              isWebSearchEnabled: _isWebSearchEnabled,
            );
            widget.textController.clear(); // Use widget.textController
          }
        },
      ),
    );
  }

}
