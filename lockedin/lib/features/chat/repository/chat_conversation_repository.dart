// chat_service.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/services/auth_service.dart';

class ChatConversationRepository {
  final AuthService _authService;
  
  ChatConversationRepository(this._authService);

  Future<Map<String, dynamic>> fetchConversation(String chatId) async {
    try {
      // Use the chat conversation endpoint from constants
      final endpoint = Constants.chatConversationEndpoint.replaceAll('{chatId}', chatId);
      debugPrint('Fetching conversation with endpoint: $endpoint');
      
      // Get the conversation
      final response = await RequestService.get(endpoint);
      
      // First check if we received HTML instead of JSON (which indicates a problem)
      if (response.body.contains('<!DOCTYPE html>') || 
          response.body.contains('<html>') ||
          !response.body.startsWith('{')) {
        
        debugPrint('Error: Received HTML instead of JSON when fetching conversation from fetchConversation');
        debugPrint('HTML Response (truncated): ${response.body.substring(0, math.min(200, response.body.length))}');
        
        // Instead of mock data, throw an exception with details
        throw Exception('API returned HTML instead of JSON. Status code: ${response.statusCode}. Check server configuration.');
      }
      
      // If we have a valid response, process it normally
      if (response.statusCode != 200) {
        throw Exception('Failed to load conversation: ${response.statusCode}');
      }
      
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      if (jsonData['success'] != true) {
        throw Exception('API returned error status: ${jsonData['message'] ?? "Unknown error"}');
      }
      
      return jsonData;
    } catch (e) {
      debugPrint('Error fetching conversation: $e');
      // Rethrow the error instead of returning mock data
      rethrow;
    }
  }
  
  /// Sends a new message to a specific chat
  /// 
  /// Format follows API documentation:
  /// {
  ///   "receiverId": "string",   // ID of the user receiving the message
  ///   "chatId": "string",       // ID of the chat conversation
  ///   "type": "direct",         // Type of chat (direct, group, etc.)
  ///   "messageText": "string",  // Text content of the message
  ///   "messageAttachment": null, // Optional file attachments
  ///   "replyTo": null           // Optional message being replied to
  /// }
  Future<bool> sendMessage({
    required String chatId,
    required String messageText,
    String chatType = 'direct',
    String? receiverId,
  }) async {
    try {
      // Make sure user data is loaded before trying to send a message
      await _authService.fetchCurrentUser();
      
      // Get the current user ID after ensuring it's loaded
      final currentUser = _authService.currentUser;
      if (currentUser == null) {
        debugPrint('Still no current user after fetchCurrentUser()');
        throw Exception('User not authenticated');
      }
      
      // Determine which user ID to use (current user by default, receiver if specified)
      final String userId = receiverId ?? currentUser.id;
      debugPrint('Using user ID for message: $userId (${receiverId != null ? "receiver ID" : "current user ID"})');
      
      // Create the request body exactly matching the API documentation
      final Map<String, dynamic> body = {
        'receiverId': userId,
        'chatId': chatId,
        'type': "direct", // Using 'type' field as shown in the API docs
        'messageText': messageText,
        'messageAttachment': null,
        'replyTo': null
      };
      
      // Log the request body for debugging
      debugPrint('Sending message with body: ${jsonEncode(body)}');
      
      // Use the new endpoint constant for messages
      final endpoint = Constants.chatMessagesEndpoint.replaceAll('{chatId}', chatId);
      debugPrint('Using messages endpoint: $endpoint');
      
      // Send the message
      final response = await RequestService.post(
        endpoint,
        body: body,
      );
      
      // Log detailed response information
      debugPrint('=== MESSAGE SEND RESPONSE ===');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Headers: ${response.headers}');
      
      // Check if we got HTML instead of JSON and throw an exception
      if (response.body.contains('<!DOCTYPE html>') || 
          response.body.contains('<html>') ||
          (response.body.isNotEmpty && !response.body.startsWith('{'))) {
        
        debugPrint('ERROR: Received HTML instead of JSON response from sendMessage');
        final htmlSnippet = response.body.substring(0, math.min(500, response.body.length));
        debugPrint('HTML Response (truncated): $htmlSnippet');
        
        // Throw exception with detailed error
        throw Exception('Server returned HTML instead of JSON. Status code: ${response.statusCode}. Check API endpoint configuration. HTML starts with: ${htmlSnippet.substring(0, math.min(100, htmlSnippet.length))}...');
      }
      
      // Log full response body for JSON responses
      debugPrint('Response Body (full): ${response.body}');
      
      // Try to parse as JSON if possible
      if (response.body.startsWith('{')) {
        try {
          final jsonResponse = jsonDecode(response.body);
          debugPrint('JSON Response: $jsonResponse');
          
          // Check if the API returned an error status
          if (jsonResponse['success'] == false) {
            throw Exception('API returned error status: ${jsonResponse['message'] ?? "Unknown error"}');
          }
        } catch (e) {
          debugPrint('Could not parse response as JSON: $e');
          throw Exception('Failed to parse JSON response: $e');
        }
      }
      
      // Check if the request was successful based on status code
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Message sent successfully!');
        return true;
      }
      
      // If the request failed, throw an exception with the status code
      throw Exception('Failed to send message: ${response.statusCode}');
    } catch (e) {
      debugPrint('Error sending message: $e');
      // Rethrow the exception to be handled by the caller
      rethrow;
    }
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final chatConversationRepositoryProvider = Provider<ChatConversationRepository>((ref) {
  final authService = ref.read(authServiceProvider);
  return ChatConversationRepository(authService);
}); 