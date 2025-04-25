import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as RequestService;
import 'package:lockedin/features/company/model/company_model.dart';

class CompanyRepository {
  Future<CompanyModel?> getCompanyById(String companyId) async {
    final uri = Uri.http('localhost:3000', '/companies/$companyId');

    // Debugging: Print the URI to ensure correct endpoint
    print('Fetching company from: $uri');

    try {
      final response = await RequestService.get(uri);

      // Debugging: Check the response status code and body
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched company data: ${jsonEncode(data)}');
        return CompanyModel.fromJson(data);
      } else {
        print('Failed to fetch company: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching company: $e');
      return null;
    }
  }
}
