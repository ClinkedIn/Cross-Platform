import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';

/// This file contains the repository for handling forgot password functionality.
/// It directly makes the API call without an additional service layer.

class ForgotPasswordRepository {
  /// Sends a forgot password request to the server for the given email address.
  /// 
  /// Throws an exception if the request fails.
  Future<void> forgotPassword(String email) async {
    try {
      final Map<String, String> body = {"email": email};
      
      final response = await RequestService.post(
        Constants.forgotPasswordEndpoint, // API endpoint
        body: body
      );

      // Check if the request was successful
      if (response.statusCode != 200) {
        print("Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to send email. Please try again.");
      }
      
      print("Success: ${response.body}");
    } catch (e) {
      throw Exception("Failed to reset password");
    }
  }
}