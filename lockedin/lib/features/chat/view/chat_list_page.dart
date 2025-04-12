import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/view/chat_item.dart';
import 'package:lockedin/features/chat/viewModel/chat_viewmodel.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final chatViewModel = ref.read(chatProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chats",
          style: AppTextStyles.headline1.copyWith(
            color: ref.watch(themeProvider) == AppTheme.darkTheme
                ? Colors.white
                : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => chatViewModel.refreshChats(),
          ),
        ],
      ),
      body: _buildBody(context, chatState, chatViewModel),
    );
  }

  Widget _buildBody(BuildContext context, ChatState chatState, ChatViewModel chatViewModel) {
    switch (chatState.loadingState) {
      case ChatLoadingState.loading:
      case ChatLoadingState.initial:
        return const Center(child: CircularProgressIndicator());
        
      case ChatLoadingState.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Failed to load chats: ${chatState.errorMessage}"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => chatViewModel.fetchChats(),
                child: const Text("Try Again"),
              ),
            ],
          ),
        );
        
      case ChatLoadingState.loaded:
        if (chatState.chats.isEmpty) {
          return const Center(
            child: Text("No chats yet. Start a conversation!"),
          );
        }
        
        // Sort chats by timestamp (newest first)
        final sortedChats = [...chatState.chats]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
          
        return RefreshIndicator(
          onRefresh: () => chatViewModel.refreshChats(),
          child: ListView.builder(
            itemCount: sortedChats.length,
            itemBuilder: (context, index) => ChatItem(chat: sortedChats[index]),
          ),
        );
    }
  }
}