import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditEmailRepository {
  Future<Map<String, dynamic>> updateEmail(
    String newEmail,
    String password,
  ) async {
    final url = Uri.parse(
      "https://cbb4b710-1c24-474e-be55-7775acae3203.mock.pstmn.io/update",
    );

    // Retrieve token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'newEmail': newEmail, 'password': password}),
    );

    // 🔥 Print the response for debugging
    print("Response Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Email updated successfully'};
    } else if (response.statusCode == 400) {
      return {'success': false, 'message': 'Invalid Email'};
    } else if (response.statusCode == 401) {
      return {
        'success': false,
        'message': 'Unauthorized, user must be logged in',
      };
    } else {
      return {'success': false, 'message': 'Internal server error'};
    }
  }
}

final editEmailRepositoryProvider = Provider((ref) => EditEmailRepository());
