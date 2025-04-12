import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/position_model.dart';
import 'package:lockedin/features/profile/service/position_service.dart';

final addPositionViewModelProvider =
    StateNotifierProvider<AddPositionViewModel, AsyncValue<void>>((ref) {
      return AddPositionViewModel(ref);
    });

class AddPositionViewModel extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  AddPositionViewModel(this.ref) : super(const AsyncValue.data(null));

  Future<bool> addPosition(
    Position position,
    List<File> mediaFiles,
    BuildContext context,
  ) async {
    state = const AsyncValue.loading();
    try {
      String? mediaUrl;

      // If we have media files, upload the first one
      if (mediaFiles.isNotEmpty) {
        try {
          mediaUrl = await PositionService.uploadMediaFile(mediaFiles.first);
          print("Uploaded media URL: $mediaUrl");
        } catch (e) {
          print("Failed to upload media: $e");
          // Continue without media if upload fails
        }
      }

      // Create a position object with media URL
      final positionWithMedia = Position(
        jobTitle: position.jobTitle,
        companyName: position.companyName,
        employmentType: position.employmentType,
        currentlyWorking: position.currentlyWorking,
        fromDate: position.fromDate,
        toDate: position.toDate,
        location: position.location,
        locationType: position.locationType,
        description: position.description,
        foundVia: position.foundVia,
        skills: position.skills,
        media: mediaUrl,
      );

      // Add the position
      final response = await PositionService.addPosition(positionWithMedia);

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = const AsyncValue.data(null);
        return true;
      } else {
        throw Exception('Failed to add experience: ${response.body}');
      }
    } catch (e, stack) {
      print("Error in addPosition: $e");
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}
