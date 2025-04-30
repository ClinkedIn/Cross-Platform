import 'package:flutter/material.dart';
import 'package:lockedin/features/admin/repository/admin_repository.dart';
import 'package:lockedin/features/admin/viewModel/flagged_jobs_viewmodel.dart';
import 'package:provider/provider.dart';

class FlaggedJobsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              FlaggedJobsViewModel(repository: AdminRepository())..loadJobs(),
      child: Scaffold(
        appBar: AppBar(title: Text('Flagged Jobs')),
        body: Consumer<FlaggedJobsViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (vm.error != null) {
              return Center(child: Text('Error: ${vm.error}'));
            } else if (vm.jobs.isEmpty) {
              return Center(child: Text('No flagged jobs'));
            }

            return ListView.builder(
              itemCount: vm.jobs.length,
              itemBuilder: (context, index) {
                final job = vm.jobs[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.flag, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${job.jobType} • ${job.workplaceType}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('Location: ${job.jobLocation}'),
                        Text(
                          'Applicants: ${job.applicants.length} • Accepted: ${job.accepted.length} • Rejected: ${job.rejected.length}',
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Description: ${job.description}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        if (job.autoRejectMustHave)
                          Text(
                            '⚠️ Flagged: Must-have screening questions with auto-reject',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (job.screeningQuestions.isNotEmpty) ...[
                          SizedBox(height: 6),
                          Text(
                            'Screening Questions:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...job.screeningQuestions
                              .map(
                                (q) => Text(
                                  '- ${q.question} ${q.mustHave ? "(Must Have)" : ""}',
                                ),
                              )
                              .toList(),
                        ],
                        SizedBox(height: 8),
                        Text('Posted on: ${job.createdAt.toLocal()}'),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
