import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:lockedin/features/jobs/viewmodel/job_view_model.dart';
// Ensure correct import

class ApplicationStatusPage extends ConsumerWidget {
  final String jobId; // Receive jobId as a parameter

  const ApplicationStatusPage({Key? key, required this.jobId})
    : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the JobViewModel
    final jobViewModel = ref.watch(JobViewModel.provider);

    // Find the job by its ID from the list of jobs
    final job = jobViewModel.jobs.firstWhere(
      (job) => job.id == jobId,
      orElse:
          () => JobModel(
            id: jobId,
            title: 'Unknown Job',
            company: 'Unknown Company',
            companyId: '',
            location: 'Unknown Location',
            description: '',
            experienceLevel: 'Unknown',
            salaryRange: 'N/A',
            isRemote: false,
            workplaceType: 'Unknown',
            screeningQuestions: [],
            applicants: [],
            accepted: [],
            rejected: [],
            applicationStatus: 'Not Applied',
          ),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Application Status')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Job ID: ${job.id}'),
            SizedBox(height: 16),
            Text('Job Title: ${job.title}'),
            SizedBox(height: 8),
            Text('Company: ${job.company}'),
            SizedBox(height: 8),
            Text('Location: ${job.location}'),
            SizedBox(height: 8),
            Text('Status: ${job.applicationStatus}'),
            SizedBox(height: 16),
            // You can add more fields or logic based on job data
          ],
        ),
      ),
    );
  }
}
