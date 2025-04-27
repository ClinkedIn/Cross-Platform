import 'dart:convert';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CompanyRepository {
  static const String _companiesEndpoint = '/api/companies';

  Future<Company?> getCompanyById(String companyId) async {
    final uri = Uri.parse('$_companiesEndpoint/$companyId');

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

  Future<Company?> createCompany(Company company, {String? logoPath}) async {
    final uri = Uri.parse('http://10.0.2.2:3000$_companiesEndpoint');

    print('Creating company at: $uri');

    try {
      var request =
          http.MultipartRequest('POST', uri)
            ..fields['name'] = company.name
            ..fields['address'] = company.address
            ..fields['industry'] = company.industry
            ..fields['organizationSize'] = company.organizationSize
            ..fields['organizationType'] = company.organizationType;

      // Optional fields
      if (company.website != null) {
        request.fields['website'] = company.website!;
      }
      if (company.tagLine != null) {
        request.fields['tagLine'] = company.tagLine!;
      }
      if (company.location != null) {
        request.fields['location'] = company.location!;
      }

      // Handling the logo as a file upload
      if (logoPath != null) {
        var logoFile = await http.MultipartFile.fromPath(
          'file',
          logoPath, // File path
          contentType: MediaType.parse(
            lookupMimeType(logoPath) ?? 'application/octet-stream',
          ),
        );
        request.files.add(logoFile);
      }

      // Send the request
      var response = await request.send();

      // Wait for the response
      var responseBody = await response.stream.bytesToString();

      print('Status code: ${response.statusCode}');
      print('Body: $responseBody');

      // Check for success
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        print('Created company data: ${jsonEncode(data)}');
        return Company.fromJson(
          data['company'], // Access the "company" field from the response
        );
      } else {
        print('Failed to create company: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating company: $e');
      return null;
    }
  }
}
