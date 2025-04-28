import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/repository/blocked_repository.dart';

// State class for blocked users
class BlockedUsersState {
  final bool isLoading;
  final List<Map<String, dynamic>> blockedUsers;
  final String? errorMessage;

  BlockedUsersState({
    this.isLoading = false,
    this.blockedUsers = const [],
    this.errorMessage,
  });

  BlockedUsersState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? blockedUsers,
    String? errorMessage,
  }) {
    return BlockedUsersState(
      isLoading: isLoading ?? this.isLoading,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      errorMessage: errorMessage,
    );
  }
}

// View model class
class BlockedUsersViewModel extends StateNotifier<BlockedUsersState> {
  final BlockedRepository _repository;

  BlockedUsersViewModel(this._repository) : super(BlockedUsersState());

  // Fetch blocked users
  Future<void> fetchBlockedUsers() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      final blockedUsers = await _repository.getBlockedUsers();
      state = state.copyWith(isLoading: false, blockedUsers: blockedUsers);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to fetch blocked users: $e",
      );
    }
  }

  // Unblock a user
  Future<void> unblockUser(String userId) async {
    try {
      await _repository.unBlockUser(userId);

      // Remove the unblocked user from the list
      final updatedList = List<Map<String, dynamic>>.from(state.blockedUsers)
        ..removeWhere((user) => user['_id'] == userId);

      state = state.copyWith(blockedUsers: updatedList);
    } catch (e) {
      state = state.copyWith(errorMessage: "Failed to unblock user: $e");
    }
  }
}

// Provider for the repository
final blockedRepositoryProvider = Provider<BlockedRepository>((ref) {
  return BlockedRepository();
});

// Provider for the view model
final blockedUsersViewModelProvider =
    StateNotifierProvider<BlockedUsersViewModel, BlockedUsersState>((ref) {
      return BlockedUsersViewModel(ref.read(blockedRepositoryProvider));
    });
