import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/view/company_analytics_screen.dart';
import 'package:lockedin/features/company/view/company_job_details.dart';
import 'package:lockedin/features/company/view/create_job_screen.dart';
import 'package:lockedin/features/company/view/create_post_screen.dart';
import 'package:lockedin/features/company/view/edit_company_profile_view.dart';
import 'package:lockedin/features/company/viewmodel/company_viewmodel.dart';
import 'package:lockedin/features/company/widgets/job_card.dart';
import 'package:lockedin/features/company/widgets/post_card.dart';
import 'package:sizer/sizer.dart';

class CompanyProfileView extends ConsumerStatefulWidget {
  final String companyId;

  const CompanyProfileView({Key? key, required this.companyId})
    : super(key: key);

  @override
  ConsumerState<CompanyProfileView> createState() => _CompanyProfileViewState();
}

class _CompanyProfileViewState extends ConsumerState<CompanyProfileView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(companyViewModelProvider).fetchCompanyById(widget.companyId);
      ref.read(companyViewModelProvider).fetchCompanyPosts(widget.companyId);
      ref.read(companyViewModelProvider).fetchCompanyJobs(widget.companyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final companyViewModel = ref.watch(companyViewModelProvider);
    final isLoading = companyViewModel.isLoading;
    final errorMessage = companyViewModel.errorMessage;
    final company = companyViewModel.fetchedCompany;
    final posts = companyViewModel.companyPosts;
    final jobs = companyViewModel.companyJobs;

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 10.w,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 8.w),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            company != null
                ? Row(
                  children: [
                    if (company.logo != null)
                      ClipOval(
                        child: Image.network(
                          company.logo!.startsWith('http')
                              ? company.logo!
                              : 'http://10.0.2.2:3000/${company.logo}',
                          height: 8.w,
                          width: 8.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.business,
                            size: 8.w,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.account_circle,
                        size: 8.w,
                        color: Colors.grey[400],
                      ),
                    SizedBox(width: 2.w),
                    Flexible(
                      child: Text(
                        company.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
                : Text(
                  'Company Profile',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.dashboard_customize, size: 6.w),
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) =>
                            EditCompanyProfileView(companyId: widget.companyId),
                  ),
                );
              }
              else if (value == 'analytics') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CompanyAnalyticsScreen(companyId: widget.companyId),
                  ),
                );
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit Company'),
                  ),
                  const PopupMenuItem(
                    value: 'analytics',
                    child: Text('Analytics'),
                  ),
                ],
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? Center(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
              )
              : company == null
              ? Center(
                child: Text(
                  'No company data found.',
                  style: TextStyle(fontSize: 14.sp),
                ),
              )
              : ListView(
                padding: EdgeInsets.all(3.w),
                children: [
                  Text(
                    "Company Overview",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (company.logo != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                company.logo!.startsWith('http')
                                    ? company.logo!
                                    : 'http://10.0.2.2:3000/${company.logo}',
                                width: double.infinity,
                                height: 20.h,
                                fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: double.infinity,
                                    height: 20.h,
                                    color: Colors.grey[300],
                                    child: Icon(Icons.business, size: 10.h, color: Colors.white),
                                  ),
                              ),
                            )
                          else
                            Center(
                              child: Icon(
                                Icons.account_circle,
                                size: 30.w,
                                color: Colors.grey[400],
                              ),
                            ),
                          SizedBox(height: 2.w),
                          Text(
                            'Location: ${company.address}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(height: 1.w),
                          Text(
                            'Industry: ${company.industry}',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          SizedBox(height: 1.w),
                          if (company.tagLine != null)
                            Text(
                              'Tagline: ${company.tagLine}',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          SizedBox(height: 1.w),
                          if (company.website != null)
                            Text(
                              'Website: ${company.website}',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Create New Job",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  JobCreationView(companyId: widget.companyId),
                        ),
                      ).then((_) {
                        // Re-fetch posts after coming back
                        ref
                            .read(companyViewModelProvider)
                            .fetchCompanyPosts(widget.companyId);
                      });
                    },
                    child: const Text("Post a job for free"),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    "Create New Post",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextButton(
                    onPressed: (company.id == null || company.id!.isEmpty) ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CreatePostScreen(
                                companyId: company.id!,
                                description: 'We just created our company!',
                              ),
                        ),
                      ).then((_) {
                        // Re-fetch posts after coming back
                        ref
                            .read(companyViewModelProvider)
                            .fetchCompanyPosts(widget.companyId);
                      });
                    },
                    child: const Text("What do you want to talk about?"),
                  ),

                  Text(
                    "Recent Posts",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...posts.map((post) {
                    print("post description: ${post.description}, post time ago: ${post.createdAt}");
                    return PostCard(post: post, companyLogoUrl: company.logo);
                  }),

                  Text(
                    "Recent Jobs",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...jobs.map((job) {
                    print("job description: ${job.description}, job time ago: ${job.createdAt}");
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetailsScreen(jobId: job.id),
                          ),
                        );
                      },
                      child: JobCard(job: job),
                    );
                  }),
                ],
              ),
    );
  }
}
