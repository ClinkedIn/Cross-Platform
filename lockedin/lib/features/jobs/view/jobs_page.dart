import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/view/create_company_view.dart';
import 'package:lockedin/features/company/view/dashboard_page.dart';
import 'package:lockedin/features/jobs/view/saved_jobs_page.dart';
import 'package:lockedin/features/jobs/viewmodel/job_view_model.dart';
import 'package:lockedin/features/jobs/widgets/job_filter.widget.dart';
import 'package:sizer/sizer.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/job_card_widget.dart';

/// A page displaying a list of jobs with filters and search functionality.
class JobsPage extends ConsumerWidget {
  /// Creates a [JobsPage] widget.
  const JobsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobViewModel = ref.watch(JobViewModel.provider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Find your next opportunity',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 18.sp,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardPage(),
                      ),
                    );
                  },
                  child: const Text('Create Company'),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.bookmark),
                tooltip: 'Saved Jobs',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedJobsPage()),
                  );
                },
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  /// Search bar for job titles or keywords.
                  SearchBarWidget(
                    hintText: 'Search for jobs...',
                    onChanged: (value) {
                      jobViewModel.updateSearchQuery(value);
                    },
                  ),
                  SizedBox(height: 2.h),

                  /// Filters for location, industry, company, and experience.
                  JobFiltersWidget(
                    locations:
                        jobViewModel.jobs
                            .map((job) => job.location)
                            .toSet()
                            .toList(),
                    industries:
                        jobViewModel.jobs
                            .map((job) => job.industry)
                            .whereType<String>()
                            .toSet()
                            .toList(),
                    companies:
                        jobViewModel.jobs
                            .map((job) => job.company)
                            .toSet()
                            .toList(),
                    experienceLevels: ['Entry-Level', 'Mid-Level', 'Senior'],
                    selectedLocation: jobViewModel.selectedLocation,
                    selectedIndustry: jobViewModel.selectedIndustry,
                    selectedCompany: jobViewModel.selectedCompanyId,
                    selectedExperienceLevel: jobViewModel.minExperience,
                    onFiltersChanged: (
                      location,
                      industry,
                      company,
                      experience,
                    ) {
                      jobViewModel.updateFilters(
                        location: location,
                        industry: industry,
                        companyId: company,
                        minExperience: experience,
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),

            /// Job list or empty state.
            Expanded(
              child:
                  jobViewModel.jobs.isNotEmpty
                      ? ListView.separated(
                        itemCount: jobViewModel.jobs.length,
                        separatorBuilder: (_, __) => SizedBox(height: 2.h),
                        itemBuilder: (context, index) {
                          final job = jobViewModel.jobs[index];
                          return JobCardWidget(job: job);
                        },
                      )
                      : Center(
                        child: Text(
                          'No jobs found.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
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
