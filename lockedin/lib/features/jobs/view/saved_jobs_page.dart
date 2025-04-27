import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/jobs/viewmodel/job_view_model.dart';
import 'package:lockedin/features/jobs/widgets/job_card_widget.dart';

class SavedJobsPage extends ConsumerWidget {
  const SavedJobsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobViewModel = ref.watch(JobViewModel.provider);
    final savedJobIds = jobViewModel.savedJobs;

    // Filter jobs by saved IDs
    final savedJobs =
        jobViewModel.jobs.where((job) => savedJobIds.contains(job.id)).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Saved Jobs',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            savedJobs.isEmpty
                ? const Center(
                  child: Text(
                    'No saved jobs yet.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
                : ListView.builder(
                  itemCount: savedJobs.length,
                  itemBuilder: (context, index) {
                    final job = savedJobs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: JobCardWidget(job: job),
                    );
                  },
                ),
      ),
    );
  }
}
