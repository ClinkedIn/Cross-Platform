import 'package:flutter/material.dart';
import 'package:lockedin/shared/theme/colors.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onAttachmentPressed;
  final VoidCallback onSendPressed;
  final bool isDarkMode;

  const ChatInputField({
    Key? key,
    required this.messageController,
    required this.onAttachmentPressed,
    required this.onSendPressed,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: onAttachmentPressed,
          ),
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: AppColors.primary),
            onPressed: onSendPressed,
          ),
        ],
      ),
    );
  }
}
