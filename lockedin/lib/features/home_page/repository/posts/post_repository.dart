import 'package:lockedin/features/home_page/model/post_model.dart';

abstract class PostRepository {
  Future<List<PostModel>> fetchHomeFeed();
  Future<void> savePostById(String postId); // Add this method
}
