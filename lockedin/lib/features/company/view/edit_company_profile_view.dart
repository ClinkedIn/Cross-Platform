import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lockedin/features/company/viewmodel/company_viewmodel.dart';
import 'package:sizer/sizer.dart';

class EditCompanyProfileView extends ConsumerStatefulWidget {
  final String companyId;

  const EditCompanyProfileView({Key? key, required this.companyId})
    : super(key: key);

  @override
  ConsumerState<EditCompanyProfileView> createState() =>
      _EditCompanyProfileViewState();
}

class _EditCompanyProfileViewState
    extends ConsumerState<EditCompanyProfileView> {
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;
  final _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _industryController;
  late TextEditingController _organizationSizeController;
  late TextEditingController _organizationTypeController;
  late TextEditingController _tagLineController;
  late TextEditingController _locationController;

  @override
  void initState() {
    super.initState();
    final company = ref.read(companyViewModelProvider).fetchedCompany;

    _nameController = TextEditingController(text: company?.name ?? '');
    _addressController = TextEditingController(text: company?.address ?? '');
    _websiteController = TextEditingController(text: company?.website ?? '');
    _industryController = TextEditingController(text: company?.industry ?? '');
    _organizationSizeController = TextEditingController(
      text: company?.organizationSize ?? '',
    );
    _organizationTypeController = TextEditingController(
      text: company?.organizationType ?? '',
    );
    _tagLineController = TextEditingController(text: company?.tagLine ?? '');
    _locationController = TextEditingController(text: company?.location ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _industryController.dispose();
    _organizationSizeController.dispose();
    _organizationTypeController.dispose();
    _tagLineController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(companyViewModelProvider)
          .editCompany(
            companyId: widget.companyId,
            name: _nameController.text.trim(),
            address: _addressController.text.trim(),
            website: _websiteController.text.trim(),
            industry: _industryController.text.trim(),
            organizationSize: _organizationSizeController.text.trim(),
            organizationType: _organizationTypeController.text.trim(),
            tagLine: _tagLineController.text.trim(),
            location: _locationController.text.trim(),
            logoPath: _pickedImage?.path,
          );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Company updated successfully!')),
        );
        Navigator.pop(context); // Go back after success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update company.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(companyViewModelProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Company Profile')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(5.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 10.w,
                          backgroundImage:
                              _pickedImage != null
                                  ? FileImage(_pickedImage!)
                                  : null,
                          child:
                              _pickedImage == null
                                  ? const Icon(Icons.camera_alt, size: 40)
                                  : null,
                        ),
                      ),
                      SizedBox(height: 5.w),
                      _buildTextField(_nameController, 'Name'),
                      _buildTextField(_addressController, 'Address'),
                      _buildTextField(
                        _websiteController,
                        'Website',
                        required: false,
                      ),
                      _buildTextField(_industryController, 'Industry'),
                      _buildTextField(
                        _organizationSizeController,
                        'Organization Size',
                      ),
                      _buildTextField(
                        _organizationTypeController,
                        'Organization Type',
                      ),
                      _buildTextField(
                        _tagLineController,
                        'Tagline',
                        required: false,
                      ),
                      _buildTextField(
                        _locationController,
                        'Location',
                        required: false,
                      ),
                      SizedBox(height: 5.w),
                      ElevatedButton(
                        onPressed: _submit,
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = true,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.w),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator:
            required
                ? (value) =>
                    value == null || value.isEmpty ? '$label is required' : null
                : null,
      ),
    );
  }
}
