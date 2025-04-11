import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/jobs/viewmodel/job_view_model.dart';
import 'package:lockedin/features/jobs/widgets/job_filter.widget.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:lockedin/shared/theme/text_styles.dart';
import 'package:sizer/sizer.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/job_card_widget.dart';

class JobsPage extends ConsumerWidget {
  const JobsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobViewModel = ref.watch(JobViewModel.provider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 4,
        titleSpacing: 16,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find your next opportunity',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SearchBarWidget(
                    hintText: 'Search for jobs...',
                    onChanged: (value) {
                      jobViewModel.updateSearchQuery(value);
                    },
                  ),
                  SizedBox(height: 2.h),
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
                          style: TextStyle(
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
