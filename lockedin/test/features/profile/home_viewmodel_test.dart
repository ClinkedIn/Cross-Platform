import 'package:flutter_test/flutter_test.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/home_page/repository/posts/mock_post_repository.dart';
import 'package:lockedin/features/home_page/viewModel/home_viewmodel.dart';
import 'package:lockedin/features/home_page/state/home_state.dart';

void main() {
  late MockPostRepository mockRepository;
  late HomeViewModel viewModel;

  setUp(() {
    mockRepository = MockPostRepository();
    viewModel = HomeViewModel(mockRepository);
  });

  group('fetchHomeFeed', () {
    test('fetches posts successfully', () async {
      await viewModel.fetchHomeFeed();

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.posts.length, 2);
      expect(viewModel.state.error, null);
    });

    test('handles fetch error', () async {
      mockRepository.shouldThrow = true;

      await viewModel.fetchHomeFeed();

      expect(viewModel.state.isLoading, false);
      expect(viewModel.state.error, isNotNull);
    });
  });

  group('savePostById', () {
    test('returns true on success', () async {
      final result = await viewModel.savePostById('1');

      expect(result, true);
      expect(viewModel.state.error, null);
    });

    test('handles save error', () async {
      mockRepository.shouldThrow = true;

      final result = await viewModel.savePostById('1');

      expect(result, false);
      expect(viewModel.state.error, isNotNull);
    });
  });

  group('toggleLike', () {
    test('likes a post', () async {
      viewModel.state = HomeState(
        posts: [
          PostModel(
            id: '1',
            userId: 'user1',
            username: 'User One',
            profileImageUrl: 'https://example.com/user1.jpg',
            content: 'This is a post',
            time: 'now',
            isEdited: false,
            imageUrl: null,
            likes: 0,
            comments: 0,
            reposts: 0,
            isLiked: false,
          ),
        ],
        isLoading: false,
      );

      final result = await viewModel.toggleLike('1');

      expect(result, true);
      expect(viewModel.state.posts.first.isLiked, true);
      expect(viewModel.state.posts.first.likes, 1);
    });

    test('unlikes a post', () async {
      viewModel.state = HomeState(
        posts: [
          PostModel(
            id: '2',
            userId: 'user2',
            username: 'User Two',
            profileImageUrl: 'https://example.com/user2.jpg',
            content: 'This is another post',
            time: 'now',
            isEdited: false,
            imageUrl: null,
            likes: 3,
            comments: 0,
            reposts: 0,
            isLiked: true,
          ),
        ],
        isLoading: false,
      );

      final result = await viewModel.toggleLike('2');

      expect(result, true);
      expect(viewModel.state.posts.first.isLiked, false);
      expect(viewModel.state.posts.first.likes, 2);
    });

    test('returns false if post not found', () async {
      final result = await viewModel.toggleLike('99');

      expect(result, false);
    });
  });
}
