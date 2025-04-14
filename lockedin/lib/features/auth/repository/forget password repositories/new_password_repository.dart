import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';

/// Repository for handling password reset operations
class NewPasswordRepository {
  /// Verifies if the reset token is valid
  /// 
  /// Returns true if token is valid, false otherwise
  Future<bool> verifyResetToken(String token) async {
    try {
      final response = await RequestService.get(
        '${Constants.resetPasswordEndpoint}',
        additionalHeaders: {"authorization": "Bearer $token"}
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying token: $e');
      return false;
    }
  }

  /// Resets the user's password using the provided token
  /// 
  /// Takes the new password and the reset token
  /// Throws an exception if the request fails
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final Map<String, dynamic> body = {"password": newPassword};
      
      final response = await RequestService.patch(
        '${Constants.resetPasswordEndpoint}',
        additionalHeaders: {"authorization": "Bearer $token"}, // PATCH /user/reset-password/{token}
        body: body
      );

      if (response.statusCode != 200) {
        print("Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to reset password. Please try again.");
      }
      
      print("Password reset successful");
    } catch (e) {
      throw Exception("Failed to reset password: ${e.toString()}");
    }
  }
}