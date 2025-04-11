import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';


class AuthService {
  

  // This method will be called when the user submits the forgot password form
  Future<void> forgotPassword(String email) async {

    final Map<String, String> body = {"email": email};

    final response = await RequestService.post('/user/forgot-password', body: body);

  // Check if the request was successful
  if (response.statusCode == 200) {
    print("Success: ${response.body}");
  } else {
    print("Error: ${response.statusCode} - ${response.body}");
    throw Exception("Failed to send email. Please try again.");
  }
  }
}
