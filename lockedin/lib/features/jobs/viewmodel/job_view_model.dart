import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';

class JobViewModel extends ChangeNotifier {
  // Static provider declaration inside the view model
  static final provider = ChangeNotifierProvider<JobViewModel>((ref) {
    return JobViewModel();
  });

  // Holds the list of jobs
  List<JobModel> _jobs = [];
  List<JobModel> get jobs => _jobs;

  // Holds search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Holds filter criteria
  String? _selectedExperienceLevel;
  String? _selectedCompany;
  String? _selectedSalaryRange;

  String? get selectedExperienceLevel => _selectedExperienceLevel;
  String? get selectedCompany => _selectedCompany;
  String? get selectedSalaryRange => _selectedSalaryRange;

  // Constructor or init method to fetch initial data
  JobViewModel() {
    fetchJobs();
  }

  // Simulate fetching jobs (or integrate with your backend API)
  void fetchJobs() {
    _jobs = [
      JobModel(
        title: 'Senior iOS Engineer',
        company: 'Flex AI',
        location: 'Egypt (Remote)',
        isRemote: false,
        logoUrl: 'https://via.placeholder.com/50',
        experienceLevel: 'Senior',
        salaryRange: '\$80k - \$120k',
        description:
            'We are looking for a Senior iOS Engineer to build and maintain our iOS applications.',
      ),
      JobModel(
        title: 'Data Engineer',
        company: 'X Company',
        location: 'Cairo, Egypt (On-site)',
        isRemote: false,
        experienceLevel: 'Mid-Level',
        salaryRange: '\$60k - \$90k',
        description:
            'Join our data team to develop and optimize data pipelines for business intelligence.',
      ),
      JobModel(
        title: 'Field Data Collector (Freelance)',
        company: 'dubizzle Egypt',
        location: 'Cairo, Egypt (On-site)',
        isRemote: false,
        experienceLevel: 'Entry-Level',
        salaryRange: '\$10 - \$15 per hour',
        description:
            'Collect and validate market data for our research and analytics team.',
      ),
    ];
    notifyListeners();
  }

  // Method to update the search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Method to update filters
  void updateFilters({
    String? experienceLevel,
    String? company,
    String? salaryRange,
  }) {
    _selectedExperienceLevel = experienceLevel;
    _selectedCompany = company;
    _selectedSalaryRange = salaryRange;
    notifyListeners();
  }

  // Filtered list based on search query and filters
  List<JobModel> get filteredJobs {
    return _jobs.where((job) {
      final queryMatch =
          _searchQuery.isEmpty ||
          job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.location.toLowerCase().contains(_searchQuery.toLowerCase());

      final experienceMatch =
          _selectedExperienceLevel == null ||
          job.experienceLevel == _selectedExperienceLevel;
      final companyMatch =
          _selectedCompany == null || job.company == _selectedCompany;
      final salaryMatch =
          _selectedSalaryRange == null ||
          job.salaryRange == _selectedSalaryRange;

      return queryMatch && experienceMatch && companyMatch && salaryMatch;
    }).toList();
  }
}
