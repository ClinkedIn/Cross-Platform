import 'package:flutter/material.dart';
import 'package:lockedin/features/admin/repository/admin_repository.dart';
import 'package:lockedin/features/admin/models/job.dart'; // Adjust the import path as needed

class AllJobsViewModel extends ChangeNotifier {
  final AdminRepository repository;

  List<Job> _jobs = [];
  bool _isLoading = false;
  String? _error;

  AllJobsViewModel({required this.repository});

  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jobsList = await repository.fetchAllJobs();
      _jobs = jobsList;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> deleteJob(String jobId) async {
    const message = "Job deleted successfully";
    try {
      await repository.deleteJob(jobId);
      // Remove the job from the local list
      _jobs.removeWhere((job) => job.id == jobId);
      notifyListeners();
    } catch (e) {
      return "Failed to delete job: ${e.toString()}";
    }
    return message;
  }

  Future<void> toggleJobStatus(String jobId) async {
    try {
      // Find the job in our local list
      final jobIndex = _jobs.indexWhere((job) => job.id == jobId);
      if (jobIndex >= 0) {
        // Get the job and its current status
        final currentJob = _jobs[jobIndex];
        final newStatus = !(currentJob.isActive == true);

        _jobs[jobIndex] = Job(
          id: currentJob.id,
          title: currentJob.title,
          workplaceType: currentJob.workplaceType,
          jobLocation: currentJob.jobLocation,
          jobType: currentJob.jobType,
          industry: currentJob.industry,
          applicants: currentJob.applicants,
          accepted: currentJob.accepted,
          rejected: currentJob.rejected,
          isActive: newStatus,
          companyName: currentJob.companyName,
          companyLogo: currentJob.companyLogo,
        );

        notifyListeners();
      }
    } catch (e) {
      _error = "Failed to update job status: ${e.toString()}";
      notifyListeners();
    }
  }
}
