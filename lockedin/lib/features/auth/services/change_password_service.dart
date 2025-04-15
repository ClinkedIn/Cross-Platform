import 'package:http/http.dart' as http;
import 'package:lockedin/core/services/request_services.dart';

class ChangePasswordService {
  static Future<http.Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      };

      // Call the API endpoint using the RequestService
      final response = await RequestService.patch(
        '/user/update-password',
        body: body,
      );

      print(
        'Password change response: ${response.statusCode}, ${response.body}',
      );
      return response;
    } catch (e) {
      print('Error in change password service: $e');
      throw Exception('Failed to update password: $e');
    }
  }
}
