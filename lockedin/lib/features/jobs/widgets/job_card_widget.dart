import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:lockedin/features/jobs/view/job_details_page.dart';
import 'package:lockedin/features/jobs/viewmodel/job_view_model.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';

class JobCardWidget extends StatelessWidget {
  final JobModel job;

  const JobCardWidget({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final jobViewModel = ref.watch(JobViewModel.provider);
        final isSaved = ref.watch(
          JobViewModel.provider.select(
            (viewModel) => viewModel.savedJobs.contains(job.id),
          ),
        );

        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 5.w),
          child: ListTile(
            leading: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 12.w,
                minHeight: 12.w,
                maxWidth: 12.w,
                maxHeight: 12.w,
              ),
              child:
                  job.logoUrl != null && job.logoUrl!.startsWith('http')
                      ? Image.network(
                        job.logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset('assets/images/experience.jpg');
                        },
                      )
                      : Image.asset(
                        'assets/images/experience.jpg',
                        fit: BoxFit.cover,
                      ),
            ),
            title: Text(
              job.title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                Flexible(
                  child: Text(
                    '${job.company} • ${job.location}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (job.isRemote)
                  Padding(
                    padding: EdgeInsets.only(left: 1.w),
                    child: Text(
                      '• Remote',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? AppColors.primary : null,
              ),
              onPressed: () {
                if (isSaved) {
                  print("Unsaving job with ID: ${job.id}");
                  jobViewModel.unsaveJob(job.id.toString()); // Unsave the job
                } else {
                  print("Saving job with ID: ${job.id}");
                  jobViewModel.saveJob(job.id.toString()); // Save the job
                }
              },
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailsPage(jobId: job.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
