import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/data/models/post_model.dart';
import 'package:lockedin/data/repositories/posts/post_api.dart';
import 'package:lockedin/data/repositories/posts/post_test.dart';
import '../../data/repositories/posts/post_repository.dart';

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((
  ref,
) {
  return HomeViewModel(PostTest()); // Switch PostTest() for testing
});

class HomeState {
  final List<PostModel> posts;
  final bool isLoading;
  HomeState({required this.posts, required this.isLoading});
}

class HomeViewModel extends StateNotifier<HomeState> {
  final PostRepository repository;

  HomeViewModel(this.repository)
    : super(HomeState(posts: [], isLoading: true)) {
    fetchHomeFeed();
  }

  Future<void> fetchHomeFeed() async {
    state = HomeState(posts: [], isLoading: true);
    final posts = await repository.fetchHomeFeed();
    state = HomeState(posts: posts, isLoading: false);
  }
}
