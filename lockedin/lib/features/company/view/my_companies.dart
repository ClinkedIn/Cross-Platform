import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/view/create_company_view.dart';
import 'package:lockedin/features/company/view/company_profile.dart';

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
      appBar: AppBar(title: const Text('My Companies')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(child: Text(errorMessage))
              : companies.isEmpty
              ? const Center(child: Text('No companies found.'))
              : ListView.builder(
                itemCount: companies.length,
                itemBuilder: (context, index) {
                  final company = companies[index];
                  return ListTile(
                    title: Text(company.name),
                    subtitle: Text(company.industry),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CompanyProfileView(companyId: company.id!),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
