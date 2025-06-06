import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';

class JobRepository {
  static const String _searchJobsEndpoint = '/search/jobs';

  Future<List<JobModel>> fetchJobs({
    String q = '',
    String location = '',
    String industry = '',
    String? companyId,
    int minExperience = 0,
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = {
      if (q.length >= 2) 'q': q,
      if (location.length >= 2) 'location': location,
      if (industry.isNotEmpty) 'industry': industry,
      if (companyId != null) 'companyId': companyId,
      if (minExperience > 0) 'minExperience': minExperience.toString(),
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final uri = Uri(path: _searchJobsEndpoint, queryParameters: queryParams);

    final response = await RequestService.get(uri.toString());
    print('Fetching cfererref from: ${response.statusCode}');
    print('Fetching jobsdkeh from: ${response.body}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fjdnclnwdcetched job data: ${jsonEncode(data['jobs'])}');
      final List jobs = data['jobs'];
      return jobs.map((job) => JobModel.fromJson(job)).toList();
    } else {
      throw Exception('Failed to load jobs: ${response.statusCode}');
    }
  }

  Future<void> saveJob(String jobId) async {
    final response = await RequestService.post(
      '/jobs/$jobId/save',
      body: {}, // Empty body
    );

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to save job');
    }
  }

  Future<void> unsaveJob(String jobId) async {
    final response = await RequestService.delete('/jobs/$jobId/save');

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to unsave job');
    }
  }

  Future<Map<String, dynamic>> applyForJob({
    required String jobId,
    required String contactEmail,
    required String contactPhone,
    required List<Map<String, String>> answers,
  }) async {
    final uri = Uri(path: '/jobs/$jobId/apply');

    final response = await RequestService.post(
      uri.toString(),
      body: {
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'answers': answers,
      },
    );

    final data = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Failed to apply for job');
    }

    debugPrint('Application response: ${jsonEncode(data)}');

    return data; // Return the response data here
  }

  Future<JobModel> getJobById(String jobId) async {
    final response = await RequestService.get("jobs/$jobId");
    print('dhekdcedw job by ID from: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint('Fetched job by ID: ${jsonEncode(data)}');

      return JobModel.fromJson(data); // THIS IS CORRECT NOW
    } else {
      throw Exception('Failed to fetch job by ID: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getCompanyById(String companyId) async {
    final response = await RequestService.get('/companies/$companyId');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched company data: ${jsonEncode(data)}');
      return data;
    } else {
      throw Exception('Failed to fetch company: ${response.statusCode}');
    }
  }
}
