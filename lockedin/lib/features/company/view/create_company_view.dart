import 'package:flutter/material.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:lockedin/features/company/viewmodel/company_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CompanyView extends ConsumerWidget {
  const CompanyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the company view model provider
    final companyViewModel = ref.watch(companyViewModelProvider);

    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _addressController = TextEditingController();
    final _websiteController = TextEditingController();
    final _industryController = TextEditingController();
    final _organizationSizeController = TextEditingController();
    final _organizationTypeController = TextEditingController();
    final _logoController = TextEditingController();
    final _tagLineController = TextEditingController();
    final _userIdController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Company')),
      body:
          companyViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        controller: _userIdController,
                        decoration: const InputDecoration(labelText: 'User ID'),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _websiteController,
                        decoration: const InputDecoration(labelText: 'Website'),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _industryController,
                        decoration: const InputDecoration(
                          labelText: 'Industry',
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _organizationSizeController,
                        decoration: const InputDecoration(
                          labelText: 'Organization Size',
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _organizationTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Organization Type',
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _logoController,
                        decoration: const InputDecoration(
                          labelText: 'Logo URL',
                        ),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      TextFormField(
                        controller: _tagLineController,
                        decoration: const InputDecoration(labelText: 'Tagline'),
                        validator:
                            (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final newCompany = Company(
                              userId: _userIdController.text.trim(),
                              name: _nameController.text.trim(),
                              address: _addressController.text.trim(),
                              website: _websiteController.text.trim(),
                              industry: _industryController.text.trim(),
                              organizationSize:
                                  _organizationSizeController.text.trim(),
                              organizationType:
                                  _organizationTypeController.text.trim(),
                              logo: _logoController.text.trim(),
                              tagLine: _tagLineController.text.trim(),
                            );

                            await companyViewModel.createCompany(newCompany);

                            if (companyViewModel.createdCompany != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Company created successfully!',
                                  ),
                                ),
                              );
                              _formKey.currentState?.reset();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    companyViewModel.errorMessage ??
                                        'Unknown error',
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
