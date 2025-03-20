import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:lockedin/features/auth/view/chats.dart';

class ChatNotifier extends StateNotifier<List<Chat>> {
  ChatNotifier() : super([]);

  // Function to simulate fetching chats with a delay
  Future<void> fetchChats() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate API delay

    state = [
      Chat(
        name: "Lionel Messi",
        imageUrl: "https://img.a.transfermarkt.technology/portrait/header/28003-1740766555.jpg?lm=1",
        unreadCount: 1,
        lastMessage: "Have you seen the new Flutter update?",
        isSentByUser: false,
        timestamp: DateTime(2025, 3, 16, 10, 30),
      ),
      Chat(
        name: "Cristiano Ronaldo",
        imageUrl: "https://img.a.transfermarkt.technology/portrait/header/8198-1694609670.jpg?lm=1",
        unreadCount: 2,
        lastMessage: "I'm waiting for the new update!",
        isSentByUser: false,
        timestamp: DateTime(2025, 2, 16, 11, 54),
      ),
      Chat(
        name: "Mohamed Salah",
        imageUrl: "https://img.a.transfermarkt.technology/portrait/header/148455-1727337594.jpg?lm=1",
        unreadCount: 3,
        lastMessage: "Amazing performance last night!",
        isSentByUser: true,
        timestamp: DateTime(2024, 12, 12, 22, 33),
      ),
    ];
  }

  // Function to mark chat as read
  void markChatAsRead(Chat chat) {
    state = state.map((c) {
      if (c.name == chat.name) {
        return c.copyWith(unreadCount: 0);
      }
      return c;
    }).toList();
  }
}

// Create a provider for chat management
final chatProvider = StateNotifierProvider<ChatNotifier, List<Chat>>((ref) {
  final chatNotifier = ChatNotifier();
  chatNotifier.fetchChats(); // Trigger chat fetching with delay
  return chatNotifier;
});
