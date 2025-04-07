import 'package:flutter/material.dart';
import 'package:lockedin/features/jobs/model/job_model.dart';
import 'package:sizer/sizer.dart';

class JobDetailsPage extends StatelessWidget {
  final JobModel job;

  const JobDetailsPage({Key? key, required this.job}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
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
            Text(
              '${job.company} • ${job.location}',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
            ),
            SizedBox(height: 1.h),
            if (job.isRemote)
              Chip(
                label: Text('Remote', style: TextStyle(color: Colors.white)),
                backgroundColor: Colors.green.shade600,
              ),
            SizedBox(height: 2.h),
            Text(
              'Experience Level: ${job.experienceLevel}',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 1.h),
            Text(
              'Salary Range: ${job.salaryRange}',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 2.h),
            Text(
              'Job Description:',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 1.h),
            Expanded(
              child: SingleChildScrollView(
                child: Text(job.description, style: TextStyle(fontSize: 12.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
