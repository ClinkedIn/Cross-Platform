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
    final body = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "remember_me": rememberMe,
      "recaptchaResponseToken": "recaptchaResponseToken",
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
    final response = await RequestService.post("/user", body: body);
    return response;
  }
}
