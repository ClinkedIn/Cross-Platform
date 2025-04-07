import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:lockedin/features/jobs/repository/job_repository.dart';

/// Define the job repository provider here
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

/// Job ViewModel
class JobViewModel extends ChangeNotifier {
  String? get selectedLocation => _selectedLocation;
  String? get selectedIndustry => _selectedIndustry;
  String? get selectedCompanyId => _selectedCompanyId;
  int get minExperience => _minExperience;

  /// Riverpod provider for JobViewModel
  static final provider = ChangeNotifierProvider<JobViewModel>((ref) {
    final repository = ref.watch(jobRepositoryProvider);
    return JobViewModel(repository);
  });

  final JobRepository _repository;

  JobViewModel(this._repository) {
    fetchJobs();
  }

  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  String _searchQuery = '';
  String? _selectedLocation;
  String? _selectedIndustry;
  String? _selectedCompanyId;
  int _minExperience = 0;

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
}
