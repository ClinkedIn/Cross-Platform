import 'dart:convert';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';

/// Repository for handling verification code operations related to password reset
class VerificationCodeRepository {
  /// Verifies the OTP code sent to the user's email or phone
  /// 
  /// Returns a reset token on successful verification
  /// Throws an exception if the request fails
  Future<String> verifyResetCode(String otp) async {
    try {
      final Map<String, String> body = {"otp": otp};
      
      final response = await RequestService.post(
        Constants.verifyResetPasswordOtpEndpoint, // API endpoint for verifying OTP
        body: body
      );

      // Check if the request was successful
      if (response.statusCode != 200) {
        print("Error: ${response.statusCode} - ${response.body}");
        throw Exception("Invalid verification code. Please try again.");
      }
      
      // Parse the response to get the token
      final responseData = jsonDecode(response.body);
      final String token = responseData['resetToken'] ?? '';
      
      if (token.isEmpty) {
        throw Exception("Token not received from server");
      }
      
      return token;
    } catch (e) {
      throw Exception("Failed to verify code: ${e.toString()}");
    }
  }
  
  /// Resends the verification code to the user's email or phone
  /// 
  /// Takes the email or phone to which the code should be resent
  /// Uses the same endpoint as the forgot password request
  /// Returns void on success, throws an exception on failure
  Future<void> resendVerificationCode(String emailOrPhone) async {
    try {
      final Map<String, String> body = {"email": emailOrPhone};
      
      final response = await RequestService.post(
        Constants.forgotPasswordEndpoint, // Reusing the same endpoint as forgot password
        body: body
      );

      if (response.statusCode != 200) {
        print("Error: ${response.statusCode} - ${response.body}");
        throw Exception("Failed to resend code. Please try again.");
      }
      
      print("Verification code resent successfully");
    } catch (e) {
      throw Exception("Failed to resend verification code");
    }
  }
}