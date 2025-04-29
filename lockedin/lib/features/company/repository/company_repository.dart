import 'dart:convert';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class CompanyRepository {
  static const String _companiesEndpoint = '/api/companies';

  Future<Company?> getCompanyById(String companyId) async {
    final uri = Uri.parse('http://10.0.2.2:3000$_companiesEndpoint/$companyId');

    print('Fetching company from: $uri');

    try {
      final token = await TokenService.getCookie();

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Cookie': 'access_token=$token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched company data: ${jsonEncode(data)}');
        return Company.fromJson(
          data['company'],
        ); // because your API wraps it inside 'company'
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
      final token = await TokenService.getCookie();

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

      // Handling logo file
      if (logoPath != null) {
        var logoFile = await http.MultipartFile.fromPath(
          'file',
          logoPath,
          contentType: MediaType.parse(
            lookupMimeType(logoPath) ?? 'application/octet-stream',
          ),
        );
        request.files.add(logoFile);
      }

      // Set the token as cookie
      request.headers.addAll({'Cookie': 'access_token=$token'});

      // Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Status code: ${response.statusCode}');
      print('Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        return Company.fromJson(data['company']);
      } else {
        print('Failed to create company: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating company: $e');
      return null;
    }
  }

  Future<bool> editCompany({
    required String companyId,
    required String name,
    required String address,
    String? website,
    required String industry,
    required String organizationSize,
    required String organizationType,
    String? tagLine,
    String? location,
    String? logoPath,
  }) async {
    final uri = Uri.parse('http://10.0.2.2:3000/api/companies/$companyId');

    try {
      final token = await TokenService.getCookie();
      var request =
          http.MultipartRequest('PATCH', uri)
            ..fields['name'] = name
            ..fields['address'] = address
            ..fields['industry'] = industry
            ..fields['organizationSize'] = organizationSize
            ..fields['organizationType'] = organizationType;

      if (website != null) request.fields['website'] = website;
      if (tagLine != null) request.fields['tagLine'] = tagLine;
      if (location != null) request.fields['location'] = location;

      if (logoPath != null) {
        var logoFile = await http.MultipartFile.fromPath(
          'file',
          logoPath,
          contentType: MediaType.parse(
            lookupMimeType(logoPath) ?? 'application/octet-stream',
          ),
        );
        request.files.add(logoFile);
      }

      request.headers.addAll({
        'Cookie': 'access_token=$token',
        'Accept': 'application/json',
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Edit company response: $responseBody');

      return response.statusCode == 200;
    } catch (e) {
      print('Error editing company: $e');
      return false;
    }
  }
}
