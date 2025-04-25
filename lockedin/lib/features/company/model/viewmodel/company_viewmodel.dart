import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:lockedin/features/company/model/repository/company_repository.dart';

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepository();
});

class CompanyViewModel extends ChangeNotifier {
  static final provider = ChangeNotifierProvider<CompanyViewModel>((ref) {
    final repository = ref.watch(companyRepositoryProvider);
    return CompanyViewModel(repository);
  });

  final CompanyRepository _repository;

  CompanyViewModel(this._repository);

  CompanyModel? _selectedCompany;
  CompanyModel? get selectedCompany => _selectedCompany;

  Future<void> fetchCompanyById(String companyId) async {
    try {
      _selectedCompany = await _repository.getCompanyById(companyId);
      if (_selectedCompany != null) {
        debugPrint('Fetched company: ${_selectedCompany!.name}');
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching company by ID: $e');
    }
  }
}
