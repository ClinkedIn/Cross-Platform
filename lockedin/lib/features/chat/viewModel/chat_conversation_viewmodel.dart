// chat_conversation_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/model/chat_message_model.dart';

// Define attachment types
enum AttachmentType {
  document,
  image,
  gif,
  none
}

// Define the state class
class ChatConversationState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  ChatConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Define the StateNotifier
class ChatConversationNotifier extends StateNotifier<ChatConversationState> {
  final String chatId;
  final String currentUserId = 'current_user'; // Replace with actual user ID from auth

  ChatConversationNotifier(this.chatId) : super(ChatConversationState(isLoading: true)) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      // Implement your API call here
      // For now, let's use some mock data
      await Future.delayed(Duration(seconds: 1));
      final messages = [
        ChatMessage(
          id: '1',
          senderId: 'current_user',
          content: 'Hello there!',
          timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        ),
        ChatMessage(
          id: '2',
          senderId: 'other_user',
          content: 'Hi! How are you?',
          timestamp: DateTime.now().subtract(Duration(minutes: 4)),
        ),
      ];
      
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void sendMessage(String content) {
    if (content.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: currentUserId,
      content: content,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, newMessage],
    );

    // Here you would normally also send the message to your backend
    // _sendMessageToAPI(newMessage);
  }
  
  // New methods for handling attachments
  
  Future<void> sendDocumentAttachment(String filePath) async {
    try {
      // Implement document sending logic
      // 1. Upload file to storage
      // 2. Get download URL
      // 3. Create message with document data
      
      // Mock implementation for demonstration
      final documentUrl = "https://storage.example.com/documents/${DateTime.now().millisecondsSinceEpoch}";
      final documentName = filePath.split('/').last;
      
      final messageContent = "[Document: $documentName]";
      
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        content: messageContent,
        timestamp: DateTime.now(),
        attachmentUrl: documentUrl,
        attachmentType: AttachmentType.document,
      );

      state = state.copyWith(
        messages: [...state.messages, newMessage],
      );
      
      // _sendAttachmentToAPI(newMessage);
    } catch (e) {
      state = state.copyWith(error: "Failed to send document: ${e.toString()}");
    }
  }
  
  Future<void> sendImageAttachment(String imagePath, bool fromCamera) async {
    try {
      // Implement image sending logic
      // 1. Compress image if needed
      // 2. Upload to storage
      // 3. Get download URL
      // 4. Create message with image data
      
      // Mock implementation for demonstration
      final imageUrl = "https://storage.example.com/images/${DateTime.now().millisecondsSinceEpoch}";
      final source = fromCamera ? "Camera" : "Gallery";
      
      final messageContent = "[Image from $source]";
      
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        content: messageContent,
        timestamp: DateTime.now(),
        attachmentUrl: imageUrl,
        attachmentType: AttachmentType.image,
      );

      state = state.copyWith(
        messages: [...state.messages, newMessage],
      );
      
      // _sendAttachmentToAPI(newMessage);
    } catch (e) {
      state = state.copyWith(error: "Failed to send image: ${e.toString()}");
    }
  }
  
  Future<void> sendGifAttachment(String gifUrl) async {
    try {
      // Implement GIF sending logic
      final messageContent = "[GIF]";
      
      final newMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: currentUserId,
        content: messageContent,
        timestamp: DateTime.now(),
        attachmentUrl: gifUrl,
        attachmentType: AttachmentType.gif,
      );

      state = state.copyWith(
        messages: [...state.messages, newMessage],
      );
      
      // _sendAttachmentToAPI(newMessage);
    } catch (e) {
      state = state.copyWith(error: "Failed to send GIF: ${e.toString()}");
    }
  }
  
  void addMentionToMessage(String username) {
    // This could be used to handle mentions from the UI
    // For example, adding the username to the text being composed
    // However, this is usually handled directly in the UI
  }
}

// Define the provider correctly
final chatConversationProvider = StateNotifierProvider.family<ChatConversationNotifier, ChatConversationState, String>(
  (ref, chatId) => ChatConversationNotifier(chatId),
);