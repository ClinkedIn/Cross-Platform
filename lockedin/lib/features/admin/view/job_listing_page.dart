import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lockedin/features/admin/viewModel/job_listing_viewmodel.dart';
import 'package:lockedin/features/admin/repository/admin_repository.dart';

enum JobFilter { all, active, inactive }

class AllJobsPage extends StatefulWidget {
  @override
  _AllJobsPageState createState() => _AllJobsPageState();
}

class _AllJobsPageState extends State<AllJobsPage> {
  JobFilter _currentFilter = JobFilter.all;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) => AllJobsViewModel(repository: AdminRepository())..loadJobs(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Jobs Management'), elevation: 0),
        body: Consumer<AllJobsViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (vm.error != null) {
              return Center(child: Text('Error: ${vm.error}'));
            } else if (vm.jobs.isEmpty) {
              return const Center(child: Text('No jobs found.'));
            }

            // Filter jobs based on current selection
            final filteredJobs = _filterJobs(vm.jobs, _currentFilter);

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.05),
                    Colors.white,
                  ],
                ),
              ),
              child: Column(
                children: [
                  _buildFilterHeader(context),
                  _buildJobStats(vm),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredJobs.length,
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (context, index) {
                        final job = filteredJobs[index];
                        return _buildJobCard(context, job, vm);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Jobs',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _filterChip(JobFilter.all, 'All Jobs'),
              _filterChip(JobFilter.active, 'Active'),
              _filterChip(JobFilter.inactive, 'Inactive'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(JobFilter filter, String label) {
    final isSelected = _currentFilter == filter;

    return FilterChip(
      selected: isSelected,
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      backgroundColor: Colors.white,
      selectedColor: Colors.indigoAccent,
      checkmarkColor: Colors.white,
      onSelected: (selected) {
        setState(() {
          _currentFilter = filter;
        });
      },
    );
  }

  Widget _buildJobStats(AllJobsViewModel vm) {
    final totalJobs = vm.jobs.length;
    final activeJobs = vm.jobs.where((job) => job.isActive == true).length;
    final inactiveJobs = totalJobs - activeJobs;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', totalJobs, Colors.indigo),
          _buildDivider(),
          _buildStatItem('Active', activeJobs, Colors.green),
          _buildDivider(),
          _buildStatItem('Inactive', inactiveJobs, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.withOpacity(0.3));
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildJobCard(BuildContext context, job, AllJobsViewModel vm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color:
              job.isActive == true
                  ? Colors.green.shade200
                  : Colors.amber.shade200,
          width: 1,
        ),
      ),
      color: job.isActive == true ? Colors.green.shade50 : Colors.amber.shade50,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 24,
              child:
                  job.companyLogo != null && job.companyLogo.isNotEmpty
                      ? ClipOval(
                        child: Image.network(
                          job.companyLogo,
                          fit: BoxFit.cover,
                          width: 48,
                          height: 48,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.business,
                              size: 24,
                              color:
                                  job.isActive == true
                                      ? Colors.green.shade700
                                      : Colors.amber.shade700,
                            );
                          },
                        ),
                      )
                      : Icon(
                        Icons.business,
                        size: 24,
                        color:
                            job.isActive == true
                                ? Colors.green.shade700
                                : Colors.amber.shade700,
                      ),
            ),
            title: Text(
              job.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${job.companyName}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 10,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.jobLocation,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.work_outline,
                      size: 14,
                      color: Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.jobType,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing:
                (job.isActive == true)
                    ? Chip(
                      label: Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: Colors.green.shade100,
                    )
                    : Chip(
                      label: Text(
                        'Inactive',
                        style: TextStyle(
                          color: Colors.amber.shade700,
                          fontSize: 12,
                        ),
                      ),
                      backgroundColor: Colors.amber.shade100,
                    ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Chip(
                  label: Text(
                    job.workplaceType,
                    style: TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.white,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(job.industry, style: TextStyle(fontSize: 12)),
                  backgroundColor: Colors.white,
                ),
                const Spacer(),
                Text(
                  '${job.applicants} Applicants',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          ButtonBar(
            alignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton.icon(
                icon: Icon(
                  Icons.toggle_on,
                  color: job.isActive == true ? Colors.grey : Colors.green,
                ),
                label: Text(
                  job.isActive == true ? 'Deactivate' : 'Activate',
                  style: TextStyle(
                    color: job.isActive == true ? Colors.grey : Colors.green,
                  ),
                ),
                onPressed: () {
                  // Implement toggle active status functionality
                  _showConfirmDialog(
                    context,
                    'Change Job Status',
                    'Are you sure you want to ${job.isActive == true ? "deactivate" : "activate"} this job?',
                    () {
                      vm.toggleJobStatus(job.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Job ${job.isActive == true ? "deactivated" : "activated"}',
                          ),
                          backgroundColor:
                              job.isActive == true
                                  ? Colors.amber
                                  : Colors.green,
                        ),
                      );
                    },
                  );
                },
              ),

              TextButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  _showConfirmDialog(
                    context,
                    'Delete Job',
                    'Are you sure you want to delete this job? This action cannot be undone.',
                    () async {
                      await vm.deleteJob(job.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Job deleted successfully'),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.red,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    Function onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );
  }

  List _filterJobs(jobs, JobFilter filter) {
    switch (filter) {
      case JobFilter.active:
        return jobs.where((job) => job.isActive == true).toList();
      case JobFilter.inactive:
        return jobs.where((job) => job.isActive == false).toList();
      case JobFilter.all:
        return jobs;
    }
  }
}
