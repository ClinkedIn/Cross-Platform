import 'package:flutter/foundation.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:lockedin/features/company/repository/company_repository.dart';

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

    // If logoPath is provided, we should handle it properly in the repository
    final result = await _companyRepository.createCompany(
      company,
      logoPath: logoPath,
    );

    if (result != null) {
      _createdCompany = result;
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
}
