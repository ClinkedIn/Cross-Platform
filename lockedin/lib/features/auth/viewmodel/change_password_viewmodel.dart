import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Provider for API service
final authServiceProvider = Provider((ref) => AuthService());

// ViewModel provider
final changePasswordViewModelProvider =
    StateNotifierProvider<ChangePasswordViewModel, AsyncValue<bool>>((ref) {
      final authService = ref.read(authServiceProvider);
      return ChangePasswordViewModel(authService);
    });

class ChangePasswordViewModel extends StateNotifier<AsyncValue<bool>> {
  final AuthService authService;

  ChangePasswordViewModel(this.authService)
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

      final success = await authService.changePassword(request);
      state = AsyncValue.data(success);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

class AuthService {
  final String _baseUrl =
      "https://a5a7a475-1f05-430d-a300-01cdf67ccb7e.mock.pstmn.io";
  String successMessage = "";
  String errorMessage = "";

  Future<bool> changePassword(ChangePasswordRequest request) async {
    final response = await http.patch(
      Uri.parse("$_baseUrl/users/update-password"),
      body: jsonEncode(request.toJson()),
    );

    try {
      if (response.statusCode == 200) {
        successMessage = " ✅ Password changed successfully";
        print("✅ Success: ${response.body}");
        return true; // Password changed successfully
      } else {
        errorMessage = "❌ Error changing password";
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
