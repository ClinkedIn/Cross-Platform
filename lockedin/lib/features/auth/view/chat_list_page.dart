import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:lockedin/features/auth/view/chats.dart';
import 'package:lockedin/features/auth/view/chat_item.dart';
import 'package:lockedin/features/auth/view/chat_provider.dart';
//import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/text_styles.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatProvider);

    final sortedChats = chats.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Scaffold(
      appBar: AppBar(title: Text("Chats", style: AppTextStyles.headline1)),
      body: chats.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching
          : ListView.builder(
              itemCount: sortedChats.length,
              itemBuilder: (context, index) => ChatItem(chat: sortedChats[index]),
            ),
    );
  }
}


// class ChatListScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final chatAsyncValue = ref.watch(chatProvider);

//     return Scaffold(
//       appBar: AppBar(title: Text("Chats")),
//       body: chatAsyncValue.when(
//         data: (chats) => ListView.builder(
//           itemCount: chats.length,
//           itemBuilder: (context, index) => ChatItem(chat: chats[index]),
//         ),
//         loading: () => Center(child: CircularProgressIndicator()),
//         error: (err, stack) => Center(child: Text('Failed to load chats')),
//      ),
//     );
//   }
// }