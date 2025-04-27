import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/home_page/repository/posts/post_repository.dart';

class MockPostRepository implements PostRepository {
  bool shouldThrow = false;

  final List<PostModel> _mockPosts = [
    PostModel(
      id: '1',
      userId: 'user1',
      username: 'john_doe',
      profileImageUrl: 'https://example.com/avatar1.png',
      content: 'Hello world!',
      time: '2h ago',
      isEdited: false,
      imageUrl: null,
      likes: 5,
      comments: 2,
      reposts: 1,
      isLiked: false,
      isMine: false,
    ),
    PostModel(
      id: '2',
      userId: 'user2',
      username: 'jane_doe',
      profileImageUrl: 'https://example.com/avatar2.png',
      content: 'Flutter is amazing!',
      time: '1h ago',
      isEdited: true,
      imageUrl: 'https://example.com/flutter.png',
      likes: 10,
      comments: 5,
      reposts: 3,
      isLiked: true,
      isMine: false,
    ),
  ];

  @override
  Future<List<PostModel>> fetchHomeFeed() async {
    if (shouldThrow) throw Exception("Error fetching posts");
    return _mockPosts;
  }

  @override
  Future<bool> savePostById(String postId) async {
    if (shouldThrow) throw Exception("Error saving post");
    return true; // Simulate a successful save
  }

  @override
  Future<bool> likePost(String postId) async {
    if (shouldThrow) return false;
    final index = _mockPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _mockPosts[index] = _mockPosts[index].copyWith(
        isLiked: true,
        likes: _mockPosts[index].likes + 1,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> unlikePost(String postId) async {
    if (shouldThrow) return false;
    final index = _mockPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _mockPosts[index] = _mockPosts[index].copyWith(
        isLiked: false,
        likes: _mockPosts[index].likes - 1,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> createRepost(String postId, {String? description}) async {
    if (shouldThrow) return false;
    final index = _mockPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _mockPosts[index] = _mockPosts[index].copyWith(
        reposts: _mockPosts[index].reposts + 1,
      );
      return true;
    }
    return false;
  }

  @override
  Future<bool> deleteRepost(String postId) async {
    if (shouldThrow) return false;
    final index = _mockPosts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _mockPosts[index] = _mockPosts[index].copyWith(
        reposts: _mockPosts[index].reposts - 1,
      );
      return true;
    }
    return false;
  }
  
  @override
  Future<bool> deletePost(String postId) {
    // TODO: implement deletePost
    throw UnimplementedError();
  }
}