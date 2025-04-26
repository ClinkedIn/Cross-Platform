import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
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
      // Make sure user profile is loaded
      _ensureUserDataLoaded();
      // Mark messages as read
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
  
  // Ensure the user data is loaded
  Future<void> _ensureUserDataLoaded() async {
    try {
      final chatViewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
      final currentUserId = chatViewModel.currentUserId;
      
      if (currentUserId.isEmpty) {
        debugPrint('Current user ID is empty, trying to reload user data');
        // Force a refresh of the conversation which now fetches user data first
        await chatViewModel.refreshConversation();
      }
    } catch (e) {
      debugPrint('Error ensuring user data is loaded: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    final chatState = ref.watch(chatConversationProvider(widget.chat.id));

    // Scroll to bottom when new messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chat.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Add refresh button
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.read(chatConversationProvider(widget.chat.id).notifier).refreshConversation();
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [      
          Expanded(
            child: chatState.messages.isEmpty && chatState.messagesByDate.isEmpty
                    ? RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(chatConversationProvider(widget.chat.id).notifier).refreshConversation();
                        },
                        child: ListView(
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
                                    if (chatState.error != null)
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              'Could not load messages from server',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Pull down to refresh or check your connection',
                                              style: TextStyle(color: Colors.grey),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 16),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                // Retry loading conversation
                                                ref.read(chatConversationProvider(widget.chat.id).notifier).refreshConversation();
                                              },
                                              icon: Icon(Icons.refresh),
                                              label: Text('Try Again'),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
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
      // Get date keys sorted from newest to oldest
      final dateKeys = chatState.messagesByDate.keys.toList();
      
      return RefreshIndicator(
        onRefresh: () async {
          // Refresh the conversation
          await ref.read(chatConversationProvider(widget.chat.id).notifier).refreshConversation();
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: dateKeys.length,
          itemBuilder: (context, index) {
            final dateKey = dateKeys[index];
            final messagesForDate = chatState.messagesByDate[dateKey]!;
            
            // Determine if we should show the date divider
            bool showDivider = true;

            // Check if previous date exists
            if (index > 0) {
              final prevDateKey = dateKeys[index - 1];
              
              // Try to convert string dates to DateTime objects for comparison
              final DateTime? currentDate = _parseDate(dateKey);
              final DateTime? prevDate = _parseDate(prevDateKey);
              
              // Skip divider if both dates are valid and are the same day or consecutive days
              if (currentDate != null && prevDate != null) {
                // Calculate difference in days
                final difference = currentDate.difference(prevDate).inDays.abs();
                
                // If the difference is 0 (same day), don't show divider
                if (difference == 0) {
                  showDivider = false;
                }
              } 
              // If we can't parse dates, fall back to comparing special strings
              else if (prevDateKey == dateKey) {
                showDivider = false;
              }
            }
            
            return Column(
              children: [
                if (showDivider)
                  _buildDateDivider(dateKey),
                ...messagesForDate.map((message) => _buildMessageBubble(message)),
              ],
            );
          },
        ),
      );
    }
    
    // Fall back to flat list if messagesByDate is empty
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh the conversation
        await ref.read(chatConversationProvider(widget.chat.id).notifier).refreshConversation();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: chatState.messages.length,
        itemBuilder: (context, index) {
          return _buildMessageBubble(chatState.messages[index]);
        },
      ),
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
  
  // Helper to parse date strings to DateTime objects
  DateTime? _parseDate(String dateString) {
    // Skip special date strings
    if (dateString == 'Today' || dateString == 'Yesterday') {
      return null;
    }
    
    // Try to parse date formats like "March 25, 2023"
    try {
      return DateFormat('MMMM d, yyyy').parse(dateString);
    } catch (_) {}
    
    // Try other common date formats
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (_) {}
    
    try {
      return DateFormat('MM/dd/yyyy').parse(dateString);
    } catch (_) {}
    
    // Return null if date couldn't be parsed
    return null;
  }
}