import 'post_repository.dart';
import '../../model/post_model.dart';

class PostTest implements PostRepository {
  @override
  Future<List<PostModel>> fetchHomeFeed() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return [
      PostModel(
        id: '1',
        userId: '100',
        username: 'Test User 1',
        content: 'This is a test post',
        likes: 10,
        comments: 3,
      ),
      PostModel(
        id: '2',
        userId: '101',
        username: 'Test User 2',
        content: 'Another test post',
        likes: 25,
        comments: 5,
      ),
    ];
  }
}
