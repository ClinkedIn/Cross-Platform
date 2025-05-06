import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/features/company/model/company_job_model.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:lockedin/features/company/model/company_post_model.dart';
import 'package:lockedin/features/company/model/job_application_model.dart';
import 'package:lockedin/features/company/repository/company_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key for storing following status in SharedPreferences
const String _followingKeyPrefix = 'isFollowing_';

/// ViewModel responsible for managing company-related state and operations
class CompanyViewModel extends ChangeNotifier {
  final CompanyRepository _companyRepository;

  // Main state
  bool _isLoading = false;
  String? _errorMessage;

  // Company state
  Company? _createdCompany;
  Company? _fetchedCompany;
  List<Company> _fetchedCompanies = [];

  // Posts state
  List<CompanyPost> _companyPosts = [];

  // Jobs state
  List<CompanyJob> _companyJobs = [];
  CompanyJob? _fetchedJob;
  List<JobApplication> _jobApplications = [];

  CompanyViewModel({CompanyRepository? companyRepository})
    : _companyRepository = companyRepository ?? CompanyRepository();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Company? get createdCompany => _createdCompany;
  Company? get fetchedCompany => _fetchedCompany;
  List<Company> get fetchedCompanies => _fetchedCompanies;
  List<CompanyPost> get companyPosts => _companyPosts;
  List<CompanyJob> get companyJobs => _companyJobs;
  CompanyJob? get fetchedJob => _fetchedJob;
  List<JobApplication> get jobApplications => _jobApplications;

