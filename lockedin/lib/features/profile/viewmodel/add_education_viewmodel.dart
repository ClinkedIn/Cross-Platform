import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/service/education_service.dart';

final addEducationViewModelProvider =
    StateNotifierProvider<AddEducationViewModel, AsyncValue<void>>((ref) {
      return AddEducationViewModel(ref);
    });

class AddEducationViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  AddEducationViewModel(this.ref) : super(const AsyncValue.data(null));

  Future<bool> addEducation(
    Education education,
    List<File> mediaFiles,
    BuildContext context,
  ) async {
    state = const AsyncValue.loading();
    try {
      print("Adding education: ${education.toJson()}");
      String? mediaUrl;

      // If we have media files, upload the first one
      if (mediaFiles.isNotEmpty) {
        try {
          mediaUrl = "cijfcndcpwoe/...";
          print("Uploaded media URL: $mediaUrl");
        } catch (e) {
          print("Failed to upload media: $e");
          // Continue without media if upload fails
        }
      }

      // Ensure all fields are properly formatted
      final Map<String, dynamic> educationData = {
        'school': education.school,
        'degree': education.degree ?? "",
        'fieldOfStudy': education.fieldOfStudy ?? "",
        'startDate': education.startDate ?? "",
        'endDate': education.endDate ?? "",
        'grade': education.grade ?? "",
        'activities': education.activities ?? "",
        'description': education.description ?? "",
        'skills': education.skills ?? [],
        'media': mediaUrl ?? "",
      };

      print("Sending education data: $educationData");

      // Add the education
      final response = await EducationService.addEducation(
        Education(
          school: educationData['school'],
          degree: educationData['degree'],
          fieldOfStudy: educationData['fieldOfStudy'],
          startDate: educationData['startDate'],
          endDate: educationData['endDate'],
          grade: educationData['grade'],
          activities: educationData['activities'],
          description: educationData['description'],
          skills:
              educationData['skills'] is List
                  ? List<String>.from(educationData['skills'])
                  : [],
          media: educationData['media'],
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw Exception('Failed to add education: ${response.body}');
      }
    } catch (e, stack) {
      print("Error in addEducation: $e");
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}
