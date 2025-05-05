// job_repository.dart
import 'package:lockedin/core/services/request_services.dart';

class CreateJobRepository {
  Future<bool> createCompanyJob(Map<String, dynamic> jobData) async {
    print('jobData: $jobData');
    final response = await RequestService.post(
      'jobs',
      body: {
        'companyId': jobData['companyId'],
        'title': jobData['title'],
        'industry': jobData['industry'],
        'workplaceType': jobData['workplaceType'],
        'jobLocation': jobData['jobLocation'],
        'jobType': jobData['jobType'],
        'description': jobData['description'],
        'applicationEmail': jobData['applicationEmail'],
        'screeningQuestions': jobData['screeningQuestions'],
        'autoRejectMustHave': jobData['autoRejectMustHave'],
        'rejectPreview': jobData['rejectPreview'],
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print('create job : ${response.body}');
      print('screeningQuestions: ${jobData['screeningQuestions']}');
      return true;
    } else {
      print('Failed to create job: ${response.body}');
      return false;
    }
  }
}
