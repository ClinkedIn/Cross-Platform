// chat_conversation_viewmodel.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/auth_service.dart';
import 'package:lockedin/features/chat/model/chat_message_model.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/repository/chat_conversation_repository.dart';
import 'package:lockedin/features/chat/viewModel/chat_viewmodel.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';

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

  ChatConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.messagesByDate = const {},
  });

  ChatConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    Map<String, List<ChatMessage>>? messagesByDate,
  }) {
    return ChatConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      messagesByDate: messagesByDate ?? this.messagesByDate,
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
        debugPrint('Fetching current user data');
        final user = await _authService.fetchCurrentUser();
        if (user == null) {
          state = state.copyWith(
            error: 'Not authenticated. Please log in.',
            isLoading: false
          );
          return;
        }
      }
      
      // Check server connectivity before loading conversation
      await _checkServerConnectivity();
      
      // Then load the conversation
      await _loadConversation();
    } catch (e) {
      debugPrint('Error in initialization: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  /// Check if the server is reachable and responding properly
  Future<bool> _checkServerConnectivity() async {
    try {
      final endpoint = Constants.getUserDataEndpoint;
      
      try {
        final response = await RequestService.get(endpoint);
        final isConnected = response.statusCode >= 200 && response.statusCode < 400;
        
        if (!isConnected) {
          state = state.copyWith(
            error: 'Server connection issue. Status: ${response.statusCode}',
            isLoading: false
          );
        }
        
        return isConnected;
      } catch (e) {
        state = state.copyWith(
          error: 'Server connection error: Unable to reach API server',
          isLoading: false
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Error checking server connectivity',
        isLoading: false
      );
      return false;
    }
  }

  Future<void> _loadConversation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Log the chatId we're using
      debugPrint('Loading conversation for chat ID: $chatId');
      if (chatId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid chat ID'
        );
        return;
      }
      
      final conversationData = await _repository.fetchConversation(chatId);
      
      // Check if the API call was successful
      if (conversationData['success'] == false) {
        state = state.copyWith(
          isLoading: false,
          error: conversationData['error'] ?? 'Failed to load conversation'
        );
        return;
      }
      
      // Extract the chat data
      final chatData = conversationData['chat'];
      if (chatData == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No chat data received'
        );
        return;
      }
      
      // Process messages from raw messages
      List<ChatMessage> messages = [];
      try {
        if (chatData['rawMessages'] != null) {
          final List<dynamic> rawMessages = chatData['rawMessages'];
          for (var msgJson in rawMessages) {
            try {
              messages.add(ChatMessage.fromJson(msgJson));
            } catch (e) {
              debugPrint('Error parsing message: $e');
            }
          }
        }
      } catch (e) {
        debugPrint('Error processing raw messages: $e');
      }
      
      // Process messages by date
      Map<String, List<ChatMessage>> messagesByDate = {};
      try {
        if (chatData['conversationHistory'] != null) {
          for (var dateGroup in chatData['conversationHistory']) {
            final date = dateGroup['date']?.toString() ?? 'Unknown Date';
            final List<dynamic>? messagesForDate = dateGroup['messages'];
            
            if (messagesForDate != null && messagesForDate.isNotEmpty) {
              messagesByDate[date] = [];
              
              for (var msgJson in messagesForDate) {
                try {
                  messagesByDate[date]!.add(ChatMessage.fromJson(msgJson));
                } catch (e) {
                  debugPrint('Error parsing message in date group: $e');
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint('Error processing conversation history: $e');
      }
      
      // Update state with the parsed data
      state = state.copyWith(
        isLoading: false,
        messages: messages,
        messagesByDate: messagesByDate,
        error: null
      );
    } catch (e) {
      debugPrint('Error in _loadConversation: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load conversation: ${e.toString()}'
      );
    }
  }
  
  /// Manually refresh the conversation
  Future<void> refreshConversation() async {
    debugPrint('Manually refreshing conversation for chat ID: $chatId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Check server connectivity first
      final isConnected = await _checkServerConnectivity();
      if (isConnected) {
        await _loadConversation();
      }
    } catch (e) {
      debugPrint('Error refreshing conversation: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh: ${e.toString()}'
      );
    }
  }
  
  /// Sends a message to the current chat
  Future<void> sendMessage(String messageText) async {
    if (messageText.isEmpty) return;
    
    try {
      // Check if user is authenticated
      if (_authService.currentUser == null) {
        throw Exception('You must be logged in to send messages');
      }
      
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
      
      try {
        // Send the message to the server using the repository
        await _repository.sendMessage(
          chatId: chatId,
          messageText: messageText,
        );
        
        // Message sent successfully
        debugPrint('Message sent successfully');
      } catch (e) {
        // Set detailed error state with the specific API error
        debugPrint('Error sending message: ${e.toString()}');
        state = state.copyWith(
          error: 'Failed to send message: ${e.toString()}',
        );
        
        // Rethrow to allow the UI to show a toast/snackbar
        rethrow;
      }
    } catch (e) {
      // Handle errors - but keep the temporary message in UI
      debugPrint('Error sending message: ${e.toString()}');
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