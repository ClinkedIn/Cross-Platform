import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';

class SignupRepository {
  Future<http.Response> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final body = {
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "password": password,
      "remember_me": rememberMe,
    };
    print("bodyyy : $body");

    final response = await RequestService.post("/user", body: body);
    print("response ${response.statusCode} , response body: ${response.body}");
    return response;
  }
}
