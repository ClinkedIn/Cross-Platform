import 'package:flutter/material.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:lockedin/features/company/view/company_profile.dart';
import 'package:lockedin/features/company/viewmodel/company_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

final companyViewModelProvider = ChangeNotifierProvider<CompanyViewModel>((
  ref,
) {
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
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _industryController.dispose();
    _organizationSizeController.dispose();
    _organizationTypeController.dispose();
    _tagLineController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final companyViewModel = ref.read(companyViewModelProvider);

    final newCompany = Company(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      industry: _industryController.text.trim(),
      organizationSize: _organizationSizeController.text.trim(),
      organizationType: _organizationTypeController.text.trim(),
      tagLine: _tagLineController.text.trim(),
    );

    await companyViewModel.createCompany(newCompany);

    if (!mounted) return;

    if (companyViewModel.createdCompany != null &&
        companyViewModel.createdCompany!.id != null) {
      final companyId = companyViewModel.createdCompany!.id!;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company created successfully!'),
          backgroundColor: Colors.green,
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
          content: Text(companyViewModel.errorMessage ?? 'Unknown error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        validator: validator ?? (value) => value!.isEmpty ? 'Required' : null,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        items:
            items.map((item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyViewModel = ref.watch(companyViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Company'),
        centerTitle: true,
        elevation: 0,
      ),
      body:
          companyViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.h),
                        child: Text(
                          'Company Information',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildInputField(
                        controller: _nameController,
                        label: 'Company Name',
                      ),
                      _buildInputField(
                        controller: _addressController,
                        label: 'Address',
                      ),
                      _buildInputField(
                        controller: _industryController,
                        label: 'Industry',
                      ),
                      _buildDropdown(
                        label: 'Organization Size',
                        items: organizationSizes,
                        value: selectedSize,
                        onChanged: (value) {
                          setState(() {
                            selectedSize = value;
                            _organizationSizeController.text = value ?? '';
                          });
                        },
                      ),
                      _buildDropdown(
                        label: 'Organization Type',
                        items: organizationTypes,
                        value: selectedType,
                        onChanged: (value) {
                          setState(() {
                            selectedType = value;
                            _organizationTypeController.text = value ?? '';
                          });
                        },
                      ),
                      _buildInputField(
                        controller: _tagLineController,
                        label: 'Tagline',
                        maxLines: 2,
                      ),
                      SizedBox(height: 3.h),
                      ElevatedButton(
                        onPressed:
                            companyViewModel.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Create Company',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
