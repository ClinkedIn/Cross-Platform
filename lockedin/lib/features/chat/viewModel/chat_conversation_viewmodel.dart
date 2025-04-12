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
    _initialize();
  }

  Future<void> _initialize() async {
    // First ensure the current user is loaded
    try {
      if (_authService.currentUser == null) {
        debugPrint('Fetching current user data in ChatConversationNotifier');
        final user = await _authService.fetchCurrentUser();
        if (user == null) {
          debugPrint('Failed to fetch current user');
          state = state.copyWith(
            error: 'Failed to fetch user data',
            isLoading: false
          );
          return;
        }
      }
      
      // Then load the conversation
      await _loadConversation();
    } catch (e) {
      debugPrint('Error in ChatConversationNotifier initialization: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> _loadConversation() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final conversationData = await _repository.fetchConversation(chatId);
      
      // Extract the raw messages
      final chatData = conversationData['chat'];
      if (chatData == null) {
        throw Exception('No chat data in response');
      }
      
      // Extract and process messages
      List<ChatMessage> messages = [];
      if (chatData['rawMessages'] != null) {
        final List<dynamic> rawMessages = chatData['rawMessages'];
        messages = rawMessages.map((json) => ChatMessage.fromJson(json)).toList();
      }
      
      // Get other user data
      String? otherUserId, otherUserName, otherUserProfilePic;
      if (conversationData['otherUser'] != null) {
        final otherUserData = conversationData['otherUser'];
        otherUserId = otherUserData['_id'];
        otherUserName = '${otherUserData['firstName']} ${otherUserData['lastName']}'.trim();
        otherUserProfilePic = otherUserData['profilePicture'];
      }
      
      // Group messages by date
      final Map<String, List<ChatMessage>> messagesByDate = {};
      if (chatData['conversationHistory'] != null) {
        for (var dateGroup in chatData['conversationHistory']) {
          final date = dateGroup['date'];
          final List<dynamic> messagesForDate = dateGroup['messages'];
          if (date != null && messagesForDate != null) {
            messagesByDate[date] = messagesForDate.map((json) => ChatMessage.fromJson(json)).toList();
          }
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
      debugPrint('Error loading conversation: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  /// Sends a message to the current chat
  Future<void> sendMessage(String messageText) async {
    if (messageText.isEmpty) return;
    
    try {
      // Create a temporary message to display immediately
      final temporaryMessage = ChatMessage(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender(
          id: currentUserId,
          firstName: _authService.currentUser?.firstName ?? 'You',
          lastName: _authService.currentUser?.lastName ?? '',
          profilePicture: _authService.currentUser?.profilePicture,
        ),
        messageText: messageText,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Add the temporary message to the UI for immediate feedback
      _addTemporaryMessage(temporaryMessage);
      
      // Get the other user's ID from state
      final receiverId = state.otherUserId;
      if (receiverId != null) {
        debugPrint('Using receiver ID for message: $receiverId');
      } else {
        debugPrint('No receiver ID found, will use current user ID');
      }
      
      try {
        // Send the message to the server using the repository
        await _repository.sendMessage(
          chatId: chatId,
          messageText: messageText,
          chatType: chat?.chatType ?? 'direct', // Use the chat type from the chat object
          receiverId: receiverId, // Pass the other user's ID
        );
        
        // Message sent successfully
        debugPrint('Message sent successfully, keeping temporary message in UI');
        // We'll eventually refresh conversation on next app load
      } catch (e) {
        // Set detailed error state with the specific API error
        debugPrint('API ERROR: ${e.toString()}');
        state = state.copyWith(
          error: 'API ERROR: ${e.toString()}',
        );
        
        // We'll still keep the temporary message in the UI but mark it with an error
        // Optionally, we could add an error indicator to the message
        
        // Rethrow to allow the UI to show a toast/snackbar
        rethrow;
      }
    } catch (e) {
      // Handle errors - but keep the temporary message in UI
      debugPrint('Error sending message: ${e.toString()}');
      state = state.copyWith(
        error: 'Error sending message: ${e.toString()}',
      );
      
      // Don't remove the temporary message or refresh the conversation
      // This allows users to see their message and the error
      
      // Rethrow the error so the UI can handle it
      rethrow;
    }
  }
  
  /// Helper method to add a temporary message to the UI
  void _addTemporaryMessage(ChatMessage message) {
    // Update the flat list of messages
    final updatedMessages = [...state.messages, message];
    
    // Update messages grouped by date if needed
    final Map<String, List<ChatMessage>> updatedMessagesByDate = 
        Map<String, List<ChatMessage>>.from(state.messagesByDate);
    
    // Add to today's group if it exists
    const todayKey = 'Today'; // For simplicity, we use 'Today' as the key
    if (updatedMessagesByDate.containsKey(todayKey)) {
      updatedMessagesByDate[todayKey] = [...updatedMessagesByDate[todayKey]!, message];
    } else {
      // Create today's group if it doesn't exist
      updatedMessagesByDate[todayKey] = [message];
    }
    
    // Update the state with the temporary message
    state = state.copyWith(
      messages: updatedMessages,
      messagesByDate: updatedMessagesByDate,
    );
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