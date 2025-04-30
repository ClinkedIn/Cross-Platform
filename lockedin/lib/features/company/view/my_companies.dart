import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/view/company_profile.dart';
import 'package:lockedin/features/company/view/create_company_view.dart';
import 'package:lockedin/shared/theme/colors.dart';

class MyCompaniesView extends ConsumerStatefulWidget {
  const MyCompaniesView({Key? key}) : super(key: key);

  @override
  ConsumerState<MyCompaniesView> createState() => _MyCompaniesViewState();
}

class _MyCompaniesViewState extends ConsumerState<MyCompaniesView> {
  @override
  void initState() {
    super.initState();
    // Fetch companies on widget load
    Future.microtask(() => ref.read(companyViewModelProvider).fetchCompanies());
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(companyViewModelProvider);
    final companies = viewModel.fetchedCompanies;
    final isLoading = viewModel.isLoading;
    final errorMessage = viewModel.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Companies'),
        backgroundColor: AppColors.primary,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : companies.isEmpty
              ? const Center(child: Text('No companies found.'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  final company = companies[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        company.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        company.industry,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    CompanyProfileView(companyId: company.id!),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
