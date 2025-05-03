import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';

class ChatMessage {
  final String id;
  final MessageSender sender;
  final String messageText;
  final List<String> messageAttachment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AttachmentType attachmentType;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.messageText,
    required this.createdAt,
    required this.updatedAt,
    this.messageAttachment = const [],
    this.attachmentType = AttachmentType.none,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'],
      sender: MessageSender.fromJson(json['sender']),
      messageText: json['messageText'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      messageAttachment: json['messageAttachment'] != null 
          ? List<String>.from(json['messageAttachment'])
          : [],
      attachmentType: _determineAttachmentType(json['messageAttachment']),
    );
  }

  factory ChatMessage.fromFirestore(Map<String, dynamic> data, String id) {
    // Extract user IDs
    final senderId = data['senderId'] ?? '';
    
    // Convert Firestore timestamp to DateTime
    final createdAt = data['timestamp'] is Timestamp 
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();
        
    final updatedAt = data['lastUpdatedAt'] is Timestamp 
        ? (data['lastUpdatedAt'] as Timestamp).toDate() 
        : createdAt;
        
    // Create sender object from participants map if available
    final Map<String, dynamic> participants = 
        data['participants'] is Map ? Map<String, dynamic>.from(data['participants']) : {};
    
    final sender = MessageSender(
      id: senderId,
      firstName: participants[senderId]?['firstName'] ?? '',
      lastName: participants[senderId]?['lastName'] ?? '',
      profilePicture: participants[senderId]?['profilePicture'],
    );
    
    // Handle attachments - check for mediaUrl first
    List<String> attachments = [];
    AttachmentType attachmentType = AttachmentType.none;
    
    // Check for mediaUrl and mediaType first (Firestore format)
    if (data['mediaUrl'] != null && data['mediaUrl'].toString().isNotEmpty) {
      attachments = [data['mediaUrl'].toString()];
      
      // Determine attachment type from mediaType
      if (data['mediaType'] != null) {
        final mediaType = data['mediaType'].toString().toLowerCase();
        if (mediaType == 'image') {
          attachmentType = AttachmentType.image;
        } else if (mediaType == 'document') {
          attachmentType = AttachmentType.document;
        } else if (mediaType == 'video') {
          attachmentType = AttachmentType.video;
        } else if (mediaType == 'audio') {
          attachmentType = AttachmentType.audio;
        } else if (mediaType == 'gif') {
          attachmentType = AttachmentType.gif;
        }
      }
    }
    // Fall back to the original attachments field
    else if (data['attachments'] != null) {
      if (data['attachments'] is List) {
        attachments = List<String>.from(data['attachments']);
      } else if (data['attachments'] is String && data['attachments'].isNotEmpty) {
        attachments = [data['attachments']];
      }
      
      // Get attachment type
      final type = data['attachmentType'];
      if (type == 'image') {
        attachmentType = AttachmentType.image;
      } else if (type == 'document') {
        attachmentType = AttachmentType.document;
      } else if (type == 'video') {
        attachmentType = AttachmentType.video;
      } else if (type == 'audio') {
        attachmentType = AttachmentType.audio;
      } else if (type == 'gif') {
        attachmentType = AttachmentType.gif;
      }
    }
    
    return ChatMessage(
      id: id,
      sender: sender,
      messageText: data['text'] ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
      messageAttachment: attachments,
      attachmentType: attachmentType,
    );
  }

  static AttachmentType _determineAttachmentType(List<dynamic>? attachments) {
    if (attachments == null || attachments.isEmpty) {
      return AttachmentType.none;
    }
    
    // You can implement logic to determine attachment type based on file extension
    // For now, just return image type if there's an attachment
    return AttachmentType.image;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'sender': sender.toJson(),
      'messageText': messageText,
      'messageAttachment': messageAttachment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isFromCurrentUser {
    // This will need to be updated based on your authentication system
    // to check if the message sender is the current user
    return false;
  }
}

class MessageSender {
  final String id;
  final String firstName;
  final String lastName;
  final String? profilePicture;

  MessageSender({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profilePicture,
  });

  factory MessageSender.fromJson(Map<String, dynamic> json) {
    return MessageSender(
      id: json['_id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePicture: json['profilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
    };
  }

  String get fullName => '$firstName $lastName';
}