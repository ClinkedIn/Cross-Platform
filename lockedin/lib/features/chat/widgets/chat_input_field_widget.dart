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
  bool _isTyping = false;
  
  @override
  void initState() {
    super.initState();
    // Add listener to text controller
    widget.messageController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.messageController.removeListener(_onTextChanged);
    super.dispose();
  }
  
  void _onTextChanged() {
    // Get current text
    final text = widget.messageController.text;
    final isEmpty = text.isEmpty;
    
    // Cancel any existing timer
    _debounceTimer?.cancel();
    
    // If text is empty and we were typing, stop typing immediately
    if (isEmpty && _isTyping) {
      _isTyping = false;
      _updateTypingStatus(false);
      return;
    }
    
    // If text is not empty, we're typing
    if (!isEmpty) {
      // If we weren't already marked as typing, update status
      if (!_isTyping) {
        _isTyping = true;
        _updateTypingStatus(true);
      }
      
      // Set a timer to automatically stop typing after inactivity
      _debounceTimer = Timer(Duration(seconds: 3), () {
        if (_isTyping) {
          _isTyping = false;
          _updateTypingStatus(false);
        }
      });
    }
  }
  
  void _updateTypingStatus(bool isTyping) {
    final chatId = ref.read(chatIdProvider);
    if (chatId.isNotEmpty) {
      ref.read(chatConversationProvider(chatId).notifier)
        .setUserTyping(isTyping);
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
