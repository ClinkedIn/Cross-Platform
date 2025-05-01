import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../repository/report_repository.dart';

class ReportViewModel extends ChangeNotifier {
  final _repo = ReportRepository();
  List<Report> reports = [];
  String selectedStatus = "All";

  bool isLoading = true;

  List<Report> get filteredReports {
    if (selectedStatus == "All") return reports;
    return reports
        .where(
          (r) => r.report.status?.toLowerCase() == selectedStatus.toLowerCase(),
        )
        .toList();
  }

  Future<void> loadReports() async {
    isLoading = true;
    notifyListeners();
    try {
      reports = await _repo.fetchReports();
    } catch (e) {
      print("Error loading reports: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String status) {
    selectedStatus = status;
    notifyListeners();
  }

  Future<String> takeActionOnReport(
    String id,
    String action,
    String reason,
  ) async {
    final String message = "Action taken on report";
    isLoading = true;
    notifyListeners();
    try {
      await _repo.takeActionOnReport(id, action, reason);
    } catch (e) {
      print("Error taking action on report: $e");
      return "Error taking action on report";
    } finally {
      loadReports();
      isLoading = false;
      notifyListeners();
      return message;
    }
  }

  Future<String> dismissReport(String id) async {
    final String message = "Report dismissed";
    try {
      await _repo.dismissReport(id);
    } catch (e) {
      print("Error loading reports: $e");
      return "Error dismissing report";
    } finally {
      loadReports();
      isLoading = false;
      notifyListeners();
      return message;
    }
  }
}