  /// Helper method to handle async operations with loading state and error handling
  Future<T?> _executeAsync<T>(
    Future<T?> Function() operation, {
    String? errorMessage,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await operation();
      return result;
    } catch (e) {
      _errorMessage = errorMessage ?? 'An error occurred: ${e.toString()}';
      debugPrint('❌ Error in CompanyViewModel: $_errorMessage');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates loading state and notifies listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clears error message and notifies listeners
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears created company state
  void clearCreatedCompany() {
    _createdCompany = null;
    notifyListeners();
  }

  /// Creates a new company with optional logo
  Future<bool> createCompany(Company company, {String? logoPath}) async {
    return await _executeAsync<bool>(() async {
          final createdResult = await _companyRepository.createCompany(
            company,
            logoPath: logoPath,
          );
          print('Created company: ${createdResult?.id}');

          if (createdResult != null &&
              createdResult.id != null &&
              createdResult.id!.isNotEmpty) {
            final fetchedResult = await _companyRepository.getCompanyById(
              createdResult.id!,
            );

            if (fetchedResult != null) {
              _createdCompany = fetchedResult;
            } else {
              _createdCompany = createdResult;
              _errorMessage =
                  'Company created, but failed to retrieve full data.';
            }
            return true;
          } else {
            _errorMessage = 'Failed to create company.';
            return false;
          }
        }, errorMessage: 'Failed to create company') ??
        false;
  }

  /// Fetches company details by ID
  Future<void> fetchCompanyById(String companyId) async {
    await _executeAsync<void>(() async {
      final result = await _companyRepository.getCompanyById(companyId);
      if (result != null) {
        final localIsFollowing = await loadIsFollowing(companyId);
        _fetchedCompany =
            localIsFollowing != null
                ? result.copyWith(isFollowing: localIsFollowing)
                : result;
      } else {
        _errorMessage = 'Failed to fetch company details.';
      }
    }, errorMessage: 'Failed to fetch company details');
  }

  /// Updates an existing company
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
    return await _executeAsync<bool>(() async {
          final success = await _companyRepository.editCompany(
            companyId: companyId,
            name: name,
            address: address,
            website: website,
            industry: industry,
            organizationSize: organizationSize,
            organizationType: organizationType,
            tagLine: tagLine,
            location: location,
            logoPath: logoPath,
          );

          if (success) {
            // Refresh the company details
            await fetchCompanyById(companyId);
          } else {
            _errorMessage = 'Failed to update company.';
          }
          return success;
        }, errorMessage: 'Failed to edit company') ??
        false;
  }

  /// Creates a company post
  Future<bool> createPost({
    required String companyId,
    required String description,
    List<Map<String, dynamic>>? taggedUsers,
    String? whoCanSee,
    String? whoCanComment,
    List<String>? filePaths,
  }) async {
    return await _executeAsync<bool>(() async {
          final success = await _companyRepository.createCompanyPost(
            companyId: companyId,
            description: description,
            taggedUsers: taggedUsers,
            whoCanSee: whoCanSee,
            whoCanComment: whoCanComment,
            filePaths: filePaths,
          );

          if (success) {
            // Fetch the latest posts after successful creation
            await fetchCompanyPosts(companyId);
            return true;
          } else {
            _errorMessage = 'Failed to create post.';
            return false;
          }
        }, errorMessage: 'Failed to create post') ??
        false;
  }

  /// Creates a company job
  Future<bool> createJob({
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
    return await _executeAsync<bool>(() async {
          final success = await _companyRepository.createCompanyJob(
            companyId: companyId,
            description: description,
            title: title,
            industry: industry,
            workplaceType: workplaceType,
            jobLocation: jobLocation,
            jobType: jobType,
            applicationEmail: applicationEmail,
            screeningQuestions: screeningQuestions,
            autoRejectMustHave: autoRejectMustHave,
            rejectPreview: rejectPreview,
          );

          if (success) {
            // Refresh jobs after successful creation
            await fetchCompanyJobs(companyId);
            return true;
          } else {
            _errorMessage = 'Failed to create job.';
            return false;
          }
        }, errorMessage: 'Failed to create job') ??
        false;
  }

  /// Fetches company posts
  Future<void> fetchCompanyPosts(
    String companyId, {
    int page = 1,
    int limit = 10,
  }) async {
    await _executeAsync<void>(() async {
      final posts = await _companyRepository.fetchCompanyPosts(
        companyId,
        page: page,
        limit: limit,
      );
      _companyPosts = posts;
    }, errorMessage: 'Failed to fetch company posts');
  }

  /// Fetches company jobs
  Future<void> fetchCompanyJobs(
    String companyId, {
    int page = 1,
    int limit = 10,
  }) async {
    await _executeAsync<void>(() async {
      final jobs = await _companyRepository.fetchCompanyJobs(companyId);
      _companyJobs = jobs;
    }, errorMessage: 'Failed to fetch company jobs');
  }

  /// Fetches all job applications for a specific job
  Future<void> fetchJobApplications(String jobId) async {
    await _executeAsync<void>(() async {
      final applications = await _companyRepository.fetchJobApplications(jobId);
      _jobApplications = applications;
    }, errorMessage: 'Failed to fetch job applications');
  }

  /// Fetches details for a specific job
  Future<void> getSpecificJob(String jobId) async {
    await _executeAsync<void>(() async {
      final job = await _companyRepository.getSpecificJob(jobId);
      _fetchedJob = job;
    }, errorMessage: 'Failed to fetch job details');
  }

  /// Fetches list of companies based on filters
  Future<void> fetchCompanies({
    int page = 1,
    int limit = 10,
    String? sort,
    String? fields,
    String? industry,
  }) async {
    await _executeAsync<void>(() async {
      final companies = await _companyRepository.fetchCompanies(
        page: page,
        limit: limit,
        sort: sort,
        fields: fields,
        industry: industry,
      );
      _fetchedCompanies = companies;
    }, errorMessage: 'Failed to fetch companies');
  }

  /// Toggles follow status for a company
  Future<void> toggleFollowCompany(String companyId) async {
    await _executeAsync<void>(() async {
      final isCurrentlyFollowing = _fetchedCompany?.isFollowing ?? false;
      final endpoint = '/companies/$companyId/follow';

      final response =
          isCurrentlyFollowing
              ? await RequestService.delete(endpoint)
              : await RequestService.post(
                endpoint,
                body: {'companyId': companyId},
              );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        // Toggle success
        _fetchedCompany = _fetchedCompany?.copyWith(
          isFollowing: !isCurrentlyFollowing,
        );
        await saveIsFollowing(companyId, !isCurrentlyFollowing);
      } else if (response.statusCode == 400 &&
          body['message']?.toLowerCase().contains('already following') ==
              true) {
        // Already following, assume true
        _fetchedCompany = _fetchedCompany?.copyWith(isFollowing: true);
        await saveIsFollowing(companyId, true);
      } else {
        throw Exception(
          'Failed to toggle follow. Status: ${response.statusCode}',
        );
      }
    }, errorMessage: 'Failed to update follow status');
  }

  /// Saves company following status to local storage
  Future<void> saveIsFollowing(String companyId, bool isFollowing) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_followingKeyPrefix$companyId', isFollowing);
    } catch (e) {
      debugPrint('❌ Error saving follow status: $e');
    }
  }

  /// Loads company following status from local storage
  Future<bool?> loadIsFollowing(String companyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_followingKeyPrefix$companyId');
    } catch (e) {
      debugPrint('❌ Error loading follow status: $e');
      return null;
    }
  }

  /// Accepts a job application
  Future<void> acceptJobApplication({
    required String jobId,
    required String userId,
  }) async {
    await _executeAsync<void>(() async {
      await _companyRepository.acceptJobApplication(
        jobId: jobId,
        userId: userId,
      );
      // Remove the application from the list once processed
      removeApplicationFromList(userId);
    }, errorMessage: 'Failed to accept application');
  }

  /// Rejects a job application
  Future<void> rejectJobApplication({
    required String jobId,
    required String userId,
  }) async {
    await _executeAsync<void>(() async {
      await _companyRepository.rejectJobApplication(
        jobId: jobId,
        userId: userId,
      );
      // Remove the application from the list once processed
      removeApplicationFromList(userId);
    }, errorMessage: 'Failed to reject application');
  }

  /// Removes an application from the applications list
  void removeApplicationFromList(String applicationId) {
    _jobApplications.removeWhere((app) => app.applicationId == applicationId);
    notifyListeners();
  }
}

/// Provider for accessing CompanyViewModel throughout the app
final companyViewModelProvider = ChangeNotifierProvider<CompanyViewModel>((
  ref,
) {
  return CompanyViewModel();
});
