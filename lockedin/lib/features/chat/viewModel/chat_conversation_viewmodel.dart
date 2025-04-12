// chat_conversation_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/auth_service.dart';
import 'package:lockedin/features/chat/model/chat_message_model.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/repository/chat_conversation_repository.dart';
import 'package:lockedin/features/chat/viewModel/chat_viewmodel.dart';

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
  final Map<String, List<ChatMessage>> messagesByDate;
  final String? otherUserId;
  final String? otherUserName;
  final String? otherUserProfilePic;

  ChatConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.messagesByDate = const {},
    this.otherUserId,
    this.otherUserName,
    this.otherUserProfilePic,
  });

  ChatConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    Map<String, List<ChatMessage>>? messagesByDate,
    String? otherUserId,
    String? otherUserName,
    String? otherUserProfilePic,
  }) {
    return ChatConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      messagesByDate: messagesByDate ?? this.messagesByDate,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserProfilePic: otherUserProfilePic ?? this.otherUserProfilePic,
    );
  }
}

// Define the StateNotifier
class ChatConversationNotifier extends StateNotifier<ChatConversationState> {
  final String chatId;
  final ChatConversationRepository _repository;
  final AuthService _authService;
  final Chat? chat;
  
  String get currentUserId => _authService.currentUser?.id ?? '';

  ChatConversationNotifier(this.chatId, this._repository, this._authService, this.chat) 
      : super(ChatConversationState(isLoading: true)) {
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final conversationData = await _repository.fetchConversation(chatId);
      
      // Extract the raw messages
      final chatData = conversationData['chat'];
      final List<dynamic> rawMessages = chatData['rawMessages'];
      final messages = rawMessages.map((json) => ChatMessage.fromJson(json)).toList();
      
      // Get other user data
      final otherUserData = conversationData['otherUser'];
      final String otherUserId = otherUserData['_id'];
      final String otherUserName = '${otherUserData['firstName']} ${otherUserData['lastName']}'.trim();
      final String? otherUserProfilePic = otherUserData['profilePicture'];
      
      // Group messages by date
      final Map<String, List<ChatMessage>> messagesByDate = {};
      if (chatData['conversationHistory'] != null) {
        for (var dateGroup in chatData['conversationHistory']) {
          final date = dateGroup['date'];
          final List<dynamic> messagesForDate = dateGroup['messages'];
          messagesByDate[date] = messagesForDate.map((json) => ChatMessage.fromJson(json)).toList();
        }
      }
      
      state = state.copyWith(
        messages: messages,
        isLoading: false,
        messagesByDate: messagesByDate,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
        otherUserProfilePic: otherUserProfilePic,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Define the provider correctly
final chatConversationProvider = StateNotifierProvider.family<ChatConversationNotifier, ChatConversationState, String>(
  (ref, chatId) {
    final repository = ref.watch(chatConversationRepositoryProvider);
    final authService = ref.watch(authServiceProvider);
    final chatState = ref.watch(chatProvider);
    
    // Find the chat to get its type
    Chat? chat;
    try {
      chat = chatState.chats.firstWhere((c) => c.id == chatId);
    } catch (e) {
      // Chat not found, leave as null
      debugPrint('Chat not found in chat list: $chatId');
    }
    
    return ChatConversationNotifier(chatId, repository, authService, chat);
  },
); 