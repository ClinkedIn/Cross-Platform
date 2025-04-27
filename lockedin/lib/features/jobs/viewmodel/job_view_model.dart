import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:lockedin/features/jobs/repository/job_repository.dart';
import 'package:lockedin/features/jobs/services/job_secure_storage.dart';

final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

class JobViewModel extends ChangeNotifier {
  static final provider = ChangeNotifierProvider<JobViewModel>((ref) {
    final repository = ref.watch(jobRepositoryProvider);
    return JobViewModel(repository);
  });

  final JobRepository _repository;

  JobViewModel(this._repository) {
    _loadSavedJobs();
    fetchJobs();
  }

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  String _searchQuery = '';
  String? _selectedLocation;
  String? _selectedIndustry;
  String? _selectedCompanyId;
  int _minExperience = 0;
  final Set<String> _savedJobIds = {};

  String? get selectedLocation => _selectedLocation;
  String? get selectedIndustry => _selectedIndustry;
  String? get selectedCompanyId => _selectedCompanyId;
  int get minExperience => _minExperience;
  List<String> get savedJobs => _savedJobIds.toList();

  JobModel? _selectedJob;
  JobModel? get selectedJob => _selectedJob;

  String? _companyName;
  String? get companyName => _companyName;

  Future<void> fetchJobs() async {
    try {
      _jobs = await _repository.fetchJobs(
        q: _searchQuery,
        location: _selectedLocation ?? '',
        industry: _selectedIndustry ?? '',
        companyId: _selectedCompanyId,
        minExperience: _minExperience,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching jobs: $e');
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    fetchJobs();
  }

  void updateFilters({
    String? location,
    String? industry,
    String? companyId,
    int? minExperience,
  }) {
    _selectedLocation = location;
    _selectedIndustry = industry;
    _selectedCompanyId = companyId;
    _minExperience = minExperience ?? 0;
    fetchJobs();
  }

  void saveJob(String jobId) async {
    try {
      _savedJobIds.add(jobId);
      await _repository.saveJob(jobId);
      await saveJobId(jobId); // <-- secure storage
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving job: $e');
    }
  }

  void unsaveJob(String jobId) async {
    try {
      _savedJobIds.remove(jobId);
      await _repository.unsaveJob(jobId);
      await unsaveJobId(jobId); // <-- secure storage
      notifyListeners();
    } catch (e) {
      debugPrint('Error unsaving job: $e');
    }
  }

  Future<void> _loadSavedJobs() async {
    final ids = await getSavedJobIds();
    _savedJobIds.addAll(ids);
    notifyListeners();
  }

  bool isJobSaved(String jobId) {
    return _savedJobIds.contains(jobId);
  }

  bool isAlreadyApplied(String userId) {
    if (_selectedJob == null)
      return false; // If no job is selected, return false

    final job = _selectedJob!;
    final isApplied =
        job.applicants.contains(userId) ||
        job.accepted.contains(userId) ||
        job.rejected.contains(userId);

    if (isApplied) {
      debugPrint("User $userId has already applied or been accepted/rejected.");
    }

    return isApplied;
  }

  Future<void> applyToJob({
    required String jobId,
    required String contactEmail,
    required String contactPhone,
    required List<Map<String, String>> answers,
  }) async {
    try {
      final response = await _repository.applyForJob(
        jobId: jobId,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        answers: answers,
      );

      debugPrint('API Response: $response');

      // Update application status based on the response
      if (response['alreadyApplied'] == true) {
        _selectedJob?.applicationStatus =
            response['applicationStatus'] ?? 'Pending';
      } else {
        _selectedJob?.applicationStatus = 'Pending';
      }

      // Store the application status in Secure Storage
      await storeApplicationStatus(
        jobId,
        true,
      ); // Storing the status as "applied"

      // Refresh job details
      await fetchJobById(jobId);

      // Notify listeners to update the UI
      notifyListeners();

      debugPrint('Application submitted successfully');
    } catch (e) {
      debugPrint('Error applying to job: $e');
      rethrow;
    }
  }

  Future<void> fetchJobById(String jobId) async {
    try {
      _selectedJob = await _repository.getJobById(jobId);
      if (_selectedJob != null) {
        // Fetch company name after fetching the job
        await _fetchCompanyNameById(_selectedJob!.companyId);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching job by ID: $e');
    }
  }

  Future<void> _fetchCompanyNameById(String companyId) async {
    try {
      final companyData = await _repository.getCompanyById(companyId);
      _companyName = companyData['name'];
      debugPrint('Fetched company name: $_companyName');
    } catch (e) {
      debugPrint('Error fetching company name: $e');
    }
  }
}
