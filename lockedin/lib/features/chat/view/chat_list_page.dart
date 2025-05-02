import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/widgets/chat_item_widget.dart';
import 'package:lockedin/features/chat/viewModel/chat_viewmodel.dart';
import 'package:lockedin/core/services/auth_service.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(firebaseChatProvider);
    final chatViewModel = ref.read(firebaseChatProvider.notifier);
    final authService = AuthService();

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
            icon: Icon(Icons.info_outline),
            onPressed: () async {
              final user = authService.currentUser;
              final message = user != null
                  ? "User authenticated: ${user.id}"
                  : "No user authenticated!";
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: authService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          final isLoggedIn = snapshot.data ?? false;
          return _buildBody(context, chatState, chatViewModel, isLoggedIn, authService);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, 
    ChatState chatState, 
    FirebaseChatViewModel chatViewModel, 
    bool isLoggedIn,
    AuthService authService
  ) {
    if (!isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_circle_outlined, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text("Not signed in"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please sign in to view chats")),
                );
              },
              child: Text("Sign In"),
            ),
          ],
        ),
      );
    }

    if (chatState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Failed to load chats: ${chatState.errorMessage}"),
          ],
        ),
      );
    }
    
    if (chatState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Loading conversations..."),
          ],
        ),
      );
    }
    
    if (chatState.chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text("No chats yet. Start a conversation!"),
            SizedBox(height: 16),
            FutureBuilder(
              future: authService.fetchCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading user info...",
                      style: TextStyle(fontSize: 12, color: Colors.grey));
                }
                
                final user = snapshot.data;
                return Text(
                  user != null ? "Signed in as: ${user.email} ${user.id}" : "User info not available",
                  style: TextStyle(fontSize: 12, color: Colors.grey)
                );
              },
            ),
          ],
        ),
      );
    }
    
    final sortedChats = [...chatState.chats]
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
    return ListView.builder(
      itemCount: sortedChats.length,
      itemBuilder: (context, index) => ChatItem(
        chat: sortedChats[index],
        onTap: (context, chat) => chatViewModel.onChatItemTapped(context, chat),
        onLongPress: (context, chat) => chatViewModel.showChatOptionsMenu(context, chat),
      ),
    );
  }
}