import '../model/createpost_model.dart';


abstract class CreatePostRepository {
  Future<void> createPost(String content, String imagePath, String videoPath);
}