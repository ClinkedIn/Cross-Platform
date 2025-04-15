import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    if (job == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? AppColors.primary,
        title: Text(job.title, style: theme.appBarTheme.titleTextStyle),
        iconTheme: theme.appBarTheme.iconTheme,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),

            // Show Company + Location
            Text(
              '${job.company} • ${job.location}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 1.h),

            // Show Industry
            if (job.industry != null)
              Text(
                'Industry: ${job.industry}',
                style: theme.textTheme.bodyLarge,
              ),

            // Show Workplace Type (Onsite/Remote/etc.)
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

            Text(
              'Experience Level: ${job.experienceLevel}',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.h),

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
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ContactInfoPage(
                              screeningQuestions: job.screeningQuestions,
                            ),
                      ),
                    );

                    if (result != null && result is Map<String, dynamic>) {
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

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Application submitted successfully!',
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to apply: $e')),
                        );
                      }
                    }
                  },
                  child: Text('Easy Apply', style: theme.textTheme.labelLarge),
                  style: theme.elevatedButtonTheme.style,
                ),
              ],
            ),
            SizedBox(height: 1.h),

            // Description Scroll
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  job.description,
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
