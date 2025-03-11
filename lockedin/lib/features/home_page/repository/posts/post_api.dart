import 'package:lockedin/features/home_page/model/post_model.dart';

import 'post_repository.dart';

class PostApi implements PostRepository {
  final String apiUrl = "https://example.com/api/posts";

  @override
  Future<List<PostModel>> fetchHomeFeed() {
    // TODO: implement fetchHomeFeed
    throw UnimplementedError();
  }
}
