import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/model/chat_message_model.dart';
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

  @override
  void initState() {
    super.initState();
    // Set the chat ID for the input field to use
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatIdProvider.notifier).state = widget.chat.id;

      // Mark messages as read when the conversation is opened
      ref.read(chatConversationProvider(widget.chat.id).notifier).markMessagesAsRead();
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
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  void sendMessage() {
    // Ensure the message is not empty before sending
    if (_messageController.text.trim().isEmpty) return;
    // Get the trimmed message text and clear the input field
    final messageText = _messageController.text.trim();
    _messageController.clear();
    // Call the viewModel's sendMessage method
    ref.read(chatConversationProvider(widget.chat.id).notifier)
      .sendMessage(messageText);
    
    // Add a slight delay to ensure the message is added to the list before scrolling
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    final chatState = ref.watch(chatConversationProvider(widget.chat.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(), // Navigate back to chat list
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
          // Add typing indicator before the input field
          _buildTypingIndicator(),
          // Conditionally show chat input based on block status
          Builder(
            builder: (context) {
              final isBlocked = chatState.isBlocked;
              
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
    return StreamBuilder<List<ChatMessage>>(
      stream: ref.read(chatConversationProvider(widget.chat.id).notifier).getMessagesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading messages'));
        }
        
        // Mark messages as read whenever new messages arrive while viewing the conversation
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(chatConversationProvider(widget.chat.id).notifier)
              .markMessagesAsRead();
          });
        }
        
        // Use data from stream if available, otherwise fall back to state
        final messages = snapshot.hasData ? snapshot.data! : chatState.messages;
        
        // If messages are empty, show a placeholder
        if (messages.isEmpty) {
          return Center(child: Text('No messages yet'));
        }

        // Create a map of messages by date if needed
        Map<String, List<ChatMessage>> messagesByDate = {};
        if (chatState.messagesByDate.isNotEmpty) {
          messagesByDate = chatState.messagesByDate;
        } else {
          // Group messages by date
          for (var message in messages) {
            final dateKey = DateFormat('MMMM d, yyyy').format(message.createdAt);
            if (!messagesByDate.containsKey(dateKey)) {
              messagesByDate[dateKey] = [];
            }
            messagesByDate[dateKey]!.add(message);
          }
        }

        // Sort date keys chronologically so newest messages are at the bottom
        final dateKeys = messagesByDate.keys.toList()..sort((a, b) {
          final dateA = DateFormat('MMMM d, yyyy').parse(a);
          final dateB = DateFormat('MMMM d, yyyy').parse(b);
          return dateA.compareTo(dateB);
        });

        // Always scroll to bottom when data changes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
        
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          // Keep standard chronological order
          itemCount: dateKeys.length,
          itemBuilder: (context, index) {
            final dateKey = dateKeys[index];
            final messagesForDate = messagesByDate[dateKey]!;
            
            return Column(
              children: [
                _buildDateDivider(dateKey),
                ...messagesForDate.map((message) => _buildMessageBubble(message)),
              ],
            );
          },
        );
      }
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
  
  Widget _buildMessageBubble(ChatMessage message) {
    final currentUserId = ref.read(chatConversationProvider(widget.chat.id).notifier).currentUserId;
    
    // Normal mode: check if the message sender is the current user
    final isMe = currentUserId.isNotEmpty && message.sender.id == currentUserId;
    
    // Default to empty string for messageText if null
    final messageText = message.messageText;
    
    // Extract first attachment URL
    final String? attachmentUrl = message.messageAttachment.isNotEmpty 
        ? message.messageAttachment.first 
        : null;

    return ChatBubble(
      message: messageText,
      isMe: isMe,
      time: DateFormat('hh:mm a').format(message.createdAt),
      senderImageUrl: isMe ? null : message.sender.profilePicture,
      isRead: true,
      attachmentUrl: attachmentUrl,  // Use the extracted URL
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
      // Add a slight delay to ensure the message is added before scrolling
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    }
  }

  // Add this method to build the typing indicator
  Widget _buildTypingIndicator() {
    ref.watch(chatConversationProvider(widget.chat.id));
    final chatNotifier = ref.read(chatConversationProvider(widget.chat.id).notifier);
    
    // Check if someone other than the current user is typing
    final isTyping = chatNotifier.isOtherUserTyping();
    
    if (!isTyping) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        children: [
          // Animated typing indicator
          _buildTypingAnimation(),
          SizedBox(width: 8),
          Text(
            'Typing...',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTypingAnimation() {
    return SizedBox(
      width: 40,
      child: Row(
        children: [
          _buildDot(300),
          _buildDot(600),
          _buildDot(900),
        ],
      ),
    );
  }
  
  Widget _buildDot(int milliseconds) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: milliseconds),
        builder: (context, value, child) {
          return Opacity(
            opacity: (value < 0.5) ? value * 2 : (1 - value) * 2,
            child: Container(
              height: 6,
              width: 6,
              margin: EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
        // Make animation repeat
        onEnd: () => setState(() {}),
      ),
    );
  }
}