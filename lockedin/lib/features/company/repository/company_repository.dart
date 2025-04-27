import 'dart:convert';

import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/company/model/company_model.dart';

class CompanyRepository {
  static const String _companiesEndpoint = '/api/companies';

  Future<Company?> getCompanyById(String companyId) async {
    final uri = Uri(path: '$_companiesEndpoint/$companyId');

    print('Fetching company from: $uri');

    try {
      final response = await RequestService.get(uri.toString());

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched company data: ${jsonEncode(data)}');
        return Company.fromJson(data);
      } else {
        print('Failed to fetch company: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching company: $e');
      return null;
    }
  }

  Future<Company?> createCompany(Company company) async {
    final uri = Uri.parse('http://10.0.2.2:3000$_companiesEndpoint');

    print('Creating company at: $uri');

    try {
      final response = await RequestService.post(
        '/companies',
        body: company.toJson(),
      );

      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');

      // Check if the response is JSON
      if (response.headers['content-type']?.contains('application/json') ??
          false) {
        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          print('Created company data: ${jsonEncode(data)}');
          return Company.fromJson(data);
        } else {
          print('Failed to create company: ${response.statusCode}');
          return null;
        }
      } else if (response.headers['content-type']?.contains('text/html') ??
          false) {
        print('Received HTML response instead of JSON');
        return null;
      } else {
        print('Unexpected response type: ${response.headers['content-type']}');
        return null;
      }
    } catch (e) {
      print('Error creating company: $e');
      return null;
    }
  }
}
