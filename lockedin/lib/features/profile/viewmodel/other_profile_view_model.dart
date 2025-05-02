import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/repository/other_profile_repository.dart';
import 'package:lockedin/features/profile/state/other_profile_state.dart';

// Create a provider for the state notifier
final profileStateProvider =
    StateNotifierProvider<ProfileStateNotifier, ProfileViewState>((ref) {
      final repository = OtherProfileRepository();
      ;
      return ProfileStateNotifier(repository);
    });

// State notifier class
class ProfileStateNotifier extends StateNotifier<ProfileViewState> {
  final OtherProfileRepository _repository;

  // Initialize with a default state
  ProfileStateNotifier(this._repository)
    : super(
        ProfileViewState(
          user: UserModel.empty(),
          canSendConnectionRequest: false,
        ),
      );

  // Load a user profile
  Future<bool> loadUserProfile(String userId) async {
    try {
      final data = await _repository.getUserProfile(userId);
      print("User data:📀📀 ${data.user}");

      // Update state with new information
      state = ProfileViewState(
        user: data.user,
        canSendConnectionRequest: data.canSendConnectionRequest,
      );
      return true;
    } catch (e) {
      state = ProfileViewState(
        user: UserModel.empty(),
        canSendConnectionRequest: false,
      );
      print('Error loading profile: $e');
      return false;
    }
  }

  // Send a connection request
  Future<void> sendConnectionRequest() async {
    // Only proceed if we can send a request
    if (!state.canSendConnectionRequest) return;

    try {
      // await _repository.sendConnectionRequest(state.user.id);

      // Update state to reflect that a request has been sent
      state = state.copyWith(canSendConnectionRequest: false);
    } catch (e) {
      print('Error sending connection request: $e');
      rethrow;
    }
  }

  // Cancel a pending connection request
  Future<void> cancelConnectionRequest() async {
    try {
      // await _repository.cancelConnectionRequest(state.user.id);

      // Update state to reflect that we can now send a request again
      state = state.copyWith(canSendConnectionRequest: true);
    } catch (e) {
      print('Error canceling connection request: $e');
      rethrow;
    }
  }

  // Refresh the connection status
  // Future<void> refreshConnectionStatus() async {
  //   try {
  //     // final connectionStatus = await _repository.getConnectionStatus(
  //     //   state.user.id,
  //     // );
  //     // final canSend = connectionStatus == 'none';

  //     state = state.copyWith(canSendConnectionRequest: canSend);
  //   } catch (e) {
  //     print('Error refreshing connection status: $e');
  //     rethrow;
  //   }
  // }
}
