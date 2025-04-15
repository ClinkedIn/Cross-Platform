import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/services/change_password_service.dart';

class ChangePasswordState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  ChangePasswordState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });
}

class ChangePasswordViewModel extends StateNotifier<ChangePasswordState> {
  ChangePasswordViewModel() : super(ChangePasswordState());

  Future<bool> changePassword(
    String newPassword,
    String currentPassword,
  ) async {
    state = ChangePasswordState(isLoading: true);

    try {
      final response = await ChangePasswordService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (response.statusCode == 200) {
        state = ChangePasswordState(
          successMessage: 'Password updated successfully',
        );
        return true;
      } else {
        state = ChangePasswordState(errorMessage: 'Failed to update password');
        return false;
      }
    } catch (e) {
      state = ChangePasswordState(errorMessage: e.toString());
      return false;
    }
  }
}

final changePasswordViewModelProvider =
    StateNotifierProvider<ChangePasswordViewModel, ChangePasswordState>((ref) {
      return ChangePasswordViewModel();
    });
