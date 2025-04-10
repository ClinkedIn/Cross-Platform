import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:lockedin/features/jobs/view/contact_info.dart';
import 'package:lockedin/features/jobs/viewmodel/job_view_model.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';

class JobDetailsPage extends ConsumerWidget {
  final JobModel job;

  const JobDetailsPage({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white, // Set page background to white
      appBar: AppBar(
        backgroundColor: AppColors.primary, // AppBar background
        title: Text(
          job.title,
          style: TextStyle(color: Colors.white), // Title color white
        ),
        iconTheme: IconThemeData(color: Colors.white), // Back icon color white
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${job.company} • ${job.location}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              'Experience Level: ${job.experienceLevel}',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            Text(
              'Salary Range: ${job.salaryRange}',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
            ),
            if (job.isRemote)
              Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Text(
                  'Remote',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Job Description:',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactInfoPage(),
                      ),
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      final contactEmail = result['email'];
                      final contactPhone = result['phone'];
                      final answers = result['answers'];

                      final jobViewModel = ref.read(JobViewModel.provider);

                      try {
                        await jobViewModel.applyToJob(
                          jobId: job.id,
                          contactEmail: contactEmail,
                          contactPhone: contactPhone,
                          answers: answers,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
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
                  child: Text(' Easy Apply'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.2.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Expanded(
              child: SingleChildScrollView(
                child: Text(job.description, style: TextStyle(fontSize: 14.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
