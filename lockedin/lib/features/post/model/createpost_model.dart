import 'dart:io';

/// Model class representing data required to create a post
class CreatePostModel {
  /// Required: The main text content of the post
  final String description;
  
  final List<File>? attachments;  // Updated type
  
  /// Optional: List of user IDs who are tagged in the post
  final List<String>? taggedUsers;
  
  /// Optional: Visibility setting - 'Anyone', 'Connections', etc.
  final String visibility;

  /// Constructor
  CreatePostModel({
    required this.description,
    this.attachments,
    this.taggedUsers,
    required this.visibility,
  });

  /// Convert model to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'attachments': attachments,
      'taggedUsers': taggedUsers,
      'visibility': visibility,
      // Note: imageFile is not included here as it needs special handling
      // for multipart form data uploads
    };
  }

  /// Create a copy of this model with specified fields updated
  CreatePostModel copyWith({
    String? description,
    List<File>? attachments,
    List<String>? taggedUsers,
    String? visibility,
  }) {
    return CreatePostModel(
      description: description ?? this.description,
      attachments: attachments ?? this.attachments,
      taggedUsers: taggedUsers ?? this.taggedUsers,
      visibility: visibility ?? this.visibility,
    );
  }

  /// Validate the post data
  bool isValid() {
    // Basic validation - description must not be empty
    return description.trim().isNotEmpty;
  }

  /// Factory to create from JSON response
  factory CreatePostModel.fromJson(Map<String, dynamic> json) {
    return CreatePostModel(
      description: json['description'] as String,
      attachments: json['attachments'] != null 
          ? List<File>.from(json['attachments']) 
          : null,
      taggedUsers: json['taggedUsers'] != null 
          ? List<String>.from(json['taggedUsers']) 
          : null,
      visibility: json['visibility'] as String? ?? 'Anyone',
    );
  }
}