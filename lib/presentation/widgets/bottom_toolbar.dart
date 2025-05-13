import 'package:flutter/material.dart';

class BottomToolbar extends StatelessWidget {
  const BottomToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF1E1E1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolButton(
            context: context,
            icon: Icons.camera_alt_outlined,
            label: '拍照识文字',
            onTap: () {
              // Handle camera functionality
            },
            isDisabled: true,
          ),
          _buildToolButton(
            context: context,
            icon: Icons.image_outlined,
            label: '图片识文字',
            onTap: () {
              // Handle image selection
            },
            isDisabled: true,
          ),
          _buildToolButton(
            context: context,
            icon: Icons.file_present_outlined,
            label: '文件',
            onTap: () {
              // Handle file upload
            },
            isDisabled: true,
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDisabled = false,
  }) {
    final Color disabledColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey.shade300
        : Colors.grey.shade800;
    
    final Color textColor = isDisabled
        ? Colors.grey.shade500
        : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    
    return Expanded(
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDisabled
                ? disabledColor
                : Theme.of(context).brightness == Brightness.light
                    ? const Color(0xFFF9F9F9)
                    : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 24,
                color: textColor,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
