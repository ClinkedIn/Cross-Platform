// chat_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/core/services/request_services.dart';

class ChatConversationRepository {
  Future<Map<String, dynamic>> fetchConversation(String chatId) async {
    try {
      final response = await RequestService.get(Constants.chatConversationEndpoint.replaceAll('{chatId}', chatId));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to load conversation: ${response.statusCode}');
      }
      
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      
      if (jsonData['success'] != true) {
        throw Exception('API returned error status');
      }
      
      return jsonData;
    } catch (e) {
      throw Exception("Error fetching conversation: $e");
    }
  }
}

final chatConversationRepositoryProvider = Provider<ChatConversationRepository>((ref) {
  return ChatConversationRepository();
}); 