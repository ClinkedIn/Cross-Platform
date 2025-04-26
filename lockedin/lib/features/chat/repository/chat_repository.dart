import 'dart:convert';
import 'package:lockedin/features/chat/model/chat_model.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';

/// Repository for handling chat-related API calls
class ChatRepository {
  /// Fetches all chats for the current user from the backend
  Future<List<Chat>> fetchChats() async {
    try {
      final response = await RequestService.get(Constants.allChatsEndpoint);
      
      if (response.statusCode != 200) {
        throw Exception("Failed to fetch chats: ${response.statusCode}");
      }
      
      // Parse the response body string to JSON
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      // Check for success
      if (jsonData['success'] != true) {
        throw Exception("API returned error status");
      }
      
      // Extract the chats list from the response
      final List<dynamic> chatData = jsonData['chats'];
      return chatData.map((chat) => Chat.fromJson(chat)).toList();
    } catch (e) {
      print("Error fetching chats: $e");
      throw Exception("Failed to load chats. Please try again.");
    }
  }
  
  /// Marks a chat as read in the backend
  Future<void> markChatAsRead(String chatId) async {
    print('Marking chat as read: $chatId');
    try {
      // Use proper endpoint for marking chat as read
      final endpoint = '${Constants.chatMarkAsReadEndpoint}/$chatId';
      
      final response = await RequestService.patch(
        endpoint,
        body:{}
      );
      
      if (response.statusCode != 200) {
        print("Error: ${response.statusCode}");
        throw Exception("Failed to mark chat as read: ${response.body}");
      }

      if (response.statusCode == 200) {
        print("${response.statusCode}: Chat marked as read successfully.");
      }

    } catch (e) {
      throw Exception("Failed to update chat status. Please try again.");
    }
  }
  
  /// Marks a chat as unread in the backend
  Future<void> markChatAsUnread(String chatId) async {
    try {
      // Use proper endpoint for marking chat as unread
      final endpoint = '${Constants.chatMarkAsUnreadEndpoint}/$chatId';
      
      final response = await RequestService.patch(
        endpoint,
        body: {'chatId': chatId}
      );
      
      if (response.statusCode != 200) {
        throw Exception("Failed to mark chat as unread: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        print("${response.statusCode}: Chat marked as unread successfully.");
      }

    } catch (e) {
      print("Error marking chat as unread: $e");
      throw Exception("Failed to update chat status. Please try again.");
    }
  }
  
  /// Gets the total count of unread messages across all chats
  Future<int> getTotalUnreadCount() async {
    try {
      // Use the endpoint from your API documentation
      final response = await RequestService.get(Constants.allChatsEndpoint);
      
      if (response.statusCode != 200) {
        throw Exception("Failed to fetch unread count: ${response.statusCode}");
      }

      if (response.statusCode == 200) {
        print("${response.statusCode}: Unread count fetched successfully.");
      }
      
      // Parse the response body string to JSON
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      // Extract the total unread count
      return jsonData['totalUnread'] as int;
    } catch (e) {
      print("Error fetching total unread count: $e");
      throw Exception("Failed to load unread message count. Please try again.");
    }
  }
}