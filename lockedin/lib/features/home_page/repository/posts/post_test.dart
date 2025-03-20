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
        profileImageUrl: 'https://i.pravatar.cc/150?img=10', // ✅ Reliable profile image
        content: 'This is a test post',
        time: '2d',
        isEdited: false,
        imageUrl: 'https://picsum.photos/800/600?random=1', // ✅ Reliable post image
        likes: 10,
        comments: 3,
        reposts: 2,
      ),
      PostModel(
        id: '2',
        userId: '101',
        username: 'Test User 2',
        profileImageUrl: 'https://i.pravatar.cc/150?img=15',
        content: 'Another test post',
        time: '5d',
        isEdited: true,
        imageUrl: 'https://picsum.photos/800/600?random=2',
        likes: 25,
        comments: 5,
        reposts: 4,
      ),
    ];
  }
}
