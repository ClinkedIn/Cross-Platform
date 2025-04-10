import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String url =
      "https://26c771aa-ae37-4fa8-b97f-085d46883af3.mock.pstmn.io/login2";

  final String forgotPasswordUrl =
      "https://b0a78715-5d8e-4e23-bda1-4d800a9e4a0f.mock.pstmn.io/forgotpass";

  // Add the headers for the request
  final Map<String, String> headers = {"Content-Type": "application/json"};

  // Add the login method
  // This method will be called when the user submits the login form
  Future<String> login(String email, String password) async {

   
    final Map<String, String> body = {"email": email, "password": password};

    // Make the POST request to the login endpoint
    // It will send the email and password to the server and handle the response
    final response = await http.post( 
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data["token"]; // Return the token if login is successful
    } else {
      throw Exception("Invalid email or password");
    }
  }

  // This method will be called when the user submits the forgot password form
  Future<void> forgotPassword(String emailOrPhone) async {
    final Map<String, String> body = {"email_or_phone": emailOrPhone};
    final response = await http.post(
      Uri.parse(forgotPasswordUrl),
      headers: headers,
      body: jsonEncode(body),
    );

  // Check if the request was successful
  if (response.statusCode == 200) {
    print("Success: ${response.body}");
  } else {
    print("Error: ${response.statusCode} - ${response.body}");
    throw Exception("Failed to send email. Please try again.");
  }
  }

  
  // This method will be called when the user submits the new password
  Future<void> resetPassword(String newPassword, bool requireSignIn) async {
    final String resetPasswordUrl = "your_reset_password_endpoint";
    final Map<String, dynamic> body = {
      "new_password": newPassword,
      "require_sign_in": requireSignIn
    };
    
    final response = await http.post(
      Uri.parse(resetPasswordUrl),
      headers: headers,
      body: jsonEncode(body),
    );
    
    if (response.statusCode != 200) {
      throw Exception("Failed to reset password.");
    }
  }
}
