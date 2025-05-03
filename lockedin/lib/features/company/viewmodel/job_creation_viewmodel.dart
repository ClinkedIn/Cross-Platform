// job_creation_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:lockedin/features/home_page/repository/job_creation_repository.dart';

class JobCreationViewModel {
  final String companyId;
  JobCreationViewModel(this.companyId);

  final titleController = TextEditingController();
  final industryController = TextEditingController();
  final jobLocationController = TextEditingController();
  final descriptionController = TextEditingController();
  final applicationEmailController = TextEditingController();
  final rejectPreviewController = TextEditingController();

  String workplaceType = 'Onsite';
  String jobType = 'Full Time';
  bool autoRejectMustHave = false;

  List<Map<String, TextEditingController>> screeningQuestionControllers = [];
  List<String?> screeningQuestionValues = []; // selected dropdown values
  List<bool> mustHaveValues = [];

  void addScreeningQuestion() {
    screeningQuestionControllers.add({
      'idealAnswer': TextEditingController(),
    });
    screeningQuestionValues.add(null); // No selection initially
    mustHaveValues.add(false);
  }

  void submitJob(BuildContext context) {
    List<Map<String, dynamic>> screeningQuestions = [];

    for (int i = 0; i < screeningQuestionControllers.length; i++) {
      final question = screeningQuestionValues[i];
      final idealAnswer = screeningQuestionControllers[i]['idealAnswer']?.text.trim();

      if (question != null && question.isNotEmpty) {
        screeningQuestions.add({
          'question': question,
          'idealAnswer': idealAnswer ?? '',
          'mustHave': mustHaveValues[i],
        });
      }
    }

    final job = {
      'companyId': companyId,
      'title': titleController.text.trim(),
      'industry': industryController.text.trim(),
      'jobLocation': jobLocationController.text.trim(),
      'description': descriptionController.text.trim(),
      'applicationEmail': applicationEmailController.text.trim(),
      'workplaceType': workplaceType,
      'jobType': jobType,
      'autoRejectMustHave': autoRejectMustHave,
      'rejectPreview': rejectPreviewController.text.trim(),
      'screeningQuestions': screeningQuestions,
    };

    final repository = CreateJobRepository();
    repository.createCompanyJob(job).then((success) {
      final snackBar = SnackBar(
        content: Text(success ? 'Job created' : 'Failed to create job'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    });
  }
}

