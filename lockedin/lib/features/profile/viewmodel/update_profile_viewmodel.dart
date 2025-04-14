import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/service/update_profile_service.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';

// State class to manage the update process
class UpdateProfileState {
  final bool isLoading;
  final String? errorMessage;
  final bool isSuccess;

  UpdateProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  UpdateProfileState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return UpdateProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// ViewModel provider
final updateProfileProvider =
    StateNotifierProvider<UpdateProfileViewModel, UpdateProfileState>((ref) {
      return UpdateProfileViewModel(ref);
    });

class UpdateProfileViewModel extends StateNotifier<UpdateProfileState> {
  final Ref ref;

  UpdateProfileViewModel(this.ref) : super(UpdateProfileState());

  Future<bool> updateProfile(Map<String, String> userData) async {
    // Start loading
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      isSuccess: false,
    );

    try {
      // Clean up the data before sending
      Map<String, dynamic> cleanData = {};

      // Only include non-empty values
      userData.forEach((key, value) {
        if (value.trim().isNotEmpty) {
          cleanData[key] = value.trim();
        }
      });

      // Add nested objects if needed
      if (userData.containsKey('link') && userData['link']!.trim().isNotEmpty) {
        cleanData['contactInfo'] = {
          'website': {'url': userData['link'], 'type': 'personal'},
        };
        // Remove from top level since we've added it to nested structure
        cleanData.remove('link');
      }

      final response = await UpdateProfileService.updateProfile(cleanData);

      if (response.statusCode == 200) {
        // Success
        state = state.copyWith(isLoading: false, isSuccess: true);

        // Refresh the user data in the app
        await ref.read(profileViewModelProvider).fetchUser();

        return true;
      } else {
        // Error from server
        String errorMsg;
        try {
          final errorData = jsonDecode(response.body);
          errorMsg = errorData['message'] ?? 'Failed to update profile';
        } catch (_) {
          errorMsg =
              'Failed to update profile. Status code: ${response.statusCode}';
        }

        state = state.copyWith(
          isLoading: false,
          errorMessage: errorMsg,
          isSuccess: false,
        );
        return false;
      }
    } catch (e) {
      // Exception during update
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error: ${e.toString()}',
        isSuccess: false,
      );
      return false;
    }
  }

  void resetState() {
    state = UpdateProfileState();
  }
}
