import 'package:flutter/material.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:lockedin/features/jobs/view/job_details_page.dart';
import 'package:sizer/sizer.dart';

class JobCardWidget extends StatelessWidget {
  final JobModel job;

  const JobCardWidget({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        subtitle: Text(
          '${job.company} • ${job.location}',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
        ),
        trailing:
            job.isRemote
                ? Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(3.w),
                  ),
                  child: Text(
                    'Remote',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobDetailsPage(job: job)),
          );
        },
      ),
    );
  }
}
