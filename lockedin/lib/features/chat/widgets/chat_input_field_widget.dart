import 'package:flutter/material.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class ChatInputField extends ConsumerStatefulWidget {
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
  ConsumerState<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends ConsumerState<ChatInputField> {
  Timer? _debounceTimer;
  bool _wasEmpty = true;

  @override
  void initState() {
    super.initState();
    widget.messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.messageController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.messageController.text;
    final isEmpty = text.isEmpty;

    if (isEmpty != _wasEmpty) {
      _wasEmpty = isEmpty;

      _debounceTimer?.cancel();

      _debounceTimer = Timer(Duration(milliseconds: 300), () {
        final chatId = ref.read(chatIdProvider);
        ref.read(chatConversationProvider(chatId).notifier)
          .setUserTyping(!isEmpty);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? Colors.grey[900] : Colors.grey[100],
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
            onPressed: widget.onAttachmentPressed,
          ),
          Expanded(
            child: TextField(
              controller: widget.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: widget.isDarkMode ? Colors.grey[800] : Colors.white,
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
            onPressed: widget.onSendPressed,
          ),
        ],
      ),
    );
  }
}

final chatIdProvider = StateProvider<String>((ref) => '');
