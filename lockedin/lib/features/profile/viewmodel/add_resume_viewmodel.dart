import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/repository/add_resume_repository.dart';

// Define state for resume upload
class ResumeState {
  final bool isLoading;
  final File? selectedFile;
  final String? errorMessage;
  final bool uploadSuccess;

  ResumeState({
    this.isLoading = false,
    this.selectedFile,
    this.errorMessage,
    this.uploadSuccess = false,
  });

  ResumeState copyWith({
    bool? isLoading,
    File? selectedFile,
    String? errorMessage,
    bool? uploadSuccess,
  }) {
    return ResumeState(
      isLoading: isLoading ?? this.isLoading,
      selectedFile: selectedFile ?? this.selectedFile,
      errorMessage: errorMessage, // Always replace error message
      uploadSuccess: uploadSuccess ?? this.uploadSuccess,
    );
  }
}

class AddResumeViewModel extends StateNotifier<ResumeState> {
  final ResumeRepository _repository;

  AddResumeViewModel(this._repository) : super(ResumeState());

  // Pick a PDF file
  Future<void> pickResumeFile() async {
    try {
      // Reset error state
      state = state.copyWith(errorMessage: null);

      // Open file picker for PDF only
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // Validate file size (max 5MB)
        final fileSize = await file.length();
        if (fileSize > 5 * 1024 * 1024) {
          state = state.copyWith(errorMessage: 'File size exceeds 5MB limit');
          return;
        }

        state = state.copyWith(selectedFile: file);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Error selecting file: ${e.toString()}',
      );
    }
  }

  // Upload the selected resume
  Future<bool> uploadResume() async {
    if (state.selectedFile == null) {
      state = state.copyWith(
        errorMessage: 'Please select a PDF resume file first',
      );
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final success = await _repository.uploadResume(state.selectedFile!);

      if (success) {
        state = state.copyWith(isLoading: false, uploadSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to upload resume',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error uploading resume: ${e.toString()}',
      );
      return false;
    }
  }

  // Reset state (useful when navigating away)
  void resetState() {
    state = ResumeState();
  }
}

final addResumeViewModelProvider =
    StateNotifierProvider<AddResumeViewModel, ResumeState>((ref) {
      return AddResumeViewModel(ref.read(resumeRepositoryProvider));
    });
