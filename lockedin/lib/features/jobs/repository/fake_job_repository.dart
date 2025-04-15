import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:lockedin/features/jobs/repository/job_repository.dart';

class FakeJobRepository implements JobRepository {
  List<JobModel> jobs = [];
  final List<String> savedJobIds = [];
  bool shouldThrow = false;

  @override
  Future<List<JobModel>> fetchJobs({
    String? companyId,
    String industry = '',
    int limit = 10,
    String location = '',
    int minExperience = 0,
    int page = 1,
    String q = '',
  }) async {
    if (shouldThrow) throw Exception('Failed to fetch');
    return jobs;
  }

  @override
  Future<void> saveJob(String jobId) async {
    if (shouldThrow) throw Exception('Failed to save');
    savedJobIds.add(jobId);
  }

  @override
  Future<void> unsaveJob(String jobId) async {
    if (shouldThrow) throw Exception('Failed to unsave');
    savedJobIds.remove(jobId);
  }

  @override
  Future<void> applyForJob({
    required String jobId,
    required String contactEmail,
    required String contactPhone,
    required List<Map<String, String>> answers,
  }) async {
    if (shouldThrow) throw Exception('Failed to apply');
  }

  @override
  Future<JobModel> getJobById(String jobId) async {
    if (shouldThrow) throw Exception('Failed to fetch job by ID');
    return jobs.firstWhere((job) => job.id == jobId);
  }
}
