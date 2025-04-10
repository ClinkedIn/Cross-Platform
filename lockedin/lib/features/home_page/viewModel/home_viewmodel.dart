import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/post_model.dart';
import '../repository/posts/post_repository.dart';
import '../repository/posts/post_api.dart';
import '../repository/posts/post_test.dart';
import '../state/home_state.dart';

/// Provider for the HomeViewModel
final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  // You can switch between PostTest and PostApi here
  // For production: return HomeViewModel(PostApi());
  return HomeViewModel(PostApi());
});

/// ViewModel for the home page
class HomeViewModel extends StateNotifier<HomeState> {
  final PostRepository repository;

  /// Constructor
  HomeViewModel(this.repository) : super(HomeState.initial()) {
    fetchHomeFeed();
  }

  /// Fetch posts for the home feed
  Future<void> fetchHomeFeed() async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, error: null);
      
      // Fetch posts from repository
      final posts = await repository.fetchHomeFeed();
      
      // Update state with fetched posts
      state = state.copyWith(
        posts: posts,
        isLoading: false,
      );
    } catch (e) {
      // Handle errors
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Refresh feed data
  Future<void> refreshFeed() async {
    await fetchHomeFeed();
  }

  
  /// Save post for later reading using post ID
    Future<void> savePostById(String postId) async {
      try {
        // Set loading state
        state = state.copyWith(isLoading: true, error: null);
        
        // Send post ID to repository
        await repository.savePostById(postId);
        
        // Update state after successfully saving
        state = state.copyWith(
          isLoading: false,
        );
      } catch (e) {
        // Handle errors
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
}