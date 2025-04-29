import 'package:flutter/material.dart';
import 'package:lockedin/features/admin/viewModel/admin_viewmodel.dart';
import 'package:provider/provider.dart';

class AdminDashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel()..loadDashboard(),
      child: Scaffold(
        appBar: AppBar(title: Text('Admin Dashboard')),
        body: Consumer<AdminDashboardViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            final userStats = viewModel.userStats;
            final postStats = viewModel.postStats;
            final jobStats = viewModel.jobStats;
            final companyStats = viewModel.companyStats;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "👥 Users",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text("Total: ${userStats['totalUsers']}"),
                  Text("Active: ${userStats['activeUsers']}"),
                  Text("Premium: ${userStats['premiumUsers']}"),
                  Text("Avg Connections: ${userStats['averageConnections']}"),
                  SizedBox(height: 16),

                  Text(
                    "📝 Posts",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text("Total Posts: ${postStats['totalPosts']}"),
                  Text("Active Posts: ${postStats['activePosts']}"),
                  Text("Impressions: ${postStats['totalImpressions']}"),
                  SizedBox(height: 16),

                  Text(
                    "💼 Jobs",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text("Total Jobs: ${jobStats['totalJobs']}"),
                  Text("Active Jobs: ${jobStats['activeJobs']}"),
                  Text("Avg Applications: ${jobStats['averageApplications']}"),
                  SizedBox(height: 16),

                  Text(
                    "🏢 Companies",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text("Total Companies: ${companyStats['totalCompanies']}"),
                  Text("Active Companies: ${companyStats['activeCompanies']}"),
                  Text("Avg Followers: ${companyStats['averageFollowers']}"),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
