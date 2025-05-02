import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/repository/chat_repository.dart';
import 'package:lockedin/features/chat/view/chat_conversation_page.dart';
import 'package:lockedin/shared/theme/colors.dart';

// Provider for the chat repository
final firebaseChatRepositoryProvider = Provider<FirebaseChatRepository>((ref) {
  return FirebaseChatRepository();
});

// State for chat data
class ChatState {
  final List<Chat> chats;
  final String? errorMessage;
  final int totalUnreadCount;
  final bool isLoading;

  ChatState({
    this.chats = const [],
    this.errorMessage,
    this.totalUnreadCount = 0,
    this.isLoading = true, // Default to loading when first created
  });

  ChatState copyWith({
    List<Chat>? chats,
    String? errorMessage,
    int? totalUnreadCount,
    bool? isLoading,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      errorMessage: errorMessage ?? this.errorMessage,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class FirebaseChatViewModel extends StateNotifier<ChatState> {
  final FirebaseChatRepository _repository;
  StreamSubscription? _chatsSubscription;
  StreamSubscription? _unreadCountSubscription;

  FirebaseChatViewModel(this._repository) : super(ChatState()) {
    // Initialize streams when the ViewModel is created
    _initChatStream();
    _initUnreadCountStream();
  }

  // Initialize chat stream
  void _initChatStream() {
    _chatsSubscription = _repository.getChatStream().listen(
      (chats) {
        // Set isLoading to false when data is received
        state = state.copyWith(chats: chats, isLoading: false);
      },
      onError: (error) {
        // Set isLoading to false even on error
        state = state.copyWith(errorMessage: error.toString(), isLoading: false);
      }
    );
  }

  // Initialize unread count stream
  void _initUnreadCountStream() {
    _unreadCountSubscription = _repository.getTotalUnreadCountStream().listen(
      (count) {
        state = state.copyWith(totalUnreadCount: count);
      },
      onError: (error) {
        print("Error in unread count stream: $error");
        // Don't update error state just for unread count
      }
    );
  }

  // Mark a chat as read and update Firebase
  Future<void> markChatAsRead(Chat chat) async {
    try {
      await _repository.markChatAsRead(chat.id);
      // No need to update local state, Firebase will trigger the stream
    } catch (e) {
      print("Error marking chat as read: $e");
    }
  }

  // Mark a chat as unread and update Firebase
  Future<void> markChatAsUnread(Chat chat) async {
    try {
      await _repository.markChatAsUnread(chat.id);
      // No need to update local state, Firebase will trigger the stream
    } catch (e) {
      print("Error marking chat as unread: $e");
    }
  }
  
  // UI Event Handlers
  
  // Handle chat item tap event
  void onChatItemTapped(BuildContext context, Chat chat) {
    // Mark as read when tapped
    markChatAsRead(chat);
    
    // Navigate to chat conversation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatConversationScreen(chat: chat),
      ),
    );
  }
  
  // Show chat options menu
  void showChatOptionsMenu(BuildContext context, Chat chat) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          value: 'mark_unread',
          child: Row(
            children: [
              Icon(Icons.mark_email_unread, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Mark as unread'),
            ],
          ),
        ), 
      ],
    ).then((value) {
      if (value == 'mark_unread') {
        // Call method to mark as unread
        markChatAsUnread(chat);
        
        // Show a confirmation snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${chat.name} marked as unread'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }
  
  @override
  void dispose() {
    // Cancel subscriptions when the ViewModel is disposed
    _chatsSubscription?.cancel();
    _unreadCountSubscription?.cancel();
    super.dispose();
  }
}

// Create a provider for Firebase chat management
final firebaseChatProvider = StateNotifierProvider<FirebaseChatViewModel, ChatState>((ref) {
  final repository = ref.watch(firebaseChatRepositoryProvider);
  return FirebaseChatViewModel(repository);
});

// Provider for just the total unread count - useful for displaying in app bar or bottom navigation
final unreadCountProvider = Provider<int>((ref) {
  final chatState = ref.watch(firebaseChatProvider);
  return chatState.totalUnreadCount;
});

// StreamSubscription import is now at the top of the file