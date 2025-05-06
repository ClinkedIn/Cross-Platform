import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/networks/model/user_model.dart';
import 'package:lockedin/features/networks/repository/user_search_repository.dart';
import 'package:lockedin/features/networks/state/user_search_state.dart';

// User search view model
class UserSearchViewModel extends StateNotifier<UserSearchState> {
  final UserSearchRepository repository;
  
  UserSearchViewModel(this.repository) : super(UserSearchState.initial());
  
  // Search users by keyword
// Update the searchUsers method:

  Future<void> searchUsers(String keyword) async {
    if (keyword.trim().isEmpty) {
      state = state.copyWith(
        showResults: false,
        searchResults: [],
        keyword: '',
      );
      return;
    }

    // Validate minimum length requirement
    if (keyword.trim().length < 2) {
      state = state.copyWith(
        error: 'Search term must be at least 2 characters',
        keyword: keyword,
        showResults: true,
        isLoading: false,
      );
      return;
    }
    
    state = state.copyWith(
      isLoading: true,
      error: null,
      keyword: keyword,
      showResults: true,
    );
    
    try {
      final result = await repository.searchUsers(keyword);
      
      // Check if there's an error returned from the repository
      if (result.containsKey('error')) {
        state = state.copyWith(
          isLoading: false,
          error: result['error'] as String,
          searchResults: [], // Clear results on error
        );
        return;
      }
      
      // Fix the type casting issue - don't assume it's already UserModel objects
      final List<dynamic> usersData = result['users'] as List<dynamic>;
      final List<UserModel> users = usersData.map((userData) {
        if (userData is UserModel) return userData;
        
        // Convert each item to UserModel if needed
        return UserModel(
          id: userData['_id'] ?? userData['id'] ?? '',
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          email: userData['email'] ?? '',
          profilePicture: userData['profilePicture'] ?? '',
          headline: userData['headline'] ?? userData['title'] ?? '',
          connectionStatus: userData['connectionStatus'] ?? 'none',
          currentCompany: userData['currentCompany'],
          currentPosition: userData['currentPosition'],
          connections: userData['connections'] ?? 0,
          isFollowing: userData['isFollowing'] ?? false,
        );
      }).toList();
      
      debugPrint('✅ Processed ${users.length} users from search results');
      
      state = state.copyWith(
        searchResults: users,
        isLoading: false,
        pagination: result['pagination'],
      );
    } catch (e) {
      debugPrint('❌ Error processing user search results: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // Load more results for pagination
  Future<void> loadMoreResults() async {
    if (state.isLoading) return;
    
    // Safe access with null checking and defaults
    final currentPage = state.pagination['page'] as int? ?? 1;
    final totalPages = state.pagination['pages'] as int? ?? 1;
    
    if (currentPage >= totalPages) return;
    
    state = state.copyWith(isLoading: true);
    
    try {
      final result = await repository.searchUsers(
        state.keyword,
        page: currentPage + 1,
      );
      
      // Correctly handle the list of users
      final List<dynamic> newUsersData = result['users'] as List<dynamic>;
      final List<UserModel> newUsers = newUsersData.map((userData) {
        if (userData is UserModel) return userData;
        
        return UserModel(
          id: userData['_id'] ?? userData['id'] ?? '',
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          email: userData['email'] ?? '',
          profilePicture: userData['profilePicture'] ?? '',
          headline: userData['headline'] ?? userData['title'] ?? '',
          connectionStatus: userData['connectionStatus'] ?? 'none',
          currentCompany: userData['currentCompany'],
          currentPosition: userData['currentPosition'],
          connections: userData['connections'] ?? 0,
          isFollowing: userData['isFollowing'] ?? false,
        );
      }).toList();
      
      state = state.copyWith(
        searchResults: [...state.searchResults, ...newUsers],
        isLoading: false,
        pagination: result['pagination'],
      );
    } catch (e) {
      debugPrint('❌ Error loading more user search results: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  // Hide results
  void hideResults() {
    state = state.copyWith(showResults: false);
  }
  
  // Show results
  void showResults() {
    if (state.keyword.isNotEmpty) {
      state = state.copyWith(showResults: true);
    }
  }
  
  // Clear search
  void clearSearch() {
    state = UserSearchState.initial();
  }
}

// Providers
final userSearchRepositoryProvider = Provider<UserSearchRepository>((ref) {
  return UserSearchRepository();
});

final userSearchViewModelProvider = StateNotifierProvider<UserSearchViewModel, UserSearchState>((ref) {
  final repository = ref.watch(userSearchRepositoryProvider);
  return UserSearchViewModel(repository);
});