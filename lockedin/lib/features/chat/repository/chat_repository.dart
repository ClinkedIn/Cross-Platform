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
    try {
      // Use proper endpoint for marking chat as read - the URL was returning HTML docs
      // We'll create a proper URL that matches your API's expected format
      final endpoint = "/chats/${chatId}/mark-read";
      
      final response = await RequestService.post(
        endpoint,
        body: {'read': true}
      );
      
      if (response.statusCode != 200) {
        throw Exception("Failed to mark chat as read: ${response.statusCode}");
      }
    } catch (e) {
      print("Error marking chat as read: $e");
      throw Exception("Failed to update chat status. Please try again.");
    }
  }
}