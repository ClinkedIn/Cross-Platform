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
      await ref
          .read(companyViewModelProvider)
          .fetchJobApplications(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyViewModel = ref.watch(companyViewModelProvider);
    final job = companyViewModel.fetchedJob;
    final applications = companyViewModel.jobApplications;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          job?.description ?? 'Job Details',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body:
          job == null
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Job details card
                    JobCard(job: job),
                    const SizedBox(height: 20),

                    // Applications header
                    Row(
                      children: [
                        Text(
                          'Applications',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${applications.length}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),

                    // Applications list
                    if (applications.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No applications yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        // This is important - makes this inner ListView non-scrollable
                        // and take only the space it needs
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: applications.length,
                        itemBuilder: (context, index) {
                          final app = applications[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                '${app.applicant['firstName']} ${app.applicant['lastName']}',
                              ),
                              subtitle: Text(app.status),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    ),
                                    onPressed: () async {
                                      await ref
                                          .read(companyViewModelProvider)
                                          .acceptJobApplication(
                                            jobId: widget.jobId,
                                            userId: app.applicant['userId'],
                                          );
                                      ref
                                          .read(companyViewModelProvider)
                                          .removeApplicationFromList(
                                            app.applicationId,
                                          );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Applicant accepted'),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () async {
                                      await ref
                                          .read(companyViewModelProvider)
                                          .rejectJobApplication(
                                            jobId: widget.jobId,
                                            userId: app.applicant['userId'],
                                          );
                                      ref
                                          .read(companyViewModelProvider)
                                          .removeApplicationFromList(
                                            app.applicationId,
                                          );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Applicant rejected'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
    );
  }
}
