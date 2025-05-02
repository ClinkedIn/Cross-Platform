import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/model/attachment_model.dart';
import 'package:lockedin/features/chat/widgets/attachment_widget.dart';
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
        duration: const Duration(milliseconds: 1000),
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
      .sendMessage(messageText).then((_) {
      // Success! Message sent
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    final chatState = ref.watch(chatConversationProvider(widget.chat.id));

    // Scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Block/unblock button
          _buildBlockButton(),
        ],
      ),
      body: Column(
        children: [      
          Expanded(
            child: chatState.messages.isEmpty && chatState.messagesByDate.isEmpty
                    ? _buildEmptyChatView()
                    : _buildChatMessagesList(chatState),
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

  Widget _buildEmptyChatView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No messages yet', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildChatMessagesList(ChatConversationState chatState) {
    // Check if we should display by date
    if (chatState.messagesByDate.isNotEmpty) {
      // Get date keys sorted from newest to oldest
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
      _showSelectedImagePreview();
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
      _showSelectedImagePreview();
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
        _showSelectedDocumentPreview(attachment);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting document: ${e.toString()}')),
      );
    }
  }

  void _showSelectedImagePreview() {
    final chatState = ref.read(chatConversationProvider(widget.chat.id));
    final attachment = chatState.selectedAttachment;
    
    if (attachment == null) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 16),
            Expanded(
              child: Image.file(
                attachment.file,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ref.read(chatConversationProvider(widget.chat.id).notifier)
                      .clearSelectedAttachment();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendAttachment();
                  },
                  icon: Icon(Icons.send),
                  label: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSelectedDocumentPreview(ChatAttachment attachment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.description, size: 40, color: Colors.blue),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attachment.fileName ?? 'Document',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${(attachment.file.lengthSync() / 1024).toStringAsFixed(2)} KB',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () {
                    ref.read(chatConversationProvider(widget.chat.id).notifier)
                      .clearSelectedAttachment();
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                  label: Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _sendAttachment();
                  },
                  icon: Icon(Icons.send),
                  label: Text('Send'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _sendAttachment() async {
    final chatViewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
    final result = await chatViewModel.sendMessageWithAttachment();
      
    if (result['success'] == true) {
      // Scroll to bottom to show the sent message
      _scrollToBottom();
    }
  }
  
  // Keep block user functionality
  Widget _buildBlockButton() {
    final receiverId = ref.read(chatConversationProvider(widget.chat.id).notifier).getReceiverUserId();
    
    // Only show block button if we have a valid receiver ID
    if (receiverId == null || receiverId.isEmpty) {
      return SizedBox.shrink(); // Hide button if no receiver ID
    }
    
    return FutureBuilder<bool>(
      future: ref.read(chatConversationProvider(widget.chat.id).notifier).isUserBlocked(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: null,
          );
        }
        
        final isBlocked = snapshot.data ?? false;
        
        return IconButton(
          icon: Icon(
            isBlocked ? Icons.block : Icons.block_outlined,
            color: isBlocked ? Colors.red : null,
          ),
          onPressed: () {
            _showBlockUserDialog(context, isBlocked);
          },
        );
      },
    );
  }

  void _showBlockUserDialog(BuildContext context, bool isBlocked) {
    // Store a reference to the scaffold messenger before showing dialog
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isBlocked ? 'Unblock User' : 'Block User'),
        content: Text(
          isBlocked
              ? 'Would you like to unblock this user? They will be able to send you messages again.'
              : 'Would you like to block this user? You won\'t receive any more messages from them.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog first
              Navigator.pop(dialogContext);
              
              // Get the view model
              final viewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
              
              // Call the toggle block method
              viewModel.toggleBlockUser().then((result) {
                if (result['success'] == true) {
                  // Use the stored scaffold messenger reference
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        isBlocked
                            ? 'User has been unblocked'
                            : 'User has been blocked',
                      ),
                      backgroundColor: isBlocked ? Colors.green : Colors.red,
                    ),
                  );
                  // Force a rebuild to update the block button
                  setState(() {});
                } else {
                  // Use the stored scaffold messenger reference
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: ${result['error']}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              });
            },
            child: Text(
              isBlocked ? 'Unblock' : 'Block',
              style: TextStyle(
                color: isBlocked ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}