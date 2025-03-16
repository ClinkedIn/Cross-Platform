import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:lockedin/features/auth/view/chats.dart';
import 'package:lockedin/features/auth/view/chat_item.dart';
import 'package:lockedin/features/auth/view/chat_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Chats")),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) => ChatItem(chat: chats[index]),
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