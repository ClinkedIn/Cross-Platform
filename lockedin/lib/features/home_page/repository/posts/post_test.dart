import 'post_repository.dart';
import '../../model/post_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PostTest implements PostRepository {
  // In-memory collection of posts for testing
  static final List<PostModel> _testPosts = [
    PostModel(
      id: '1',
      userId: '100',
      username: 'Jane Smith',
      profileImageUrl: 'https://i.pravatar.cc/150?img=10',
      content: 'Just completed my first project using Flutter! #MobileDevelopment #Flutter',
      time: '2d',
      isEdited: false,
      imageUrl: 'https://picsum.photos/800/600?random=1',
      likes: 42,
      comments: 7,
      reposts: 5,
    ),
    PostModel(
      id: '2',
      userId: '101',
      username: 'Alex Johnson',
      profileImageUrl: 'https://i.pravatar.cc/150?img=15',
      content: 'Excited to announce I\'ve joined Microsoft as a Senior Developer! Looking forward to this new chapter in my career. #NewJob #Microsoft',
      time: '5d',
      isEdited: true,
      imageUrl: 'https://picsum.photos/800/600?random=2',
      likes: 87,
      comments: 23,
      reposts: 12,
    ),
    PostModel(
      id: '3',
      userId: '102',
      username: 'Emily Chen',
      profileImageUrl: 'https://i.pravatar.cc/150?img=20',
      content: 'Attended the AI Summit yesterday. So many groundbreaking innovations in machine learning this year!',
      time: '1d',
      isEdited: false,
      imageUrl: null,
      likes: 31,
      comments: 5,
      reposts: 2,
    ),
    PostModel(
      id: '4',
      userId: '100',
      username: 'Jane Smith',
      profileImageUrl: 'https://i.pravatar.cc/150?img=10',
      content: 'Working on a new open-source project. Can\'t wait to share it with everyone!',
      time: '3h',
      isEdited: false,
      imageUrl: null,
      likes: 16,
      comments: 2,
      reposts: 0,
    ),
  ];

  @override
  Future<List<PostModel>> fetchHomeFeed() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return List.from(_testPosts); // Return a copy
  }


  // Get posts for feed (with pagination support)
  static Future<List<PostModel>> getFeedPosts({
    int? lastIndex,
    int limit = 10,
    List<String>? userIds,
  }) async {
    await Future.delayed(Duration(milliseconds: 800));
    
    List<PostModel> filteredPosts = List.from(_testPosts);
    
    // Filter by specific users if provided
    if (userIds != null && userIds.isNotEmpty) {
      filteredPosts = filteredPosts.where((post) => userIds.contains(post.userId)).toList();
    }
    
    // Sort by "time" (for this test implementation we'll just use the existing order)
    
    // Apply pagination
    if (lastIndex != null) {
      if (lastIndex >= filteredPosts.length - 1) {
        return []; // No more posts
      }
      
      final startIndex = lastIndex + 1;
      final endIndex = startIndex + limit > filteredPosts.length 
          ? filteredPosts.length 
          : startIndex + limit;
          
      return filteredPosts.sublist(startIndex, endIndex);
    }
    
    // Return first page
    return filteredPosts.length > limit 
        ? filteredPosts.sublist(0, limit) 
        : filteredPosts;
  }
    @override
  Future<void> savePostById(String postId) async {
    // Implementation to call backend API
    // Example:
    final response = await http.post(
      Uri.parse('https://your-api.com/posts/save'),
      headers: {
        'Content-Type': 'application/json',
       // 'Authorization': 'Bearer ${await TokenService.getToken()}',
      },
      body: jsonEncode({'postId': postId}),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to save post: ${response.body}');
    }
  }

}