import 'package:flutter/material.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/repository/update_profile_repository.dart';

class UpdateProfileViewModel {
  final repository = UpdateProfileRepository();

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

  List<Widget> buildBasicInfoForm() => [
    _textField(controller: firstNameController, label: "First Name"),
    _textField(controller: lastNameController, label: "Last Name"),
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
    _textField(controller: birthDayController, label: "Birth Day (number)"),
    _textField(controller: birthMonthController, label: "Birth Month"),
    _textField(controller: websiteUrlController, label: "Website URL"),
    _textField(controller: websiteTypeController, label: "Website Type"),
  ];

  List<Widget> buildAboutInfoForm() => [
    _textField(controller: descriptionController, label: "Description"),
    _textField(controller: skillsController, label: "Skills (comma-separated)"),
  ];

  Future<void> submitBasicInfo() async {
    await repository.updateBasicInfo({
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "additinalName": additionalNameController.text,
      "headLine": headLineController.text,
      "website": websiteController.text,
      "location": locationController.text,
      "mainEducation": mainEducationController.text,
      "industry": industryController.text,
    });
  }

  Future<void> submitContactInfo() async {
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
  }

  Future<void> submitAboutInfo() async {
    await repository.updateAboutInfo({
      "about": {
        "description": descriptionController.text,
        "skills":
            skillsController.text.split(',').map((e) => e.trim()).toList(),
      },
    });
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
