import 'package:flutter/material.dart';
import 'package:lockedin/features/admin/repository/admin_repository.dart';

class AdminDashboardViewModel extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  Map<String, dynamic>? dashboardData;
  bool isLoading = true;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    dashboardData = await _repository.fetchDashboardStats();
    print("Dashboard Data📝: $dashboardData");
    if (dashboardData == null) {
      // Handle the case where no data is returned
      print("No data found");
      return;
    }

    isLoading = false;
    notifyListeners();
  }

  dynamic get userStats => dashboardData?['userStats'];
  dynamic get postStats => dashboardData?['postStats'];
  dynamic get jobStats => dashboardData?['jobStats'];
  dynamic get companyStats => dashboardData?['companyStats'];
}
