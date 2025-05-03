// chat_conversation_viewmodel.dart
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/core/services/auth_service.dart';
import 'package:lockedin/features/chat/model/attachment_model.dart';
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
  final ChatAttachment? selectedAttachment;
  final Map<String, ChatMessage> temporaryMessages; // Track temporary messages by ID

  ChatConversationState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.messagesByDate = const {},
    this.isMarkedAsRead = false,
    this.isSending = false,
    this.selectedAttachment,
    this.temporaryMessages = const {},
  });

  ChatConversationState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
    Map<String, List<ChatMessage>>? messagesByDate,
    bool? isMarkedAsRead,
    bool? isSending,
    ChatAttachment? selectedAttachment,
    Map<String, ChatMessage>? temporaryMessages,
  }) {
    return ChatConversationState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error : this.error, // Preserve null if null is passed
      messagesByDate: messagesByDate ?? this.messagesByDate,
      isMarkedAsRead: isMarkedAsRead ?? this.isMarkedAsRead,
      isSending: isSending ?? this.isSending,
      selectedAttachment: selectedAttachment,
      temporaryMessages: temporaryMessages ?? this.temporaryMessages,
    );
  }
}

// Define the StateNotifier
class ChatConversationNotifier extends StateNotifier<ChatConversationState> {
  final String chatId;
  final ChatConversationRepository _repository;
  final AuthService _authService;
  final Chat? chat;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<Map<String, List<ChatMessage>>>? _messagesByDateSubscription;
  
  String get currentUserId {
    final userId = _authService.currentUser?.id ?? '';
    return userId;
  }

  ChatConversationNotifier(this.chatId, this._repository, this._authService, this.chat) 
      : super(ChatConversationState(isLoading: true)) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Load the current user before loading the conversation
      await _authService.fetchCurrentUser();
      
      // Fetch the receiver ID from the conversation document
      await _repository.fetchReceiverIdFromConversation(chatId);
      
