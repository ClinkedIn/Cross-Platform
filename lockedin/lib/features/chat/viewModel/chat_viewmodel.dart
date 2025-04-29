import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/repository/chat_repository.dart';
import 'package:lockedin/features/chat/view/chat_conversation_page.dart';
import 'package:lockedin/shared/theme/colors.dart';

// Provider for the chat repository
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository();
});

// State for chat loading
enum ChatLoadingState { initial, loading, loaded, error }

// State class for chat data
class ChatState {
  final List<Chat> chats;
  final ChatLoadingState loadingState;
  final String? errorMessage;
  final int totalUnreadCount;
  final bool isLoadingUnreadCount;

  ChatState({
    this.chats = const [],
    this.loadingState = ChatLoadingState.initial,
    this.errorMessage,
    this.totalUnreadCount = 0,
    this.isLoadingUnreadCount = false,
  });

  ChatState copyWith({
    List<Chat>? chats,
    ChatLoadingState? loadingState,
    String? errorMessage,
    int? totalUnreadCount,
    bool? isLoadingUnreadCount,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: errorMessage ?? this.errorMessage,
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      isLoadingUnreadCount: isLoadingUnreadCount ?? this.isLoadingUnreadCount,
    );
  }
}

class ChatViewModel extends StateNotifier<ChatState> {
  final ChatRepository _repository;

  ChatViewModel(this._repository) : super(ChatState());

  // Fetch chats from the backend
  Future<void> fetchChats() async {
    state = state.copyWith(loadingState: ChatLoadingState.loading);
    
    try {
      final chats = await _repository.fetchChats();
      state = state.copyWith(
        chats: chats,
        loadingState: ChatLoadingState.loaded,
      );
      
      // After fetching chats, update the unread count
      fetchTotalUnreadCount();
    } catch (e) {
      state = state.copyWith(
        loadingState: ChatLoadingState.error,
        errorMessage: e.toString(),
      );
    }
  }
  
  // Fetch the total count of unread messages
  Future<void> fetchTotalUnreadCount() async {
    state = state.copyWith(isLoadingUnreadCount: true);
    
    try {
      final count = await _repository.getTotalUnreadCount();
      state = state.copyWith(
        totalUnreadCount: count,
        isLoadingUnreadCount: false,
      );
    } catch (e) {
      print("Error fetching total unread count: $e");
      // Don't update error state for the whole UI, just log it
      // and end the loading state
      state = state.copyWith(isLoadingUnreadCount: false);
    }
  }

  // Mark a chat as read and update the state
  Future<void> markChatAsRead(Chat chat) async {
      try {
      await _repository.markChatAsRead(chat.id);
      
      // Update local state to reflect the change
      final updatedChats = state.chats.map((c) {
        if (c.id == chat.id) {
          return c.copyWith(unreadCount: 0);
        }
        return c;
      }).toList();
      
      // Calculate new total unread count by subtracting the chat's unread count
      final newTotalUnread = state.totalUnreadCount - chat.unreadCount;
      
      state = state.copyWith(
        chats: updatedChats,
        totalUnreadCount: Math.max(0, newTotalUnread), // Ensure it's not negative
      );
    } catch (e) {
      // Handle error but don't change the UI state
      print("Error marking chat as read: ${e}");
      
      // Re-fetch unread count to ensure accuracy
      fetchTotalUnreadCount();
    }
  }

  // Mark a chat as unread and update the state
  Future<void> markChatAsUnread(Chat chat) async {
    try {
      await _repository.markChatAsUnread(chat.id);
      
      // Update local state to reflect the change
      final updatedChats = state.chats.map((c) {
        if (c.id == chat.id) {
          return c.copyWith(unreadCount: 1); // Set unread count to 1
        }
        return c;
      }).toList();
      
      // Update total unread count
      // If the chat already had unread messages, don't add anything
      // Otherwise add 1 (since we're adding an unread)
      final addToTotal = chat.unreadCount > 0 ? 0 : 1;
      
      state = state.copyWith(
        chats: updatedChats,
        totalUnreadCount: state.totalUnreadCount + addToTotal,
      );
    } catch (e) {
      // Handle error but don't change the UI state
      print("Error marking chat as unread: $e");
      
      // Re-fetch unread count to ensure accuracy
      fetchTotalUnreadCount();
    }
  }

  // Refresh chats (useful for pull-to-refresh functionality)
  Future<void> refreshChats() async {
    // Refresh both chats and unread count
    await fetchChats();
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
    ).then((_) {
      // Refresh unread count when returning from conversation
      fetchTotalUnreadCount();
    });
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
}

// Create a provider for chat management
final chatProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  final chatViewModel = ChatViewModel(repository);
  
  // Initial fetch
  chatViewModel.fetchChats();
  
  return chatViewModel;
});

// Provider for just the total unread count - useful for displaying in app bar or bottom navigation
final unreadCountProvider = Provider<int>((ref) {
  final chatState = ref.watch(chatProvider);
  return chatState.totalUnreadCount;
});