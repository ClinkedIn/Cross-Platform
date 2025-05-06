import 'package:flutter/material.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/repository/update_profile_repository.dart';

// Define an enum to track update status
enum UpdateStatus { idle, loading, success, error }

class UpdateProfileViewModel extends ChangeNotifier {
  final repository = UpdateProfileRepository();

  // Status tracking
  UpdateStatus _status = UpdateStatus.idle;
  String _message = '';

  // Getters for status and message
  UpdateStatus get status => _status;
  String get message => _message;

  // Controllers for Basic Information
  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController additionalNameController;
  late final TextEditingController headLineController;
  late final TextEditingController websiteController;
  late final TextEditingController locationController;
  late final TextEditingController mainEducationController;
  late final TextEditingController industryController;

  // Controllers for Contact Information
  late final TextEditingController phoneController;
  late final TextEditingController phoneTypeController;
  late final TextEditingController addressController;
  late final TextEditingController birthDayController;
  late final TextEditingController birthMonthController;
  late final TextEditingController websiteUrlController;
  late final TextEditingController websiteTypeController;

  // Controllers for About
  late final TextEditingController descriptionController;
  late final TextEditingController skillsController;

  UpdateProfileViewModel(UserModel userState) {
    firstNameController = TextEditingController(text: userState.firstName);
    lastNameController = TextEditingController(text: userState.lastName);
    additionalNameController = TextEditingController(
      text: userState.additionalName ?? '',
    );
    headLineController = TextEditingController(text: userState.headline ?? '');
    websiteController = TextEditingController(text: userState.website ?? '');
    locationController = TextEditingController(text: userState.location ?? '');
    mainEducationController = TextEditingController(
      text: userState.mainEducation ?? '',
    );
    industryController = TextEditingController(text: userState.industry ?? '');

    phoneController = TextEditingController(
      text: userState.contactInfo?.phone.toString() ?? '',
    );
    phoneTypeController = TextEditingController(
      text: userState.contactInfo?.phoneType.toString() ?? '',
    );
    addressController = TextEditingController(
      text: userState.contactInfo?.address.toString() ?? '',
    );
    birthDayController = TextEditingController(
      text: (userState.contactInfo?.birthDay.day ?? '').toString(),
    );
    birthMonthController = TextEditingController(
      text: userState.contactInfo?.birthDay.month ?? '',
    );
    websiteUrlController = TextEditingController(
      text: userState.contactInfo?.website?.url ?? '',
    );
    websiteTypeController = TextEditingController(
      text: userState.contactInfo?.website?.type ?? '',
    );

    descriptionController = TextEditingController(
      text: userState.about?.description ?? '',
    );
    skillsController = TextEditingController(
      text: (userState.about?.skills as List<dynamic>?)?.join(', ') ?? '',
    );
  }

  // Method to update status and notify listeners
  void _updateStatus(UpdateStatus newStatus, String message) {
    _status = newStatus;
    _message = message;
    notifyListeners();
  }

  // Reset status to idle
  void resetStatus() {
    _status = UpdateStatus.idle;
    _message = '';
    notifyListeners();
  }

  List<Widget> buildBasicInfoForm() => [
    _textField(
      controller: firstNameController,
      label: "First Name",
      required: true,
    ),
    _textField(
      controller: lastNameController,
      label: "Last Name",
      required: true,
    ),
    _textField(controller: additionalNameController, label: "Additional Name"),
    _textField(controller: headLineController, label: "Headline"),
    _textField(controller: websiteController, label: "Website"),
    _textField(controller: locationController, label: "Location"),
    _textField(controller: mainEducationController, label: "Main Education"),
    _textField(controller: industryController, label: "Industry"),
  ];

  List<Widget> buildContactInfoForm() => [
    _textField(controller: phoneController, label: "Phone"),
    _textField(controller: phoneTypeController, label: "Phone Type"),
    _textField(controller: addressController, label: "Address"),
    _textField(
      controller: birthDayController,
      label: "Birth Day (number)",
      keyboardType: TextInputType.number,
    ),
    _textField(controller: birthMonthController, label: "Birth Month"),
    _textField(controller: websiteUrlController, label: "Website URL"),
    _textField(controller: websiteTypeController, label: "Website Type"),
  ];

  List<Widget> buildAboutInfoForm() => [
    _textField(
      controller: descriptionController,
      label: "Description",
      maxLines: 4,
    ),
    _textField(controller: skillsController, label: "Skills (comma-separated)"),
  ];

  // Enhanced methods with proper error handling and status updates
  Future<bool> submitBasicInfo() async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      _updateStatus(
        UpdateStatus.error,
        "First name and last name are required",
      );
      return false;
    }

    try {
      _updateStatus(UpdateStatus.loading, "Updating basic information...");

      await repository.updateBasicInfo({
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
        "additionalName": additionalNameController.text,
        "headLine": headLineController.text,
        "website": websiteController.text,
        "location": locationController.text,
        "mainEducation": mainEducationController.text,
        "industry": industryController.text,
      });

      _updateStatus(
        UpdateStatus.success,
        "Basic information updated successfully",
      );
      return true;
    } catch (e) {
      _updateStatus(
        UpdateStatus.error,
        "Failed to update basic information: ${e.toString()}",
      );
      return false;
    }
  }

  Future<bool> submitContactInfo() async {
    try {
      _updateStatus(UpdateStatus.loading, "Updating contact information...");

      await repository.updateContactInfo({
        "phone": phoneController.text,
        "phoneType": phoneTypeController.text,
        "address": addressController.text,
        "birthDay": {
          "day": int.tryParse(birthDayController.text) ?? 0,
          "month": birthMonthController.text,
        },
        "website": {
          "url": websiteUrlController.text,
          "type": websiteTypeController.text,
        },
      });

      _updateStatus(
        UpdateStatus.success,
        "Contact information updated successfully",
      );
      return true;
    } catch (e) {
      _updateStatus(
        UpdateStatus.error,
        "Failed to update contact information: ${e.toString()}",
      );
      return false;
    }
  }

  Future<bool> submitAboutInfo() async {
    try {
      _updateStatus(UpdateStatus.loading, "Updating about information...");

      await repository.updateAboutInfo({
        "about": {
          "description": descriptionController.text,
          "skills":
              skillsController.text.split(',').map((e) => e.trim()).toList(),
        },
      });

      _updateStatus(
        UpdateStatus.success,
        "About information updated successfully",
      );
      return true;
    } catch (e) {
      _updateStatus(
        UpdateStatus.error,
        "Failed to update about information: ${e.toString()}",
      );
      return false;
    }
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: required ? "$label *" : label,
          border: const OutlineInputBorder(),
          helperText: required ? "Required" : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose all controllers
    firstNameController.dispose();
    lastNameController.dispose();
    additionalNameController.dispose();
    headLineController.dispose();
    websiteController.dispose();
    locationController.dispose();
    mainEducationController.dispose();
    industryController.dispose();

    phoneController.dispose();
    phoneTypeController.dispose();
    addressController.dispose();
    birthDayController.dispose();
    birthMonthController.dispose();
    websiteUrlController.dispose();
    websiteTypeController.dispose();

    descriptionController.dispose();
    skillsController.dispose();

    super.dispose();
  }
}
