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
      // Commenting out the mark as read call to test without it
      // ref.read(chatProvider.notifier).markChatAsRead(widget.chat);
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

  // Updated to use the viewModel's sendMessage implementation
  void sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final messageText = _messageController.text.trim();
    _messageController.clear();
    
    // Get the current user ID and log it for debugging
    final chatViewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
    final userId = chatViewModel.currentUserId;
    debugPrint('Sending message with user ID: ${userId.isNotEmpty ? userId : "EMPTY"}');
    
    // Show a loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sending message...'),
        duration: Duration(seconds: 1),
      ),
    );
    
    // Call the viewModel's sendMessage method
    chatViewModel.sendMessage(messageText).then((_) {
      // Success! Message sent
      _scrollToBottom();
    }).catchError((error) {
      // Show a detailed error message if something went wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Error sending message', 
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                error.toString(),
                style: TextStyle(fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'DETAILS',
            textColor: Colors.white,
            onPressed: () {
              // Show a dialog with the full error details
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('API Error Details'),
                  content: SingleChildScrollView(
                    child: Text(error.toString()),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('CLOSE'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
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
          // Show error banner if there's an API error
          if (chatState.error != null)
            Material(
              color: Colors.red.shade700,
              child: InkWell(
                onTap: () {
                  // Show dialog with full error details
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('API Error Details'),
                      content: SingleChildScrollView(
                        child: Text(chatState.error!),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('CLOSE'),
                        ),
                      ],
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'API Error: Tap for details',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.messages.isEmpty && chatState.messagesByDate.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No messages yet', style: TextStyle(color: Colors.grey)),
                            if (chatState.error != null)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Could not load messages from server',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                          ],
                        ),
                      )
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
    // Debug fix: In demo mode, alternate messages between "me" and "other"
    // to show different bubble colors (remove this in production)
    bool isMe;
    if (currentUserId == 'demo-user-123') {
      // We're in demo mode, so we'll make every other message appear as "me"
      isMe = message.id.hashCode % 2 == 0;
    } else {
      // Normal mode: check if the message sender is the current user
      isMe = message.sender.id == currentUserId;
    }
    
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