import 'package:flutter/material.dart';
import 'package:lockedin/features/auth/view/chats.dart';

class ChatDetailScreen extends StatelessWidget {
  final Chat chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(chat.name),
      ),
      body: Center(
        child: Text('Chat history with ${chat.name} will be displayed here'),
     ),
    );
  }
}