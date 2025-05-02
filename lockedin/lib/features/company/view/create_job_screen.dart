import 'package:flutter/material.dart';
import 'package:lockedin/features/company/view/job_details_screen.dart';
import 'package:sizer/sizer.dart';

class CreateJobScreen extends StatefulWidget {
  final String companyId;

  const CreateJobScreen({super.key, required this.companyId});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final TextEditingController _jobTitleController = TextEditingController();

  void _writeOnMyOwn() {
    final jobTitle = _jobTitleController.text.trim();

    if (jobTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Job title cannot be empty")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailsScreen(initialJobTitle: jobTitle, companyId: widget.companyId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        elevation: 0,
        title: Text("Post a Job", style: TextStyle(fontSize: 20.sp)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h),
            Center(
              child: Icon(Icons.star, size: 5.h, color: Colors.blueAccent),
            ),
            SizedBox(height: 2.h),
            Center(
              child: Text(
                "Post a job in minutes",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 0.8.h),
            Center(
              child: Text(
                "Increase the quality of your hire",
                style: TextStyle(fontSize: 17.sp),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Job title",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17.sp),
            ),
            SizedBox(height: 1.h),
            TextField(
              controller: _jobTitleController,
              decoration: InputDecoration(
                hintText: "Add job title",
                border: UnderlineInputBorder(),
              ),
              style: TextStyle(fontSize: 17.sp),
            ),
            SizedBox(height: 6.h),
            Center(
              child: GestureDetector(
                onTap: _writeOnMyOwn,
                child: Text(
                  "Write on my own",
                  style: TextStyle(
                    fontSize: 20.sp,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
