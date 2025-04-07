import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String profileImageUrl;
  final String content;
  final String time;
  final bool isEdited;
  final String? imageUrl;
  final int likes;
  final int comments;
  final int reposts;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.content,
    required this.time,
    required this.isEdited,
    this.imageUrl,
    required this.likes,
    required this.comments,
    required this.reposts,
  });

  // Convert model to map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'content': content,
      'time': time, 
      'isEdited': isEdited,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'reposts': reposts,
      'createdAt': FieldValue.serverTimestamp(), // Add server timestamp
    };
  }

  // Create model from Firestore document
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      content: data['content'] ?? '',
      time: data['time'] ?? '',
      isEdited: data['isEdited'] ?? false,
      imageUrl: data['imageUrl'],
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      reposts: data['reposts'] ?? 0,
    );
  }

  // Original fromJson method for compatibility
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      content: json['content'] ?? '',
      time: json['time'] ?? '',
      isEdited: json['isEdited'] ?? false,
      imageUrl: json['imageUrl'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      reposts: json['reposts'] ?? 0,
    );
  }

  
}