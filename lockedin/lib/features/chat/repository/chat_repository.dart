// chat_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/model/chat_message_model.dart';
import 'package:lockedin/features/chat/services/chat_service.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages(String chatId);
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  });
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatService _service;

  ChatRepositoryImpl(this._service);

  @override
  Future<List<ChatMessage>> getMessages(String chatId) async {
    try {
      return await _service.fetchMessages(chatId);
    } catch (e) {
      throw Exception("Failed to load messages: ${e.toString()}");
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    try {
      return await _service.sendMessage(
        chatId: chatId,
        senderId: senderId,
        content: content,
      );
    } catch (e) {
      throw Exception("Failed to send message: ${e.toString()}");
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatRepositoryImpl(chatService);
});