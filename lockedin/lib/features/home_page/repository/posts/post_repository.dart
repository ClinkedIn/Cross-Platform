import 'package:lockedin/features/home_page/model/post_model.dart';

abstract class PostRepository {
  Future<List<PostModel>> fetchHomeFeed();
  Future<bool> savePostById(String postId); // Add this method
  Future<bool> likePost(String postId);      // New method for liking
  Future<bool> unlikePost(String postId);    // New method for unliking

   // Add these new methods for repost functionality
  Future<bool> createRepost(String postId, {String? description});
  Future<bool> deleteRepost(String repostId);
  // Add this method to your PostRepository interface
  Future<bool> deletePost(String postId);
}
