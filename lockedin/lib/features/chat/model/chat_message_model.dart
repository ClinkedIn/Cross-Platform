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