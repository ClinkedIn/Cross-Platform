//import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/view/chats.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

//////////static//////////

/// todos ///
/// set unread count to 0 when clicking on a chat
/// sort the chats by timestamp
/// mark a chat as read

final chatProvider = StateProvider<List<Chat>>((ref) => [
      Chat(
        name: "Lionel Messi",
        imageUrl: "https://img.a.transfermarkt.technology/portrait/header/28003-1740766555.jpg?lm=1",
        unreadCount: 1,
        lastMessage: "Have you seen the new Flutter update?",
        isSentByUser: false,
        timestamp: DateTime(2025, 3, 10),
      ),
      Chat(
        name: "Cristiano Ronaldo",
        imageUrl: "https://img.a.transfermarkt.technology/portrait/header/8198-1694609670.jpg?lm=1",
        unreadCount: 0,
        lastMessage: "I'm waiting for the new update!",
        isSentByUser: false,
        timestamp: DateTime(2025, 2, 16),
      ),
      Chat(
        name: "Mohamed Salah",
        imageUrl: "https://img.a.transfermarkt.technology/portrait/header/148455-1727337594.jpg?lm=1",
        unreadCount: 0,
        lastMessage: "Amazing performance last night!",
        isSentByUser: true,
        timestamp: DateTime(2025, 2, 12),
      ),
]);



// final chatProvider = FutureProvider<List<Chat>>((ref) async {
//   final response = await http.get(Uri.parse('https://your-backend.com/api/chats'));

//   if (response.statusCode == 200) {
//     final List<dynamic> data = json.decode(response.body);
//     List<Chat> chats = data.map((chat) => Chat(
//       name: chat['name'],
//       imageUrl: chat['imageUrl'],
//       unreadCount: chat['unreadCount'],
//       lastMessage: chat['lastMessage'],
//       isSentByUser: chat['isSentByUser'],
//       timestamp: DateTime.parse(chat['timestamp']),
//     )).toList();
//      chats.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//      return chats;
//   } else {
//     throw Exception('Failed to load chats');
// }
// });



// class ChatNotifier extends StateNotifier<List<Chat>> {
//   ChatNotifier() : super([]); // Initially empty, will be populated from the backend

//   // Fetch chats from backend (simulate API call)
//   Future<void> fetchChats() async {
//     // Simulated API response
//     await Future.delayed(Duration(seconds: 1)); 
//     state = [
//       Chat(name: 'Lionel Messi', 
//            imageUrl: 'https://img.a.transfermarkt.technology/portrait/header/28003-1740766555.jpg?lm=1',
//            lastMessage: 'Have you seen the new Flutter update?',
//            unreadCount: 2,
//            isSentByUser: false, 
//            timestamp: DateTime(2025, 3, 10)),

//       Chat(name: 'Cristiano Ronaldo',
//           imageUrl: 'https://img.a.transfermarkt.technology/portrait/header/8198-1694609670.jpg?lm=1',
//           lastMessage: 'I''m waiting for the new update!', 
//           unreadCount: 3, 
//           isSentByUser: true,
//           timestamp: DateTime(2025, 2, 16)),

//       Chat(name: 'Mohamed Salah',
//           imageUrl: 'https://img.a.transfermarkt.technology/portrait/header/148455-1727337594.jpg?lm=1',
//           lastMessage: 'Amazing performance last night!', 
//           unreadCount: 1, 
//           isSentByUser: true,
//           timestamp: DateTime(2025, 2, 12))
//     ];
//   }

//   // Function to mark a chat as read
//   void markChatAsRead(Chat chat) {
//     state = state.map((c) {
//       if (c.name == chat.name) {
//         return Chat(
//           name: c.name,
//           imageUrl: c.imageUrl,
//           lastMessage: c.lastMessage,
//           unreadCount: 0,
//           isSentByUser: c.isSentByUser, // Set unread count to 0
//           timestamp: c.timestamp,
//         );
//       }
//       return c;
//     }).toList();
//   }
// }

// // Provider instance
// final chatProvider = StateNotifierProvider<ChatNotifier, List<Chat>>((ref) {
//   return ChatNotifier();
// });

