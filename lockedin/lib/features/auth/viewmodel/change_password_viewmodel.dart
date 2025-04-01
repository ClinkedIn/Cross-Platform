import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/features/auth/view/change_password_page.dart';

// Provider for API service
final authServiceProvider = Provider((ref) => AuthService());

// ViewModel provider
final changePasswordViewModelProvider =
    StateNotifierProvider<ChangePasswordViewModel, AsyncValue<bool>>((ref) {
      final authService = ref.read(authServiceProvider);
      return ChangePasswordViewModel(authService, ref);
    });

class ChangePasswordViewModel extends StateNotifier<AsyncValue<bool>> {
  final AuthService authService;
  final Ref ref;

  ChangePasswordViewModel(this.authService, this.ref)
    : super(const AsyncValue.data(false));

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

class AuthService {
  final String _baseUrl =
      "https://a5a7a475-1f05-430d-a300-01cdf67ccb7e.mock.pstmn.io";
  final http.Client client; // Accepting the client as a constructor parameter

  // Constructor with a default value for client
  AuthService({http.Client? client}) : client = client ?? http.Client();

  Future<bool> changePasswordRequest(ChangePasswordRequest request) async {
    final response = await client.patch(
      Uri.parse("$_baseUrl/users/update-password"),
      body: jsonEncode(request.toJson()),
    );

    try {
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

class ChangePasswordRequest {
  final String newPassword;
  final String currentPassword;
  //final bool requireSignIn;

  ChangePasswordRequest({
    required this.newPassword,
    required this.currentPassword,
    //this.requireSignIn = true,
  });

  Map<String, dynamic> toJson() {
    return {
      "newPassword": newPassword,
      "currentPassword": currentPassword,
      //"requireSignIn": requireSignIn,
    };
  }
}
