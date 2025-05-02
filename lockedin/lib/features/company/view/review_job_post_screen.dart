import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/view/company_profile.dart';
import 'package:lockedin/features/company/viewmodel/company_viewmodel.dart';
import 'package:sizer/sizer.dart';
import 'job_details_screen.dart';
import 'job_description_screen.dart';

class ReviewJobPostScreen extends ConsumerStatefulWidget {
  final String jobTitle;
  final String company;
  final String location;
  final String jobType;
  final String workplaceType;
  final String companyId;
  final String? jobDescription;

  const ReviewJobPostScreen({
    super.key,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.jobType,
    required this.workplaceType,
    required this.companyId,
    this.jobDescription,
  });

  @override
  ConsumerState<ReviewJobPostScreen> createState() =>
      _ReviewJobPostScreenState();
}

class _ReviewJobPostScreenState extends ConsumerState<ReviewJobPostScreen> {
  String? jobDescription;
  bool get hasValidDescription => jobDescription?.trim().isNotEmpty ?? false;

  @override
  void initState() {
    super.initState();
    jobDescription = widget.jobDescription;
  }

  void _navigateToJobDescription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDescriptionScreen(
          initialText: jobDescription,
          jobTitle: widget.jobTitle,
          company: widget.company,
          location: widget.location,
          jobType: widget.jobType,
          workplaceType: widget.workplaceType,
          companyId: widget.companyId,
        ),
      ),
    );
  }

  void _navigateToEditJobDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => JobDetailsScreen(
              initialJobTitle:
                  widget.jobTitle, // Replace with correct state handling
              companyId: widget.companyId,
            ),
      ),
    );
  }

  Future<void> submitJob() async {
    final viewModel = ref.read(companyViewModelProvider);

    final success = await viewModel.createJob(
      jobTitle: widget.jobTitle,
      location: widget.location,
      jobType: widget.jobType,
      workplaceType: widget.workplaceType,
      companyId: widget.companyId,
      description: jobDescription!.trim(), // use actual description
    );

    // Make sure widget is still mounted before using context
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Job posted successfully!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CompanyProfileView(companyId: widget.companyId),
        ),
      );
    } else {
      final error = viewModel.errorMessage ?? 'Failed to create job post.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review job post', style: TextStyle(fontSize: 18.sp)),
        leading: BackButton(),
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Job Details",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: _navigateToEditJobDetails,
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              const Icon(
                                Icons.business,
                                size: 40,
                                color: Colors.black,
                              ),
                              SizedBox(width: 3.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.jobTitle,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "${widget.company} • ${widget.jobType}",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    "${widget.location} (${widget.workplaceType})",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 3.h),
            InkWell(
              onTap: _navigateToJobDescription,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Job Description",
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          hasValidDescription
                              ? jobDescription!.trim()
                              : "Add job description",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color:
                                hasValidDescription
                                    ? Colors.black
                                    : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.add, color: Colors.blue),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                if (!hasValidDescription) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Must add a job description")),
                  );
                  return;
                }
                submitJob();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 6.h),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Post job for free",
                style: TextStyle(fontSize: 18.sp),
              ),
            ),
            SizedBox(height: 2.h),
            Text.rich(
              TextSpan(
                text: "By continuing, you agree to LinkedIn's ",
                style: TextStyle(fontSize: 16.sp),
                children: [
                  TextSpan(
                    text: "Jobs Terms and Conditions",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: " including "),
                  TextSpan(
                    text: "policies prohibiting discriminatory jobs.",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
