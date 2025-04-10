// chat_service.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lockedin/features/chat/model/chat_message_model.dart';

class ChatService {
  final String baseUrl = "https://your-api-endpoint.com"; // Replace with your API

  Future<List<ChatMessage>> fetchMessages(String chatId) async {
    try {
      // For now, we'll mock this response
      // In a real app, you'd make an HTTP request
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay
      
      // Mock response
      final mockMessages = [
        {
          "id": "msg1",
          "senderId": "user2",
          "content": "Hi there!",
          "timestamp": DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
          "isRead": true
        },
        {
          "id": "msg2",
          "senderId": "current_user_id", 
          "content": "Hello! How are you?",
          "timestamp": DateTime.now().subtract(Duration(minutes: 25)).toIso8601String(),
          "isRead": true
        },
        {
          "id": "msg3",
          "senderId": "user2",
          "content": "I'm doing well, thanks for asking!",
          "timestamp": DateTime.now().subtract(Duration(minutes: 20)).toIso8601String(),
          "isRead": true
        }
      ];

      return mockMessages.map((json) => ChatMessage.fromJson(json)).toList();
      
      // In a real app, you'd do something like:
      /*
      final response = await http.get(
        Uri.parse('$baseUrl/chats/$chatId/messages'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load messages');
      }
      */
    } catch (e) {
      throw Exception("Error fetching messages: $e");
    }
  }

  Future<ChatMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    try {
      // Mock sending a message
      await Future.delayed(Duration(milliseconds: 500));
      
      // Return a mock new message
      return ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        senderId: senderId,
        content: content,
        timestamp: DateTime.now(),
        isRead: false,
      );
      
      // In a real app:
      /*
      final response = await http.post(
        Uri.parse('$baseUrl/chats/$chatId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'senderId': senderId,
          'content': content,
        }),
      );
      
      if (response.statusCode == 201) {
        return ChatMessage.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to send message');
      }
      */
    } catch (e) {
      throw Exception("Error sending message: $e");
    }
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});