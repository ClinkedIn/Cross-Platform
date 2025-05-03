import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/home_page/model/taggeduser_model.dart';

abstract class PostRepository {
  Future<Map<String, dynamic>> fetchHomeFeed({int page = 1, int limit = 10});
  Future<bool> savePostById(String postId); 
  Future<bool> unsavePostById(String postId);
  Future<bool> likePost(String postId);     
  Future<bool> unlikePost(String postId);    

   // Add these new methods for repost functionality
  Future<bool> createRepost(String postId, {String? description});
  Future<bool> deleteRepost(String repostId);
  // Add this method to your PostRepository interface
  Future<bool> deletePost(String postId);
  Future<bool> editPost(String postId, {required String content, List<TaggedUser>? taggedUsers});
   // Add these methods to the interface
  Future<bool> reportPost(String postId, String policy, {String? dontWantToSee});
  Future<List<TaggedUser>> searchUsers(String name, {int page = 1, int limit = 10});
  // Add this to the PostRepository interface
  Future<Map<String, dynamic>> getPostLikes(String postId,{int page = 10});
}
