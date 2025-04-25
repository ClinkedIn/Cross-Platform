import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lockedin/features/auth/services/user_credentials_provider.dart';
import 'package:lockedin/features/company/model/repository/company_repository.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:lockedin/features/jobs/view/contact_info.dart';
import 'package:lockedin/features/jobs/viewmodel/job_view_model.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';

final _secureStorage = FlutterSecureStorage();

Future<void> storeApplicationStatus(String jobId, bool hasApplied) async {
  await _secureStorage.write(key: jobId, value: hasApplied ? 'true' : 'false');
}

Future<bool> getApplicationStatus(String jobId) async {
  final status = await _secureStorage.read(key: jobId);
  return status == 'true';
}

class JobDetailsPage extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailsPage({Key? key, required this.jobId}) : super(key: key);

  @override
  ConsumerState<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends ConsumerState<JobDetailsPage> {
  String? companyName;
  String status = 'Not Applied'; // Default status

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = ref.read(JobViewModel.provider);
      await viewModel.fetchJobById(widget.jobId);
      final job = viewModel.selectedJob;

      if (job != null) {
        if ((job.company?.isEmpty ?? true) &&
            job.companyId?.isNotEmpty == true) {
          final companyRepo = CompanyRepository();
          final company = await companyRepo.getCompanyById(job.companyId);
          if (company != null) {
            setState(() {
              companyName = company.name;
            });
          }
        } else {
          setState(() {
            companyName = job.company ?? 'Unknown Company';
          });
        }

        // Check if the user has already applied
        final hasApplied = await getApplicationStatus(widget.jobId);
        setState(() {
          status = hasApplied ? 'Pending' : 'Not Applied';
        });
      }
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

        final job = jobViewModel.jobs.firstWhere(
          (job) => job.id == widget.jobId,
          orElse:
              () => JobModel(
                id: widget.jobId,
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
                Text(
                  job.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '${job.company} • ${job.location}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 1.h),
                if (job.industry != null)
                  Text(
                    'Industry: ${job.industry}',
                    style: theme.textTheme.bodyLarge,
                  ),
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
                                          jobId: job.id,
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

                                    await storeApplicationStatus(
                                      job.id,
                                      true,
                                    ); // Store the application status

                                    // After applying, we need to fetch job again and update status
                                    await jobViewModel.fetchJobById(job.id);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Application submitted successfully!',
                                        ),
                                      ),
                                    );

                                    setState(() {
                                      status =
                                          'Pending'; // Update the status immediately after applying
                                    });
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
