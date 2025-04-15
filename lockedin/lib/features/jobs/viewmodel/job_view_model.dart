import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:lockedin/features/jobs/repository/job_repository.dart';

/// Provides an instance of [JobRepository] to be used with Riverpod.
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

/// ViewModel that manages job listings, filters, search, and job actions.
class JobViewModel extends ChangeNotifier {
  /// Riverpod provider for [JobViewModel].
  static final provider = ChangeNotifierProvider<JobViewModel>((ref) {
    final repository = ref.watch(jobRepositoryProvider);
    return JobViewModel(repository);
  });

  final JobRepository _repository;

  /// Creates an instance of [JobViewModel] and fetches initial jobs.
  JobViewModel(this._repository) {
    fetchJobs();
  }

  List<JobModel> _jobs = [];

  /// List of jobs fetched from the repository.
  List<JobModel> get jobs => _jobs;

  String _searchQuery = '';
  String? _selectedLocation;
  String? _selectedIndustry;
  String? _selectedCompanyId;
  int _minExperience = 0;
  final Set<String> _savedJobIds = {};

  /// The selected location filter.
  String? get selectedLocation => _selectedLocation;

  /// The selected industry filter.
  String? get selectedIndustry => _selectedIndustry;

  /// The selected company ID filter.
  String? get selectedCompanyId => _selectedCompanyId;

  /// The selected minimum experience level filter.
  int get minExperience => _minExperience;

  /// List of saved job IDs.
  List<String> get savedJobs => _savedJobIds.toList();

  /// Fetches jobs from the repository based on current filters and query.
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

  /// Updates the search query and refetches jobs.
  void updateSearchQuery(String query) {
    _searchQuery = query;
    fetchJobs();
  }

  /// Updates filter values and refetches jobs.
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

  /// Saves a job by ID and updates the saved list.
  void saveJob(String jobId) async {
    try {
      _savedJobIds.add(jobId);
      debugPrint('Saved Job IDs: $_savedJobIds');
      await _repository.saveJob(jobId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving job: $e');
    }
  }

  /// Unsaves a job by ID and updates the saved list.
  void unsaveJob(String jobId) async {
    try {
      await _repository.unsaveJob(jobId);
      _savedJobIds.remove(jobId);
      debugPrint('Unsave successful: $jobId');
      notifyListeners();
    } catch (e) {
      debugPrint('Error unsaving job: $e');
    }
  }

  /// Checks if a job is saved.
  bool isJobSaved(String jobId) {
    return _savedJobIds.contains(jobId);
  }

  /// Applies to a job with provided contact details and answers.
  Future<void> applyToJob({
    required String jobId,
    required String contactEmail,
    required String contactPhone,
    required List<Map<String, String>> answers,
  }) async {
    try {
      await _repository.applyForJob(
        jobId: jobId,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        answers: answers,
      );
      debugPrint('Application submitted successfully');
    } catch (e) {
      debugPrint('Error applying to job: $e');
    }
  }

  JobModel? _selectedJob;

  JobModel? get selectedJob => _selectedJob;

  Future<void> fetchJobById(String jobId) async {
    try {
      _selectedJob = await _repository.getJobById(jobId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching job by ID: $e');
    }
  }
}
