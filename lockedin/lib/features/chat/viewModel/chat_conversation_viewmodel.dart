// chat_conversation_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/model/chat_message_model.dart';

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
}

// Define the provider correctly
final chatConversationProvider = StateNotifierProvider.family<ChatConversationNotifier, ChatConversationState, String>(
  (ref, chatId) => ChatConversationNotifier(chatId),
);