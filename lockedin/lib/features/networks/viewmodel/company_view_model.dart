import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/company_list_model.dart';
import '../repository/network_repository.dart';

class CompanyViewModel extends ChangeNotifier {
  final CompanyService _companyService;

  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  List<CompanyResponse> _companies = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  List<CompanyResponse> get companies => _companies;

  CompanyViewModel({CompanyService? companyService})
    : _companyService = companyService ?? CompanyService();

  // Fetch companies from the API
  Future<void> fetchCompanies() async {
    _setLoading(true);
    _clearError();

    try {
      final companyList = await _companyService.getCompanies();
      _companies = companyList.companies;
      _setLoading(false);
    } catch (e) {
      print('Error details: $e');
      _setError('Failed to load companies: $e');
    }
  }

  // Follow a company
  Future<void> followCompany(String companyId) async {
    try {
      final success = await _companyService.followCompany(companyId);
      if (success) {
        // Update the local state on successful follow
        _updateCompanyRelationship(companyId, "follower");
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to follow company: $e');
    }
  }

  Future<void> unfollowCompany(String companyId) async {
    try {
      final success = await _companyService.unfollowCompany(companyId);
      if (success) {
        // Update the local state on successful follow
        _updateCompanyRelationship(companyId, "visitor");
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to follow company: $e');
    }
  }

  // Helper method to update company relationship in local state
  void _updateCompanyRelationship(String companyId, String newRelationship) {
    final index = _companies.indexWhere((item) => item.company.id == companyId);
    if (index != -1) {
      final company = _companies[index].company;
      _companies[index] = CompanyResponse(
        company: company,
        userRelationship: newRelationship,
      );
    }
  }

  // Helper methods for state management
  void _setLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
}
