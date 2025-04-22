import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/auth/services/user_credentials_provider.dart';
import 'package:lockedin/features/jobs/view/contact_info.dart';
import 'package:lockedin/features/jobs/viewmodel/job_view_model.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';

class JobDetailsPage extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailsPage({Key? key, required this.jobId}) : super(key: key);

  @override
  ConsumerState<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends ConsumerState<JobDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(JobViewModel.provider).fetchJobById(widget.jobId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobViewModel = ref.watch(JobViewModel.provider);
    final job = jobViewModel.selectedJob;
    final userCredentialsAsync = ref.watch(userCredentialsProvider);

    if (job == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return userCredentialsAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (credentials) {
        final userId = credentials['email'] ?? '';
        final status = jobViewModel.getApplicationStatusForCurrentUser(userId);

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor:
                theme.appBarTheme.backgroundColor ?? AppColors.primary,
            title: Text(job.title, style: theme.appBarTheme.titleTextStyle),
            iconTheme: theme.appBarTheme.iconTheme,
          ),
          body: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Title
                Text(
                  job.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),

                // Company & Location
                Text(
                  '${job.company} • ${job.location}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 1.h),

                // Industry
                if (job.industry != null)
                  Text(
                    'Industry: ${job.industry}',
                    style: theme.textTheme.bodyLarge,
                  ),

                // Workplace Type
                Text(
                  'Workplace Type: ${job.workplaceType}',
                  style: theme.textTheme.bodyLarge,
                ),
                if (job.isRemote)
                  Padding(
                    padding: EdgeInsets.only(top: 0.5.h),
                    child: Text(
                      'Remote',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                // Experience Level
                Text(
                  'Experience Level: ${job.experienceLevel}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),

                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    SizedBox(width: 2.w),
                    Text(
                      'Status: $status',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color:
                            status == 'Accepted'
                                ? Colors.green
                                : status == 'Rejected'
                                ? Colors.red
                                : status == 'Pending'
                                ? Colors.orange
                                : Colors.grey,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Easy Apply Button
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Job Description:',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          status == 'Not Applied'
                              ? () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => ContactInfoPage(
                                          screeningQuestions:
                                              job.screeningQuestions,
                                          userId: userId,
                                        ),
                                  ),
                                );

                                if (result != null &&
                                    result is Map<String, dynamic>) {
                                  final contactEmail = result['email'];
                                  final contactPhone = result['phone'];
                                  final answers = result['answers'];

                                  try {
                                    await jobViewModel.applyToJob(
                                      jobId: job.id,
                                      contactEmail: contactEmail,
                                      contactPhone: contactPhone,
                                      answers: answers,
                                    );

                                    await jobViewModel.fetchJobById(job.id);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Application submitted successfully!',
                                        ),
                                      ),
                                    );
                                    setState(() {});
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to apply: $e'),
                                      ),
                                    );
                                  }
                                }
                              }
                              : null,
                      child: Text(
                        'Easy Apply',
                        style: theme.textTheme.labelLarge,
                      ),
                      style: theme.elevatedButtonTheme.style,
                    ),
                  ],
                ),

                SizedBox(height: 1.h),

                // Description
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      job.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
