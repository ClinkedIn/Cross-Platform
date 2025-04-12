import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/auth/view/change_password_page.dart';

/// Provider for the [AuthService], responsible for making API calls.
final authServiceProvider = Provider((ref) => AuthService());

/// Provider for the [ChangePasswordViewModel], managing the state of the password change process.
final changePasswordViewModelProvider =
    StateNotifierProvider<ChangePasswordViewModel, AsyncValue<bool>>((ref) {
      final authService = ref.read(authServiceProvider);
      return ChangePasswordViewModel(authService, ref);
    });

/// ViewModel class that manages the logic for changing a user's password.
class ChangePasswordViewModel extends StateNotifier<AsyncValue<bool>> {
  final AuthService authService;
  final Ref ref;

  /// Initializes the state as not loading and not successful by default.
  ChangePasswordViewModel(this.authService, this.ref)
    : super(const AsyncValue.data(false));

  /// Handles the entire change password process.
  /// - Sends the change password request.
  /// - Updates the state based on the result.
  /// - Sets a status message using [passwordStateProvider].
  Future<void> changePassword(
    String newPassword,
    String currentPassword,
  ) async {
    state = const AsyncValue.loading();

    try {
      final request = ChangePasswordRequest(
        newPassword: newPassword,
        currentPassword: currentPassword,
        //requireSignIn: requireSignIn,
      );

      final success = await authService.changePasswordRequest(request);
      state = AsyncValue.data(success);
      ref
          .read(passwordStateProvider.notifier)
          .setStatusMessage(
            success
                ? "✅ Password changed successfully"
                : "❌ Error changing password",
          );
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Service responsible for sending the change password request to the backend.
class AuthService {
  final String _baseUrl =
      "https://a5a7a475-1f05-430d-a300-01cdf67ccb7e.mock.pstmn.io";
  final http.Client client; // Accepting the client as a constructor parameter

  /// Accepts an optional HTTP client (useful for mocking in tests).
  AuthService({http.Client? client}) : client = client ?? http.Client();

  /// Sends a PATCH request to change the user's password.
  /// Returns `true` if the status code is 200, `false` otherwise.
  Future<bool> changePasswordRequest(ChangePasswordRequest request) async {
    try {
      final response = await RequestService.patch(
        "/user/update-password",
        body: request.toJson(),
      );

      if (response.statusCode == 200) {
        print("✅ Success: ${response.body}");
        return true; // Password changed successfully
      } else {
        print("❌ API Error: ${response.statusCode} - ${response.body}");
        return false; // Password change failed
      }
    } catch (e) {
      print("❌ Exception: $e");
      return false; // Password change failed
    }
  }
}

/// Model representing the request to change a user's password.
class ChangePasswordRequest {
  final String newPassword;
  final String currentPassword;
  //final bool requireSignIn;

  ChangePasswordRequest({
    required this.newPassword,
    required this.currentPassword,
    //this.requireSignIn = true,
  });

  /// Converts the request to JSON format for the HTTP request body.
  Map<String, dynamic> toJson() {
    return {
      "newPassword": newPassword,
      "currentPassword": currentPassword,
      //"requireSignIn": requireSignIn,
    };
  }
}
