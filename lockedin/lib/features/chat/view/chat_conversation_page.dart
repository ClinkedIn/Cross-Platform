import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/widgets/attachment_widget.dart';
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
  final ImagePicker _imagePicker = ImagePicker();
  bool _showAttachmentOptions = false;

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

  void toggleAttachment() {
    setState(() {
      _showAttachmentOptions = !_showAttachmentOptions;
    });
  }

  void sendMessage() {
    if (_messageController.text.trim().isNotEmpty) {
      final chatViewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
      chatViewModel.sendMessage(_messageController.text.trim());
      _messageController.clear();
      _scrollToBottom();
    }
  }
  
  // Document button functionality
  Future<void> _handleDocumentSelection() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
      );
      
      if (result != null) {
        final chatViewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
        await chatViewModel.sendDocumentAttachment(result.files.single.path!);
        
        setState(() {
          _showAttachmentOptions = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting document: $e')),
      );
    }
  }
  
  // Camera button functionality
  Future<void> _handleCameraCapture() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
      
      if (photo != null) {
        final chatViewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
        await chatViewModel.sendImageAttachment(photo.path, true);
        
        setState(() {
          _showAttachmentOptions = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing image: $e')),
      );
    }
  }
  
  // Media button functionality
  Future<void> _handleMediaSelection() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final chatViewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
        await chatViewModel.sendImageAttachment(image.path, false);
        
        setState(() {
          _showAttachmentOptions = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting media: $e')),
      );
    }
  }
  
  // GIF button functionality
  void _handleGifSelection() {
    // TODO: Implement GIF picker
    // For demonstration purposes only
    final chatViewModel = ref.read(chatConversationProvider(widget.chat.id).notifier);
    chatViewModel.sendGifAttachment("https://example.com/sample.gif");
    
    setState(() {
      _showAttachmentOptions = false;
    });
    _scrollToBottom();
  }
  
  // Mention button functionality
  void _handleMention() {
    // Insert @ symbol in current text position
    _messageController.text = _messageController.text + '@';
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: _messageController.text.length),
    );
    
    setState(() {
      _showAttachmentOptions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider) == AppTheme.darkTheme;
    final chatState = ref.watch(chatConversationProvider(widget.chat.id));

    // Scroll to bottom when new messages are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: ChatAppBar(
        name: widget.chat.name,
        imageUrl: widget.chat.imageUrl,
        isOnline: widget.chat.isOnline,
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : chatState.error != null
                    ? Center(child: Text('Error: ${chatState.error}'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: chatState.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatState.messages[index];
                          final currentUserId = ref.read(chatConversationProvider(widget.chat.id).notifier).currentUserId;
                          final isMe = message.senderId == currentUserId;
                          
                          return ChatBubble(
                            message: message.content,
                            isMe: isMe,
                            time: DateFormat('hh:mm a').format(message.timestamp),
                            senderImageUrl: widget.chat.imageUrl,
                            isRead: widget.chat.isRead,
                            attachmentUrl: message.attachmentUrl,
                            attachmentType: message.attachmentType,
                          );
                        },
                      ),
          ),
          if (_showAttachmentOptions) AttachmentWidget(
            onDocumentPressed: _handleDocumentSelection,
            onCameraPressed: _handleCameraCapture,
            onMediaPressed: _handleMediaSelection,
            onGifPressed: _handleGifSelection,
            onMentionPressed: _handleMention,
          ),
          ChatInputField(
            messageController: _messageController,
            onAttachmentPressed: toggleAttachment,
            onSendPressed: sendMessage,
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }
}