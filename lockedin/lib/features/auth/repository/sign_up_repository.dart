import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';

class SignupRepository {
  Future<http.Response> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool rememberMe,
    String? fcmToken,
  }) async {
    final response = await RequestService.signup(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      rememberMe: rememberMe,
      fcmToken: fcmToken ?? 'fcmToken',
    );
    return response;
  }

  Future<http.Response> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    final body = {"otp": otp};
    final response = await RequestService.post(
      "/user/confirm-email",
      body: body,
    );
    return response;
  }
}
