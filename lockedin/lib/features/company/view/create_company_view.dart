import 'package:flutter/material.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:lockedin/features/company/view/company_profile.dart';
import 'package:lockedin/features/company/viewmodel/company_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

final companyViewModelProvider = ChangeNotifierProvider<CompanyViewModel>((ref) {
  return CompanyViewModel();
});

class CompanyView extends ConsumerStatefulWidget {
  const CompanyView({Key? key}) : super(key: key);

  @override
  ConsumerState<CompanyView> createState() => _CompanyViewState();
}

class _CompanyViewState extends ConsumerState<CompanyView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _industryController = TextEditingController();
  final _organizationSizeController = TextEditingController();
  final _organizationTypeController = TextEditingController();
  final _tagLineController = TextEditingController();

  final List<String> organizationSizes = [
    '1-10',
    '11-50',
    '51-200',
    '201-500',
    '501-1000',
    '1001-5000',
    '5,000+',
  ];

  final List<String> organizationTypes = [
    'Public',
    'Private',
    'Nonprofit',
    'Government',
    'Educational',
    'Self-employed',
  ];

  String? selectedSize;
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    final companyViewModel = ref.watch(companyViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Company')),
      body: companyViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 1.25.h),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Address'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 1.25.h),
                    TextFormField(
                      controller: _industryController,
                      decoration: const InputDecoration(labelText: 'Industry'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    SizedBox(height: 1.25.h),
                    DropdownButtonFormField<String>(
                      value: selectedSize,
                      decoration: const InputDecoration(labelText: 'Organization Size'),
                      items: organizationSizes.map((size) {
                        return DropdownMenuItem<String>(
                          value: size,
                          child: Text(size),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSize = value!;
                          _organizationSizeController.text = value;
                        });
                      },
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                    SizedBox(height: 1.25.h),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Organization Type'),
                      items: organizationTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                          _organizationTypeController.text = value;
                        });
                      },
                      validator: (value) => value == null ? 'Required' : null,
                    ),
                    SizedBox(height: 1.25.h),
                    TextFormField(
                      controller: _tagLineController,
                      decoration: const InputDecoration(labelText: 'Tagline'),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final newCompany = Company(
                            name: _nameController.text.trim(),
                            address: _addressController.text.trim(),
                            industry: _industryController.text.trim(),
                            organizationSize: _organizationSizeController.text.trim(),
                            organizationType: _organizationTypeController.text.trim(),
                            tagLine: _tagLineController.text.trim(),
                          );

                          await companyViewModel.createCompany(newCompany);

                          if (companyViewModel.createdCompany != null &&
                              companyViewModel.createdCompany!.id != null) {
                            final companyId = companyViewModel.createdCompany!.id!;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Company created successfully!'),
                              ),
                            );

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CompanyProfileView(companyId: companyId),
                              ),
                            );

                            _formKey.currentState?.reset();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  companyViewModel.errorMessage ?? 'Unknown error',
                                ),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Create Company'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
