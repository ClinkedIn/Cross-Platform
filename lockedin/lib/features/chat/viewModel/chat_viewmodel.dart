import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/features/chat/repository/chat_repository.dart';

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

  ChatState({
    this.chats = const [],
    this.loadingState = ChatLoadingState.initial,
    this.errorMessage,
  });

  ChatState copyWith({
    List<Chat>? chats,
    ChatLoadingState? loadingState,
    String? errorMessage,
  }) {
    return ChatState(
      chats: chats ?? this.chats,
      loadingState: loadingState ?? this.loadingState,
      errorMessage: errorMessage ?? this.errorMessage,
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
    } catch (e) {
      state = state.copyWith(
        loadingState: ChatLoadingState.error,
        errorMessage: e.toString(),
      );
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
      
      state = state.copyWith(chats: updatedChats);
    } catch (e) {
      // Handle error but don't change the UI state
      print("Error marking chat as read: $e");
    }
  }

  // Refresh chats (useful for pull-to-refresh functionality)
  Future<void> refreshChats() async {
    return fetchChats();
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