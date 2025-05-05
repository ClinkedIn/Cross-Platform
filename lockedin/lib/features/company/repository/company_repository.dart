import 'dart:convert';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/company/model/company_job_model.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:lockedin/features/company/model/company_post_model.dart';
import 'package:lockedin/features/company/model/job_application_model.dart';
import 'package:mime/mime.dart';

class CompanyRepository {
  static const String _companiesEndpoint = '/companies';

  Future<Company?> getCompanyById(String companyId) async {
    final uri = Uri.parse(
      'https://lockedin-cufe.me/api$_companiesEndpoint/$companyId',
    );

    print('Fetching company from: $uri');

    try {
      final response = await RequestService.get(
        "$_companiesEndpoint/$companyId",
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched company data: ${jsonEncode(data)}');
        return Company.fromJson(data['company']);
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
    final uri = Uri.parse('https://lockedin-cufe.me/api$_companiesEndpoint');

    print('Creating company at: $uri');

    try {
      final response = await RequestService.post(
        _companiesEndpoint,
        body: {
          'name': company.name,
          'address': company.address,
          'industry': company.industry,
          'organizationSize': company.organizationSize,
          'organizationType': company.organizationType,
          if (company.website != null) 'website': company.website!,
          if (company.tagLine != null) 'tagLine': company.tagLine!,
          if (company.location != null) 'location': company.location!,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
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
    final uri = Uri.parse('https://lockedin-cufe.me/api/companies/$companyId');

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

  Future<bool> createCompanyPost({
    required String companyId,
    required String description,
    List<Map<String, dynamic>>? taggedUsers,
    String? whoCanSee,
    String? whoCanComment,
    List<String>? filePaths,
  }) async {
    final uri = Uri.parse(
      'https://lockedin-cufe.me/api/companies/$companyId/post',
    );
    final token = await TokenService.getCookie();

    final cleanedDescription = description.trim();
    if (cleanedDescription.isEmpty) {
      print(' Description is empty after trimming. Aborting request.');
      return false;
    }

    print('➡️ Sending post with fields:');
    print('   - description: $cleanedDescription');
    print('   - whoCanSee: ${whoCanSee ?? 'anyone'}');
    print('   - whoCanComment: ${whoCanComment ?? 'anyone'}');

    var request =
        http.MultipartRequest('POST', uri)
          ..fields['description'] = cleanedDescription
          ..fields['whoCanSee'] = whoCanSee ?? 'anyone'
          ..fields['whoCanComment'] = whoCanComment ?? 'anyone';

    if (taggedUsers != null && taggedUsers.isNotEmpty) {
      final taggedJson = jsonEncode(taggedUsers);
      print('   - taggedUsers: $taggedJson');
      request.fields['taggedUsers'] = taggedJson;
    }

    if (filePaths != null && filePaths.isNotEmpty) {
      for (var path in filePaths) {
        print('   - Attaching file: $path');
        var file = await http.MultipartFile.fromPath(
          'files',
          path,
          contentType: MediaType.parse(
            lookupMimeType(path) ?? 'application/octet-stream',
          ),
        );
        request.files.add(file);
      }
    }

    request.headers.addAll({
      'Cookie': 'access_token=$token',
      'Accept': 'application/json',
    });

    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    print("Status: ${streamedResponse.statusCode}");
    print("Response: $responseBody");

    // Check if the post was created successfully
    if (streamedResponse.statusCode == 200 ||
        streamedResponse.statusCode == 201) {
      // Trigger a refresh of the posts list
      await fetchCompanyPosts(
        companyId,
      ); // Ensure the posts are reloaded after creation
      return true;
    } else {
      return false;
    }
  }

  Future<bool> createCompanyJob({
    required String companyId,
    required String title,
    required String industry,
    required String workplaceType,
    required String jobLocation,
    required String jobType,
    required String description,
    required String applicationEmail,
    required List<Map<String, dynamic>> screeningQuestions,
    required bool autoRejectMustHave,
    required String rejectPreview,
  }) async {
    final response = await RequestService.post(
      'jobs',
      body: {
        'companyId': companyId,
        'title': title,
        'industry': industry,
        'workplaceType': workplaceType,
        'jobLocation': jobLocation,
        'jobType': jobType,
        'description': description,
        'applicationEmail': applicationEmail,
        'screeningQuestions': screeningQuestions,
        'autoRejectMustHave': autoRejectMustHave,
        'rejectPreview': rejectPreview,
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('create job : ${response.body}');
      return true;
    } else {
      print('Failed to create job: ${response.body}');
      return false;
    }
  }

  Future<List<CompanyPost>> fetchCompanyPosts(
    String companyId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await RequestService.get(
        '/companies/$companyId/post?page=$page&limit=$limit',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final postsJson = data['posts'] as List;
        return postsJson.map((post) => CompanyPost.fromJson(post)).toList();
      } else {
        print('Failed to fetch posts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  Future<List<CompanyJob>> fetchCompanyJobs(String companyId) async {
    final response = await RequestService.get('/jobs/company/$companyId');
    print('Jobbb Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final jobsJson = data as List;
      return jobsJson.map((job) => CompanyJob.fromJson(job)).toList();
    } else {
      print('Failed to fetch jobs: ${response.statusCode}');
      return [];
    }
  }

  Future<List<JobApplication>> fetchJobApplications(String jobId) async {
    final response = await RequestService.get('/jobs/$jobId/apply');
    print('applicationsss Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('applicationsss Response body: ${response.body}');
      final data = json.decode(response.body);
      final jobsJson = data['applications'] as List;
      return jobsJson
          .map((application) => JobApplication.fromJson(application))
          .toList();
    } else {
      print('Failed to fetch jobs: ${response.statusCode}');
      return [];
    }
  }

  Future<bool> acceptJobApplication({
    required String jobId,
    required String userId,
  }) async {
    final response = await RequestService.put(
      '/jobs/$jobId/applications/$userId/accept',
      body: {},
    );

    print('✅ Accept Application Status: ${response.statusCode}');
    print('✅ Accept Application Response: ${response.body}');

    return response.statusCode == 200;
  }

  Future<bool> rejectJobApplication({
    required String jobId,
    required String userId,
  }) async {
    final response = await RequestService.put(
      '/jobs/$jobId/applications/$userId/reject',
      body: {},
    );

    print('❌ Reject Application Status: ${response.statusCode}');
    print('❌ Reject Application Response: ${response.body}');

    return response.statusCode == 200;
  }

  Future<CompanyJob> getSpecificJob(String jobId) async {
    final response = await RequestService.get('/jobs/$jobId');
    print('Job application Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return CompanyJob.fromJson(data); // this is correct
    } else {
      print('Failed to fetch jobs: ${response.statusCode}');
      return CompanyJob(
        companyId: '0',
        workplaceType: 'Error',
        jobLocation: 'Error',
        jobType: 'Error',
        description: 'Error',
        applicationEmail: 'Error',
        screeningQuestions: [],
        autoRejectMustHave: false,
        rejectPreview: 'Error',
        id: 'Error',
        applicants: [],
        accepted: [],
        rejected: [],
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }
  }

  Future<List<Company>> fetchCompanies({
    int page = 1,
    int limit = 10,
    String? sort,
    String? fields,
    String? industry,
  }) async {
    try {
      final response = await RequestService.get("/user/companies");
      print('Response status: ${response.statusCode}');
      print('Respondhefdie3fse body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Fetched euhidefde data: ${(data['companies'])}');
        return (data['companies'] as List)
            .map((item) => Company.fromJson(item))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
