import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:lockedin/features/chat/viewModel/chat_viewmodel.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/widgets/chat_app_bar.dart';
import 'package:lockedin/features/chat/widgets/chat_bubble_widget.dart';
import 'package:lockedin/features/chat/widgets/chat_input_field_widget.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
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
  void initState() {
    super.initState();
    // Mark chat as read when opening the conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).markChatAsRead(widget.chat);
    });
  }

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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Placeholder for future implementation
  void sendMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message sending not yet implemented'),
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    final chatState = ref.watch(chatConversationProvider(widget.chat.id));

    // Scroll to bottom when new messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    final otherUserName = chatState.otherUserName ?? widget.chat.name;
    final otherUserProfilePic = chatState.otherUserProfilePic ?? widget.chat.imageUrl;

    return Scaffold(
      appBar: ChatAppBar(
        name: otherUserName,
        imageUrl: otherUserProfilePic,
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.error != null
                    ? Center(child: Text('Error: ${chatState.error}'))
                    : _buildChatMessagesList(chatState),
          ),
          ChatInputField(
            messageController: _messageController,
            onAttachmentPressed: () {}, // Placeholder for future implementation
            onSendPressed: sendMessage,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatMessagesList(ChatConversationState chatState) {
    // Check if we should display by date
    if (chatState.messagesByDate.isNotEmpty) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: chatState.messagesByDate.length,
        itemBuilder: (context, index) {
          final dateKey = chatState.messagesByDate.keys.toList()[index];
          final messagesForDate = chatState.messagesByDate[dateKey]!;
          
          return Column(
            children: [
              _buildDateDivider(dateKey),
              ...messagesForDate.map((message) => _buildMessageBubble(message)),
            ],
          );
        },
      );
    }
    
    // Fall back to flat list if messagesByDate is empty
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(chatState.messages[index]);
      },
    );
  }
  
  Widget _buildDateDivider(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              date,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12.0,
              ),
            ),
          ),
          Expanded(child: Divider()),
        ],
      ),
    );
  }
  
  Widget _buildMessageBubble(message) {
    final currentUserId = ref.read(chatConversationProvider(widget.chat.id).notifier).currentUserId;
    final isMe = message.sender.id == currentUserId;
    
    // Default to empty string for messageText if null
    final messageText = message.messageText ?? '';
    
    // Handle attachments safely
    final String? attachmentUrl = message.messageAttachment.isNotEmpty 
        ? message.messageAttachment.first 
        : null;
    
    return ChatBubble(
      message: messageText,
      isMe: isMe,
      time: DateFormat('hh:mm a').format(message.createdAt),
      senderImageUrl: isMe ? null : message.sender.profilePicture,
      isRead: true, // Always considered read in the conversation
      attachmentUrl: attachmentUrl,
      attachmentType: message.attachmentType,
    );
  }
} 