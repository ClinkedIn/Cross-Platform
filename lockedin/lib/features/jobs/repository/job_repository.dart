import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lockedin/features/jobs/model/job_model.dart';

class JobRepository {
  final String baseUrl;

  JobRepository({this.baseUrl = 'http://localhost:3000/search'});

  Future<List<JobModel>> fetchJobs({
    String q = '',
    String location = '',
    String industry = '',
    String? companyId,
    int minExperience = 0,
    int page = 1,
    int limit = 10,
  }) async {
    final uri = Uri.parse('$baseUrl/jobs').replace(
      queryParameters: {
        'q': q,
        'location': location,
        'industry': industry,
        if (companyId != null) 'companyId': companyId,
        'minExperience': minExperience.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(
      uri,
      headers: {'accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List jobs = data['jobs'];
      return jobs.map((job) => JobModel.fromJson(job)).toList();
    } else {
      throw Exception('Failed to load jobs: ${response.statusCode}');
    }
  }
}
