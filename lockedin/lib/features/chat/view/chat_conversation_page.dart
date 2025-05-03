import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/widgets/attachment_widget.dart';
import 'package:lockedin/features/chat/widgets/chat_bubble_widget.dart';
import 'package:lockedin/features/chat/widgets/chat_input_field_widget.dart';
import 'package:lockedin/features/chat/widgets/block_button_widget.dart';
import 'package:lockedin/features/chat/widgets/image_preview_widget.dart';
import 'package:lockedin/features/chat/widgets/document_preview_widget.dart';
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
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when opening the conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
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
  
  // Check if message list changed and we need to scroll
  void _checkForAutoScroll(ChatConversationState chatState) {
    // Only run this after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final int currentCount = chatState.messages.length;
      // If we have new messages, scroll to bottom
      if (currentCount > _previousMessageCount) {
        _scrollToBottom();
      }
      _previousMessageCount = currentCount;
    });
  }

  void sendMessage() {
    // Ensure the message is not empty before sending
    if (_messageController.text.trim().isEmpty) return;
    // Get the trimmed message text and clear the input field
    final messageText = _messageController.text.trim();
    _messageController.clear();
    // Call the viewModel's sendMessage method
    ref.read(chatConversationProvider(widget.chat.id).notifier)
      .sendMessage(messageText).then((_) {
      // Wait a short delay to ensure the UI updates first before scrolling
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    final chatState = ref.watch(chatConversationProvider(widget.chat.id));

    // Check for auto-scroll when chatState changes
    _checkForAutoScroll(chatState);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Block/unblock button
          BlockButtonWidget(chatId: widget.chat.id),
        ],
      ),
      body: Column(
        children: [      
          Expanded(
            // Show the messages list - always use the same implementation
            child: _buildChatMessagesList(chatState),
          ),
          // Conditionally show chat input based on block status
          FutureBuilder<bool>(
            future: ref.read(chatConversationProvider(widget.chat.id).notifier).isUserBlocked(),
            builder: (context, snapshot) {
              final isBlocked = snapshot.data ?? false;
              
              if (isBlocked) {
                // Show a message instead of input field when blocked
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.block, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'You cannot message this user',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ],
                  ),
                );
              }
              
              // Show regular chat input field when not blocked
              return ChatInputField(
                messageController: _messageController,
                onAttachmentPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => AttachmentWidget(
                      onDocumentPressed: () {
                        _pickDocument(); 
                        Navigator.pop(context);
                      },
                      onCameraPressed: () {
                        _pickImageFromCamera();
                        Navigator.pop(context);
                      },
                      onMediaPressed: () {
                        _pickImageFromGallery();
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                onSendPressed: sendMessage,
                isDarkMode: isDarkMode,
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatMessagesList(ChatConversationState chatState) {
    // Never show an empty list if we're sending a message
    if (chatState.isSending && chatState.messages.isNotEmpty) {
      // Always use the flat list when sending to ensure temporary messages are shown
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: chatState.messages.length,
        itemBuilder: (context, index) {
          return _buildMessageBubble(chatState.messages[index]);
        },
      );
    }
    
    // Otherwise, continue with your grouped-by-date view if available
    if (chatState.messagesByDate.isNotEmpty) {
      final dateKeys = chatState.messagesByDate.keys.toList();
      
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: dateKeys.length,
        itemBuilder: (context, index) {
          final dateKey = dateKeys[index];
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
    
    // Normal mode: check if the message sender is the current user
    // Handle empty current user ID case
    final isMe = currentUserId.isNotEmpty && message.sender.id == currentUserId;
    
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

  Future<void> _pickImageFromCamera() async {
    try {
      final viewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
      await viewModel.selectImageFromCamera();
      _showSelectedAttachmentPreview();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing camera: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final viewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
      await viewModel.selectImageFromGallery();
      _showSelectedAttachmentPreview();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accessing gallery: ${e.toString()}')),
      );
    }
  }

  Future<void> _pickDocument() async {
    try {
      final viewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
      final attachment = await viewModel.selectDocument();
      
      if (attachment != null) {
        _showSelectedAttachmentPreview();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting document: ${e.toString()}')),
      );
    }
  }

  void _showSelectedAttachmentPreview() {
    final chatState = ref.read(chatConversationProvider(widget.chat.id));
    final attachment = chatState.selectedAttachment;
    
    if (attachment == null) return;
    
    if (attachment.type == AttachmentType.image) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => ImagePreviewWidget(
          attachment: attachment,
          chatId: widget.chat.id,
          onSend: _sendAttachment,
        ),
      );
    } else if (attachment.type == AttachmentType.document) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => DocumentPreviewWidget(
          attachment: attachment,
          chatId: widget.chat.id,
          onSend: _sendAttachment,
        ),
      );
    }
  }
  
  Future<void> _sendAttachment() async {
    final chatViewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
    final result = await chatViewModel.sendMessageWithAttachment();
      
    if (result['success'] == true) {
      // Wait a short delay to ensure the UI updates first before scrolling
      Future.delayed(Duration(milliseconds: 300), () {
        _scrollToBottom();
      });
    }
  }
}