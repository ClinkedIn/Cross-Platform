// chat_conversation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/model/chat_message_model.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';

class ChatConversationScreen extends ConsumerStatefulWidget {
  final Chat chat;

  const ChatConversationScreen({Key? key, required this.chat}) : super(key: key);

  @override
  _ChatConversationScreenState createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends ConsumerState<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    final chatState = ref.watch(chatConversationProvider(widget.chat.id));
    final chatViewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
    
    // Scroll to bottom when new messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 30,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.imageUrl),
              radius: 20,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.name,
                  style: AppTextStyles.headline2.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  widget.chat.isOnline ? 'Online' : 'Offline',
                  style: AppTextStyles.bodyText2.copyWith(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              // Show chat options menu
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // Messages list
          Expanded(
            child: chatState.isLoading
                ? Center(child: CircularProgressIndicator())
                : chatState.error != null
                    ? Center(child: Text('Error: ${chatState.error}'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.messages[index];
                          final isMe = message.senderId == chatViewModel.currentUserId;
                          
                          return _buildMessageBubble(
                            message: message.content,
                            isMe: isMe,
                            time: DateFormat('hh:mm a').format(message.timestamp),
                          );
                        },
                      ),
          ),
          
          // Message input area
          Container(
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
                  onPressed: () {
                    // Handle attachment
                  },
                ),

                Expanded(
                  child: TextField(
                    controller: _messageController,
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
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      chatViewModel.sendMessage(_messageController.text.trim());
                      _messageController.clear();
                    }
                  },
                ),
                
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isMe,
    required String time,
  }) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chat.imageUrl),
              radius: 16,
            ),
            SizedBox(width: 8),
          ],
          
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe 
                ? AppColors.primary 
                : isDarkMode ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isMe ? Colors.white : (isDarkMode ? Colors.white : Colors.black87),
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          if (isMe) ...[
            SizedBox(width: 8),
            Icon(
              Icons.done_all,
              size: 16,
              color: widget.chat.isRead ? Colors.blue : Colors.grey,
            ),
          ],
        ],
      ),
    );
  }
}