      // Start listening to Firebase messages
      _setupMessageStreams();
    } catch (e) {
      debugPrint('Error in initialization: $e');
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  void _setupMessageStreams() {
    // Listen for all messages in a flat list
    _messagesSubscription = _repository.getMessagesStream(chatId).listen(
      (serverMessages) {
        // Create a new list that includes both server messages and temporary messages
        final Map<String, ChatMessage> tempMsgs = Map.from(state.temporaryMessages);
        final List<ChatMessage> allMessages = [...serverMessages];
        
        // Remove any temporary messages that have matching server messages
        final serverMessageIds = serverMessages.map((m) => m.id).toSet();
        tempMsgs.removeWhere((tempId, _) {
          // Check if we have a server message with matching text and sender
          // This is a heuristic to match temp messages with their server counterparts
          for (final serverMsg in serverMessages) {
            if (tempId.startsWith('temp_') && 
                tempMsgs[tempId]?.messageText == serverMsg.messageText &&
                tempMsgs[tempId]?.sender.id == serverMsg.sender.id) {
              return true;
            }
          }
          return false;
        });
        
        // Add any remaining temporary messages
        allMessages.addAll(tempMsgs.values);
        
        // Sort messages by creation time
        allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        // Update state with merged messages and set isSending to false
        state = state.copyWith(
          messages: allMessages,
          temporaryMessages: tempMsgs,
          isLoading: false,
          error: null,
          isSending: false  // Always set to false when we receive messages
        );
      },
      onError: (error) {
        debugPrint('Error in messages stream: $error');
        state = state.copyWith(
          error: error.toString(),
          isLoading: false
        );
      }
    );
    
    // Similar update for messages by date stream
    _messagesByDateSubscription = _repository.getMessagesByDateStream(chatId).listen(
      (messagesByDate) {
        // Don't completely replace the messages by date - incorporate temporary messages
        if (state.temporaryMessages.isNotEmpty) {
          final updatedMessagesByDate = Map<String, List<ChatMessage>>.from(messagesByDate);
          
          // Add temporary messages to their respective dates
          for (final tempMessage in state.temporaryMessages.values) {
            // Format the date to match the keys in messagesByDate
            final dateKey = DateFormat('MMMM d, yyyy').format(tempMessage.createdAt);
            
            // Add the temporary message to the appropriate date group
            if (updatedMessagesByDate.containsKey(dateKey)) {
              final messagesForDate = List<ChatMessage>.from(updatedMessagesByDate[dateKey]!);
              // Check if a similar message already exists to avoid duplicates
              final exists = messagesForDate.any((msg) => 
                msg.messageText == tempMessage.messageText && 
                msg.sender.id == tempMessage.sender.id);
                
              if (!exists) {
                messagesForDate.add(tempMessage);
                // Sort by timestamp within the day
                messagesForDate.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                updatedMessagesByDate[dateKey] = messagesForDate;
              }
            } else {
              // Create a new entry for this date
              updatedMessagesByDate[dateKey] = [tempMessage];
            }
          }
          
          // Update state with merged messagesByDate
          state = state.copyWith(
            messagesByDate: updatedMessagesByDate,
            isLoading: false,
            error: null
          );
        } else {
          // No temporary messages, just use server data
          state = state.copyWith(
            messagesByDate: messagesByDate,
            isLoading: false,
            error: null
          );
        }
      },
      onError: (error) {
        debugPrint('Error in messages by date stream: $error');
        // Don't update error state since the first stream will handle that
      }
    );
  }
  
  /// Sends a message to the current chat
  Future<void> sendMessage(String messageText) async {
    if (messageText.isEmpty) return;
    
    try {
      // Update state to indicate sending in progress, but KEEP existing messages
      // Don't set isSending to true immediately to avoid unnecessary UI flicker
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final temporaryMessage = ChatMessage(
        id: tempId,
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
      
      // Add the temporary message to the state FIRST before setting isSending
      _addTemporaryMessage(tempId, temporaryMessage);
      
      // Only after adding the message to UI, update sending state
      state = state.copyWith(isSending: true, error: null);
      
      // Determine chat type from the chat object if available
      String chatType = chat?.chatType ?? 'direct';
      
      // Get receiver ID for direct messages
      String? receiverId = getReceiverUserId();
      
      try {
        // Send the message to the server using the repository
        final result = await _repository.sendMessage(
          chatId: chatId,
          messageText: messageText,
          chatType: chatType,
          receiverId: receiverId,
        );
        
        // Check if the message was sent successfully
        if (result['success'] != true) {
          throw Exception(result['error'] ?? 'Failed to send message');
        }
        
        // Message sent successfully, but don't set isSending to false immediately
        // We'll let the Firebase stream update trigger that
        debugPrint('Message sent successfully');
        
      } catch (e) {
        // Set detailed error state with the specific API error - KEEP messages
        debugPrint('Error sending message: ${e.toString()}');
        state = state.copyWith(
          error: 'Failed to send message: ${e.toString()}',
          isSending: false, // Only reset on error
        );
        
        // Rethrow to allow the UI to show a toast/snackbar
        rethrow;
      }
    } catch (e) {
      // Handle errors - but keep the temporary message in UI
      debugPrint('Error sending message: ${e.toString()}');
      state = state.copyWith(isSending: false); // Only reset on error
      rethrow;
    }
  }
  
  /// Helper method to add a temporary message to the UI
  void _addTemporaryMessage(String tempId, ChatMessage message) {
    // Create a new map with the temporary message
    final updatedTempMessages = Map<String, ChatMessage>.from(state.temporaryMessages)
      ..putIfAbsent(tempId, () => message);
    
    // Create a new list including the temporary message
    final allMessages = [...state.messages, message];
    
    // Sort by timestamp
    allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    // Update the state with the new message
    state = state.copyWith(
      messages: allMessages,
      temporaryMessages: updatedTempMessages,
    );
  }
  
  /// Sends a message with an attachment to the current chat
  Future<Map<String, dynamic>> sendMessageWithAttachment({
    String? messageText,
  }) async {
    if (state.selectedAttachment == null) {
      return {
        'success': false,
        'error': 'No attachment selected',
      };
    }
    
    final attachment = state.selectedAttachment!;
    
    try {
      // Update state to indicate sending in progress
      state = state.copyWith(isSending: true, error: null);
      
      // Create a temporary message to display immediately
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
      final temporaryMessage = ChatMessage(
        id: tempId,
        sender: MessageSender(
          id: currentUserId,
          firstName: _authService.currentUser?.firstName ?? 'You',
          lastName: _authService.currentUser?.lastName ?? '',
          profilePicture: _authService.currentUser?.profilePicture,
        ),
        messageText: messageText ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        messageAttachment: [attachment.previewUrl ?? ''], // Use preview URL or empty
        attachmentType: attachment.type,
      );
      
      // Add the temporary message to the UI for immediate feedback
      _addTemporaryMessage(tempId, temporaryMessage);
      
      // Determine chat type from the chat object if available
      String chatType = chat?.chatType ?? 'direct';
      
      try {
        // Send the message with attachment to the server 
        final result = await _repository.sendMessageWithAttachment(
          chatId: chatId,
          messageText: messageText ?? '',
          chatType: chatType,
          attachment: attachment.file,
          attachmentType: attachment.type,
          fileName: attachment.fileName,
        );
        
        // Check if the message was sent successfully
        if (result['success'] != true) {
          throw Exception(result['error'] ?? 'Failed to send message with attachment');
        }
        
        // Message sent successfully
        debugPrint('Message with attachment sent successfully');
        
        // Clear the selected attachment since it was sent
        clearSelectedAttachment();
        
        // Update state to indicate sending is complete
        state = state.copyWith(isSending: false);
        
        return {
          'success': true
        };
      } catch (e) {
        // Set detailed error state with the specific API error
        debugPrint('Error sending message with attachment: ${e.toString()}');
        state = state.copyWith(
          error: 'Failed to send message with attachment: ${e.toString()}',
          isSending: false,
        );
        
        return {
          'success': false,
          'error': e.toString()
        };
      }
    } catch (e) {
      // Handle errors - but keep the temporary message in UI
      debugPrint('Error preparing message with attachment: ${e.toString()}');
      state = state.copyWith(isSending: false);
      
      return {
        'success': false,
        'error': e.toString()
      };
    }
  }
  
  // Rest of your methods remain the same
  Future<ChatAttachment?> selectImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      
      if (image != null) {
        final file = File(image.path);
        final attachment = ChatAttachment(
          file: file,
          type: AttachmentType.image,
          localId: 'local_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        state = state.copyWith(selectedAttachment: attachment);
        return attachment;
      }
      return null;
    } catch (e) {
      debugPrint('Error selecting image from camera: $e');
      throw Exception('Could not access camera: ${e.toString()}');
    }
  }

  Future<ChatAttachment?> selectImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      
      if (image != null) {
        final file = File(image.path);
        final attachment = ChatAttachment(
          file: file,
          type: AttachmentType.image,
          localId: 'local_${DateTime.now().millisecondsSinceEpoch}',
        );
        
        state = state.copyWith(selectedAttachment: attachment);
        return attachment;
      }
      return null;
    } catch (e) {
      debugPrint('Error selecting image from gallery: $e');
      throw Exception('Could not access gallery: ${e.toString()}');
    }
  }

  Future<ChatAttachment?> selectDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        
        final attachment = ChatAttachment(
          file: file,
          type: AttachmentType.document,
          localId: 'local_${DateTime.now().millisecondsSinceEpoch}',
          fileName: fileName,
        );
        
        state = state.copyWith(selectedAttachment: attachment);
        return attachment;
      }
      return null;
    } catch (e) {
      debugPrint('Error selecting document: $e');
      throw Exception('Could not select document: ${e.toString()}');
    }
  }

  void clearSelectedAttachment() {
    state = state.copyWith(selectedAttachment: null);
  }

  String? getReceiverUserId() {
    // First try getting from the repository
    final receiverId = _repository.receiverId;
    if (receiverId != null && receiverId.isNotEmpty) {
      return receiverId;
    }

    // Fallback: try to extract from the chat object if available
    if (chat != null) {
      final currentUserId = _authService.currentUser?.id;
      
      // If we have participants in the chat model, find the other user
      if (chat!.participants != null && chat!.participants!.isNotEmpty) {
        for (final participant in chat!.participants!) {
          if (participant.id != currentUserId) {
            return participant.id;
          }
        }
      }
    }

    return null;
  }
  
  Future<bool> isUserBlocked() async {
    final receiverId = getReceiverUserId();
    if (receiverId == null || receiverId.isEmpty) {
      debugPrint('Cannot check block status: No receiver ID found');
      return false;
    }
    
    try {
      return await _repository.isUserBlocked(receiverId);
    } catch (e) {
      debugPrint('Error checking block status: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> toggleBlockUser() async {
    final receiverId = getReceiverUserId();
    if (receiverId == null || receiverId.isEmpty) {
      debugPrint('Cannot block/unblock user: No receiver ID found');
      return {
        'success': false,
        'error': 'Cannot identify user to block/unblock',
      };
    }
    
    try {
      // Check current block status
      final isBlocked = await isUserBlocked();
      
      Map<String, dynamic> result;
      if (isBlocked) {
        // If blocked, unblock them
        result = await _repository.unblockUser(receiverId);
      } else {
        // If not blocked, block them
        result = await _repository.blockUser(receiverId);
      }
            
      return result;
    } catch (e) {
      debugPrint('Error toggling block status: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  @override
  void dispose() {
    // Cancel any active subscriptions
    _messagesSubscription?.cancel();
    _messagesByDateSubscription?.cancel();
    super.dispose();
  }
}

// Define the provider correctly
final chatConversationProvider = StateNotifierProvider.family<ChatConversationNotifier, ChatConversationState, String>(
  (ref, chatId) {
    final repository = ref.watch(chatConversationRepositoryProvider);
    final authService = ref.watch(authServiceProvider);
    final chatState = ref.watch(firebaseChatProvider);
    
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