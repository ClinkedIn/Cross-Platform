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
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Locked ",
              style: AppTextStyles.headline1.copyWith(
                color: AppColors.primary,
                fontSize: 2.h,
              ),
            ),
            Image.network(
              "https://upload.wikimedia.org/wikipedia/commons/c/ca/LinkedIn_logo_initials.png",
              height: 2.h,
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Navigate to Preferences
            },
            child: const Text(
              'Preferences',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Navigate to My jobs
            },
            child: const Text('My jobs', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Post a free job
            },
            child: const Text(
              'Post a free job',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
              children: [
                Text(
                  'Search for jobs',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                SearchBarWidget(
                  hintText: 'Search for jobs...',
                  onChanged: (value) {
                    jobViewModel.updateSearchQuery(value);
                  },
                ),
                const SizedBox(height: 10),
                JobFiltersWidget(
                  experienceLevels: ['Entry-Level', 'Mid-Level', 'Senior'],
                  companies:
                      jobViewModel.jobs
                          .map((job) => job.company)
                          .toSet()
                          .toList(),
                  salaryRanges:
                      jobViewModel.jobs
                          .map((job) => job.salaryRange)
                          .toSet()
                          .toList(),
                  selectedExperienceLevel: jobViewModel.selectedExperienceLevel,
                  selectedCompany: jobViewModel.selectedCompany,
                  selectedSalaryRange: jobViewModel.selectedSalaryRange,
                  onFiltersChanged: (experience, company, salary) {
                    jobViewModel.updateFilters(
                      experienceLevel: experience,
                      company: company,
                      salaryRange: salary,
                    );
                  },
                ),
              ],
            ),
          ),
          if (jobViewModel.filteredJobs.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: jobViewModel.filteredJobs.length,
                itemBuilder: (context, index) {
                  final job = jobViewModel.filteredJobs[index];
                  return JobCardWidget(job: job);
                },
              ),
            )
          else
            const Expanded(child: Center(child: Text('No jobs found.'))),
        ],
      ),
    );
  }
}
