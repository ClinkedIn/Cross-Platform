import 'dart:convert';
import 'post_repository.dart';
import '../../models/post_model.dart';

class PostApi implements PostRepository {
  final String apiUrl = "https://example.com/api/posts";

  @override
  Future<List<PostModel>> fetchHomeFeed() {
    // TODO: implement fetchHomeFeed
    throw UnimplementedError();
  }
}
