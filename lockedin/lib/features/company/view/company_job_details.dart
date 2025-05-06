import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/model/company_job_model.dart';
import 'package:lockedin/features/company/widgets/job_card.dart';
import 'package:lockedin/features/company/viewmodel/company_viewmodel.dart';
import 'package:sizer/sizer.dart';

class JobDetailsScreen extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(companyViewModelProvider).getSpecificJob(widget.jobId);
      await ref.read(companyViewModelProvider).fetchJobApplications(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyViewModel = ref.watch(companyViewModelProvider);
    final job = companyViewModel.fetchedJob;
    final applications = companyViewModel.jobApplications;

    return Scaffold(
      appBar: AppBar(
        title: Text(job?.jobType ?? 'Job Details'),
      ),
      body: job == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JobCard(job: job),
                  SizedBox(height: 20),
                  Text(
                    'Applications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...applications
                      .where((app) => app.status != 'accepted' && app.status != 'rejected')
                      .map((app) => Card(
                        child: ListTile(
                          title: Text(
                            '${app.applicant['firstName']} ${app.applicant['lastName']}',
                          ),
                          subtitle: Text(app.status),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () async {
                                  await ref.read(companyViewModelProvider).acceptJobApplication(
                                    jobId: widget.jobId,
                                    userId: app.applicant['userId'],
                                  );
                                  ref.read(companyViewModelProvider).removeApplicationFromList(app.applicationId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Applicant accepted')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () async {
                                  await ref.read(companyViewModelProvider).rejectJobApplication(
                                    jobId: widget.jobId,
                                    userId: app.applicant['userId'],
                                  );
                                  ref.read(companyViewModelProvider).removeApplicationFromList(app.applicationId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Applicant rejected')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
    );
  }
}
