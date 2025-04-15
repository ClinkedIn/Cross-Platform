// chat_conversation_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
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
  video,
  audio,
  none
}

// Define the state class
class ChatConversationState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;
  final Map<String, List<ChatMessage>> messagesByDate;
  final bool isMarkedAsRead;
  final bool isSending;

  ChatConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.messagesByDate = const {},
    this.isMarkedAsRead = false,
    this.isSending = false,
  });

  ChatConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    Map<String, List<ChatMessage>>? messagesByDate,
    bool? isMarkedAsRead,
    bool? isSending,
  }) {
    return ChatConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error : this.error, // Preserve null if null is passed
      messagesByDate: messagesByDate ?? this.messagesByDate,
      isMarkedAsRead: isMarkedAsRead ?? this.isMarkedAsRead,
      isSending: isSending ?? this.isSending,
    );
  }
}

// Define the StateNotifier
class ChatConversationNotifier extends StateNotifier<ChatConversationState> {
  final String chatId;
  final ChatConversationRepository _repository;
  final AuthService _authService;
  final Chat? chat;
  
  String get currentUserId {
    final userId = _authService.currentUser?.id ?? '';
    debugPrint('Getting currentUserId: ${userId.isEmpty ? "EMPTY" : userId}');
    return userId;
  }

  ChatConversationNotifier(this.chatId, this._repository, this._authService, this.chat) 
      : super(ChatConversationState(isLoading: true)) {
    _initialize();
  }

  Future<void> _initialize() async {
    // First ensure the current user is loaded
    try {
      // Load the current user before loading the conversation
      await _authService.fetchCurrentUser();
      
      // Then load the conversation
      await _loadConversation();
      
      // Mark as read when opening the conversation
      await markChatAsRead();
    } catch (e) {
      debugPrint('Error in initialization: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  Future<void> _loadConversation() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
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
      await _loadConversation();
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
      // Update state to indicate sending in progress
      state = state.copyWith(isSending: true, error: null);
      
      // // Check if user is authenticated
      // if (_authService.currentUser == null) {
      //   throw Exception('You must be logged in to send messages');
      // }
      
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
        messageAttachment: const [], // Initialize as empty list
        attachmentType: AttachmentType.none,
      );
      
      // Add the temporary message to the UI for immediate feedback
      _addTemporaryMessage(temporaryMessage);
      
      // Determine chat type from the chat object if available
      String chatType = chat?.chatType ?? 'direct';
      
      try {
        // Send the message to the server using the repository
        final result = await _repository.sendMessage(
          chatId: chatId,
          messageText: messageText,
          chatType: chatType,
        );
        
        // Check if the message was sent successfully
        if (result['success'] != true) {
          throw Exception(result['error'] ?? 'Failed to send message');
        }
        
        // Message sent successfully
        debugPrint('Message sent successfully');
        
        // Refresh the conversation to get the actual message from the server
        // Wait a moment to give the server time to process the message
        await Future.delayed(const Duration(milliseconds: 500));
        await refreshConversation();
        
        // Update state to indicate sending is complete
        state = state.copyWith(isSending: false);
      } catch (e) {
        // Set detailed error state with the specific API error
        debugPrint('Error sending message: ${e.toString()}');
        state = state.copyWith(
          error: 'Failed to send message: ${e.toString()}',
          isSending: false,
        );
        
        // Rethrow to allow the UI to show a toast/snackbar
        rethrow;
      }
    } catch (e) {
      // Handle errors - but keep the temporary message in UI
      debugPrint('Error sending message: ${e.toString()}');
      state = state.copyWith(isSending: false);
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
    
    // Format today's date
    final today = DateFormat('MMMM d, yyyy').format(DateTime.now());
    
    // Add to today's group if it exists
    String todayKey = 'Today';
    
    // Check if we have a date formatted key for today in the existing keys
    for (final key in updatedMessagesByDate.keys) {
      if (key == today) {
        todayKey = key;
        break;
      }
    }
    
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
  
  /// Mark chat as read
  /// This sets the unread count to zero for the current user
  Future<bool> markChatAsRead() async {
    try {
      
      // Call the repository method to mark as read
      final success = await _repository.markChatAsRead(chatId);
      
      // Update the state to reflect the read status
      if (success) {
        state = state.copyWith(isMarkedAsRead: true);
        
        // Also update the unread count in the parent chat list if possible
        try {
          // This would be implemented in a real app to update the chat list
          // For now just log it
          debugPrint('Chat marked as read successfully');
        } catch (e) {
          debugPrint('Error updating chat list unread count: $e');
        }
      } else {
        debugPrint('Failed to mark chat as read');
      }
      
      return success;
    } catch (e) {
      debugPrint('Error in markChatAsRead: $e');
      return false;
    }
  }
}

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