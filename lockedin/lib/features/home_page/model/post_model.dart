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
  final String? mediaType; // Add this field to explicitly set media type
  final int likes;
  final int comments;
  final int reposts;
  final bool isLiked;
  final bool isMine;
  final bool isRepost;
  final String? repostId;
  final String? repostDescription;
  final String? reposterId;
  final String? reposterName;
  final String? reposterProfilePicture;
  

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.profileImageUrl,
    required this.content,
    required this.time,
    required this.isEdited,
    this.imageUrl,
    this.mediaType,
    required this.likes,
    required this.comments,
    required this.reposts,
    this.isLiked = false, // Default to not liked
    required this.isMine,
    this.isRepost = false,
    this.repostId,
    this.repostDescription,
    this.reposterId,
    this.reposterName,
    this.reposterProfilePicture,
  });

  // Add copyWith method for easy modification of post properties
  PostModel copyWith({
    String? id,
    String? userId,
    String? username,
    String? profileImageUrl,
    String? content,
    String? time,
    bool? isEdited,
    String? imageUrl,
    String? mediaType,
    int? likes,
    int? comments,
    int? reposts,
    bool? isLiked,
    bool? isMine,
    bool? isRepost,
    String? repostId,
    String? repostDescription,
    String? reposterId,
    String? reposterName,
    String? reposterProfilePicture,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      content: content ?? this.content,
      time: time ?? this.time,
      isEdited: isEdited ?? this.isEdited,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      reposts: reposts ?? this.reposts,
      isLiked: isLiked ?? false,
      isMine: isMine ?? this.isMine,
      isRepost: isRepost ?? this.isRepost,
      repostId: repostId ?? this.repostId,
      repostDescription: repostDescription ?? this.repostDescription,
      reposterId: reposterId ?? this.reposterId,
      reposterName: reposterName ?? this.reposterName,
      reposterProfilePicture: reposterProfilePicture ?? this.reposterProfilePicture,
    );
  }

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
      'mediaType': mediaType,
      'likes': likes,
      'comments': comments,
      'reposts': reposts,
      'isLiked': isLiked,
      'isMine': isMine,
      'isRepost': isRepost,
      'repostId': repostId,
      'repostDescription': repostDescription,
      'reposterId': reposterId,
      'reposterName': reposterName,
      'reposterProfilePicture': reposterProfilePicture,
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
      mediaType: data['mediaType'],
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      reposts: data['reposts'] ?? 0,
      isLiked: data['isLiked'] ?? false,
      isMine: data['isMine'] ?? false,
      isRepost: data['isRepost'] ?? false,
      repostId: data['repostId'],
      repostDescription: data['repostDescription'],
      reposterId: data['reposterId'],
      reposterName: data['reposterName'],
      reposterProfilePicture: data['reposterProfilePicture'],
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
      mediaType: json['mediaType'],
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      reposts: json['reposts'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      isMine: json['isMine'] ?? false,
      isRepost: json['isRepost'] ?? false,
      repostId: json['repostId'],
      repostDescription: json['repostDescription'],
      reposterId: json['reposterId'],
      reposterName: json['reposterName'],
      reposterProfilePicture: json['reposterProfilePicture'],
    );
  }
}