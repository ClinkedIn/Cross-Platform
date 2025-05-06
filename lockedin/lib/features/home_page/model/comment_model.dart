import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lockedin/features/home_page/model/taggeduser_model.dart';

class CommentModel {
  final String id;
  final String userId;
  final String username;
  final String profileImageUrl;
  final String content;
  final String time;
  final bool isEdited;
  final int likes;
  final bool isLiked;
  final String? designation;
  final List<TaggedUser> taggedUsers;

  CommentModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.content,
    required this.time,
    this.isEdited = false,
    this.likes = 0,
    this.isLiked = false,
    this.designation,
    this.taggedUsers = const [],
  });

  // Fixed: Added taggedUsers to copyWith method
  CommentModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? profileImageUrl,
    String? content,
    String? time,
    bool? isEdited,
    int? likes,
    bool? isLiked,
    String? designation,
    List<TaggedUser>? taggedUsers,
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      content: content ?? this.content,
      time: time ?? this.time,
      isEdited: isEdited ?? this.isEdited,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      designation: designation ?? this.designation,
      taggedUsers: taggedUsers ?? this.taggedUsers,
    );
  }

  // Fixed: Added taggedUsers to toJson method
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'profileImageUrl': profileImageUrl,
      'content': content,
      'time': time,
      'isEdited': isEdited,
      'likes': likes,
      'isLiked': isLiked,
      'designation': designation,
      'createdAt': FieldValue.serverTimestamp(),
      'taggedUsers': taggedUsers.map((user) => user.toJson()).toList(),
    };
  }

  // Fixed: Added taggedUsers to fromFirestore factory
  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse taggedUsers if available
    List<TaggedUser> taggedUsersList = [];
    if (data['taggedUsers'] != null && data['taggedUsers'] is List) {
      taggedUsersList = List<TaggedUser>.from(
        (data['taggedUsers'] as List).map((user) => TaggedUser.fromJson(user))
      );
    }
    
    return CommentModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      content: data['content'] ?? '',
      time: data['time'] ?? '',
      isEdited: data['isEdited'] ?? false,
      likes: data['likes'] ?? 0,
      isLiked: data['isLiked'] ?? false,
      designation: data['designation'],
      taggedUsers: taggedUsersList,
    );
  }

  // Fixed: Added taggedUsers to fromJson factory
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    // Parse taggedUsers if available
    List<TaggedUser> taggedUsersList = [];
    if (json['taggedUsers'] != null && json['taggedUsers'] is List) {
      taggedUsersList = List<TaggedUser>.from(
        (json['taggedUsers'] as List).map((user) => TaggedUser.fromJson(user))
      );
    }
    
    return CommentModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      content: json['content'] ?? '',
      time: json['time'] ?? '',
      isEdited: json['isEdited'] ?? false,
      likes: json['likes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      designation: json['designation'],
      taggedUsers: taggedUsersList,
    );
  }
}