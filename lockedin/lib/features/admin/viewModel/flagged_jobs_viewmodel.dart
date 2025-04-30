import 'package:flutter/foundation.dart';
import 'package:lockedin/features/admin/repository/admin_repository.dart';
import '../models/flagged_job.dart';

class FlaggedJobsViewModel extends ChangeNotifier {
  final AdminRepository repository;
  List<FlaggedJob> jobs = [];
  bool isLoading = false;
  String? error;

  FlaggedJobsViewModel({required this.repository});

  Future<void> loadJobs() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      jobs = await repository.fetchFlaggedJobs();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
