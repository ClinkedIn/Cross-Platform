import 'package:cloud_firestore/cloud_firestore.dart';
import 'taggeduser_model.dart';

class PostModel {
  final String id;
  final String userId;
  final Map<String,dynamic>? companyId;
  final String username;
  final String profileImageUrl;
  final String content;
  final String time;
  final bool isEdited;
  final String? imageUrl;
  final String? mediaType;
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
  final List<TaggedUser> taggedUsers; // Added field for tagged users

  PostModel({
    required this.id,
    required this.userId,
    this.companyId,
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
    this.isLiked = false,
    required this.isMine,
    this.isRepost = false,
    this.repostId,
    this.repostDescription,
    this.reposterId,
    this.reposterName,
    this.reposterProfilePicture,
    this.taggedUsers = const [], // Default to empty list
  });

  // Update copyWith to include taggedUsers
  PostModel copyWith({
    String? id,
    String? userId,
    Map<String,dynamic>? companyId,
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
    List<TaggedUser>? taggedUsers,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      content: content ?? this.content,
      time: time ?? this.time,
      isEdited: isEdited ?? this.isEdited,
      imageUrl: imageUrl ?? this.imageUrl,
      mediaType: mediaType ?? this.mediaType,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      reposts: reposts ?? this.reposts,
      isLiked: isLiked ?? this.isLiked,
      isMine: isMine ?? this.isMine,
      isRepost: isRepost ?? this.isRepost,
      repostId: repostId ?? this.repostId,
      repostDescription: repostDescription ?? this.repostDescription,
      reposterId: reposterId ?? this.reposterId,
      reposterName: reposterName ?? this.reposterName,
      reposterProfilePicture: reposterProfilePicture ?? this.reposterProfilePicture,
      taggedUsers: taggedUsers ?? this.taggedUsers,
    );
  }

  // Update toJson to include taggedUsers
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'companyId': companyId,
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
      'taggedUsers': taggedUsers.map((user) => user.toJson()).toList(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Update fromFirestore to include taggedUsers
  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Parse tagged users if they exist
    List<TaggedUser> parsedTaggedUsers = [];
    if (data['taggedUsers'] != null && data['taggedUsers'] is List) {
      parsedTaggedUsers = (data['taggedUsers'] as List)
          .map((user) => TaggedUser.fromJson(user as Map<String, dynamic>))
          .toList();
    }
    
    return PostModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      companyId: data['companyId'] != null ? Map<String,dynamic>.from(data['companyId']) : null,
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
      taggedUsers: parsedTaggedUsers,
    );
  }

  // Update fromJson to include taggedUsers
  factory PostModel.fromJson(Map<String, dynamic> json) {
    // Parse tagged users if they exist
    List<TaggedUser> parsedTaggedUsers = [];
    if (json['taggedUsers'] != null && json['taggedUsers'] is List) {
      parsedTaggedUsers = (json['taggedUsers'] as List)
          .map((user) => TaggedUser.fromJson(user as Map<String, dynamic>))
          .toList();
    }
    
    return PostModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      companyId: json['companyId'] != null ? Map<String,dynamic>.from(json['companyId']) : null,
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
      taggedUsers: parsedTaggedUsers,
    );
  }
}