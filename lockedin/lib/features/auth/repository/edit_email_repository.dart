import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/core/services/request_services.dart';

class EditEmailRepository {
  Future<Map<String, dynamic>> updateEmail(
    String newEmail,
    String password,
  ) async {
    final response = await RequestService.patch(
      '/user/update-email',
      body: {'newEmail': newEmail, 'password': password},
    );
    print("Response status code: ${response.statusCode}");
    print("Response body: ${response.body}");
    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Email updated successfully'};
    } else {
      final responseBody = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseBody["message"] ?? 'An error occurred',
      };
    }
  }
}

final editEmailRepositoryProvider = Provider((ref) => EditEmailRepository());
