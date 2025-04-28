import 'package:flutter/foundation.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:lockedin/features/company/repository/company_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> createCompany(Company company, {String? logoPath}) async {
    _setLoading(true);
    _clearError();

    final createdResult = await _companyRepository.createCompany(
      company,
      logoPath: logoPath,
    );

    if (createdResult != null) {
      // Immediately fetch full company details after creation
      final fetchedResult = await _companyRepository.getCompanyById(
        createdResult.address,
      );

      if (fetchedResult != null) {
        _createdCompany = fetchedResult;
      } else {
        // If fetching fails, fallback to the createdResult
        _createdCompany = createdResult;
        _errorMessage = 'Company created, but failed to retrieve full data.';
      }
    } else {
      _errorMessage = 'Failed to create company.';
    }

    _setLoading(
      false,
    ); // Ensure this is called after the state has been updated
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
      _fetchedCompany = result;
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
}

// CompanyViewModel provider for accessing this class in UI
final companyViewModelProvider = ChangeNotifierProvider<CompanyViewModel>((
  ref,
) {
  return CompanyViewModel();
});
