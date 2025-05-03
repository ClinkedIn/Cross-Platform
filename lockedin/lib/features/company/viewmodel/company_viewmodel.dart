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

class CompanyViewModel extends ChangeNotifier {
  final CompanyRepository _companyRepository;

  CompanyViewModel({CompanyRepository? companyRepository})
    : _companyRepository = companyRepository ?? CompanyRepository();

  bool _isLoading = false;
  String? _errorMessage;
  Company? _createdCompany;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Company? get createdCompany => _createdCompany;

  // Jobs state
  List<CompanyJob> _companyJobs = [];
  List<CompanyJob> get companyJobs => _companyJobs;

  List<JobApplication> _jobApplications = [];
  List<JobApplication> get jobApplications => _jobApplications;

  CompanyJob? _fetchedJob;
  CompanyJob? get fetchedJob => _fetchedJob;

  Future<void> createCompany(Company company, {String? logoPath}) async {
    _setLoading(true);
    _clearError();

    final createdResult = await _companyRepository.createCompany(
      company,
      logoPath: logoPath,
    );

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
        _errorMessage = 'Company created, but failed to retrieve full data.';
      }
    } else {
      _errorMessage = 'Failed to create company.';
    }

    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearCreatedCompany() {
    _createdCompany = null;
    notifyListeners();
  }

  Company? _fetchedCompany;
  Company? get fetchedCompany => _fetchedCompany;

  Future<void> fetchCompanyById(String companyId) async {
    _setLoading(true);
    _clearError();

    final result = await _companyRepository.getCompanyById(companyId);
    if (result != null) {
      final localIsFollowing = await loadIsFollowing(companyId);
      _fetchedCompany =
          localIsFollowing != null
              ? result.copyWith(isFollowing: localIsFollowing)
              : result;
      notifyListeners();
    } else {
      _errorMessage = 'Failed to fetch company details.';
    }

    _setLoading(false);
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
    _setLoading(true);
    _clearError();

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

    _setLoading(false);
    return success;
  }

  Future<bool> createPost({
    required String companyId,
    required String description,
    List<Map<String, dynamic>>? taggedUsers,
    String? whoCanSee,
    String? whoCanComment,
    List<String>? filePaths,
  }) async {
    _setLoading(true);
    _clearError();

    final success = await _companyRepository.createCompanyPost(
      companyId: companyId,
      description: description,
      taggedUsers: taggedUsers,
      whoCanSee: whoCanSee,
      whoCanComment: whoCanComment,
      filePaths: filePaths,
    );

    if (!success) {
      _errorMessage = 'Failed to create post.';
      _setLoading(false);
      return false;
    }

    // Fetch the latest posts after successful creation
    await fetchCompanyPosts(companyId);

    _setLoading(false);
    return true;
  }

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
    _setLoading(true);
    _clearError();

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

    if (!success) {
      _errorMessage = 'Failed to create post.';
      _setLoading(false);
      return false;
    }

    // Fetch the latest posts after successful creation
    await fetchCompanyPosts(companyId);

    _setLoading(false);
    return true;
  }

  List<CompanyPost> _companyPosts = [];
  List<CompanyPost> get companyPosts => _companyPosts;

  Future<void> fetchCompanyPosts(
    String companyId, {
    int page = 1,
    int limit = 10,
  }) async {
    _setLoading(true);
    _clearError();

    final posts = await _companyRepository.fetchCompanyPosts(
      companyId,
      page: page,
      limit: limit,
    );
    _companyPosts = posts;

    _setLoading(false);
  }

  Future<void> fetchCompanyJobs(
    String companyId, {
    int page = 1,
    int limit = 10,
  }) async {
    _setLoading(true);
    _clearError();

    final jobs = await _companyRepository.fetchCompanyJobs(companyId);
    _companyJobs = jobs;

    _setLoading(false);
  }

  Future<void> fetchJobApplications(String jobId) async {
    _setLoading(true);
    _clearError();

    final applications = await _companyRepository.fetchJobApplications(jobId);
    _jobApplications = applications;

    _setLoading(false);
  }

  Future<void> getSpecificJob(String jobId) async {
    _setLoading(true);
    _clearError();

    final job = await _companyRepository.getSpecificJob(jobId);
    _fetchedJob = job;

    _setLoading(false);
  }

  List<Company> _fetchedCompanies = [];
  List<Company> get fetchedCompanies => _fetchedCompanies;

  Future<void> fetchCompanies({
    int page = 1,
    int limit = 10,
    String? sort,
    String? fields,
    String? industry,
  }) async {
    _setLoading(true);
    _clearError();

    final companies = await _companyRepository.fetchCompanies(
      page: page,
      limit: limit,
      sort: sort,
      fields: fields,
      industry: industry,
    );

    _fetchedCompanies = companies;

    _setLoading(false);
  }

  Future<void> toggleFollowCompany(String companyId) async {
    _setLoading(true);
    try {
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
        notifyListeners();
      } else if (response.statusCode == 400 &&
          body['message']?.toLowerCase().contains('already following') ==
              true) {
        // Already following, assume true
        _fetchedCompany = _fetchedCompany?.copyWith(isFollowing: true);
        await saveIsFollowing(companyId, true);
        notifyListeners();
      } else {
        debugPrint("❌ Failed to toggle follow. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error toggling follow: $e");
    }

    _setLoading(false);
  }

  // Save isFollowing state
  Future<void> saveIsFollowing(String companyId, bool isFollowing) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFollowing_$companyId', isFollowing);
  }

  // Load isFollowing state
  Future<bool?> loadIsFollowing(String companyId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isFollowing_$companyId');
  }

  Future<void> acceptJobApplication({
    required String jobId,
    required String userId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _companyRepository.acceptJobApplication(
        jobId: jobId,
        userId: userId,
      );
    } catch (e) {
      debugPrint('Error accepting application: $e');
      _errorMessage = 'Failed to accept application';
    }

    _setLoading(false);
  }

  Future<void> rejectJobApplication({
    required String jobId,
    required String userId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _companyRepository.rejectJobApplication(
        jobId: jobId,
        userId: userId,
      );
    } catch (e) {
      debugPrint('Error rejecting application: $e');
      _errorMessage = 'Failed to reject application';
    }

    _setLoading(false);
  }

  void removeApplicationFromList(String applicationId) {
    _jobApplications.removeWhere((app) => app.applicationId == applicationId);
    notifyListeners();
  }
}

// CompanyViewModel provider for accessing this class in UI
final companyViewModelProvider = ChangeNotifierProvider<CompanyViewModel>((
  ref,
) {
  return CompanyViewModel();
});
