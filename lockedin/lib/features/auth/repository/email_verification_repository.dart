import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailVerificationRepository {
  final String _baseUrl =
      "https://cbb4b710-1c24-474e-be55-7775acae3203.mock.pstmn.io";

  Future<String?> sendVerificationEmail() async {
    final url = Uri.parse("$_baseUrl/confirm-email");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data["emailVerificationToken"];
      } else if (response.statusCode == 401) {
        throw Exception("Unauthorized: User must be logged in");
      } else {
        throw Exception("Failed to send verification email");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
