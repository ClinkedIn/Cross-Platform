import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/admin/widgets/charts/bar_chart_card.dart';
import 'package:provider/provider.dart';
import 'package:lockedin/features/admin/viewModel/admin_viewmodel.dart';
import 'package:lockedin/features/admin/widgets/dashboard_header.dart';
import 'package:lockedin/features/admin/widgets/section_title.dart';
import 'package:lockedin/features/admin/widgets/stat_card/stat_card.dart';
import 'package:lockedin/features/admin/widgets/charts/donut_chart_card.dart';
import 'package:lockedin/features/admin/widgets/utils/chart_utils.dart';

class AdminDashboardView extends StatelessWidget {
  final _userColor = Colors.blue;
  final _postColor = Colors.green;
  final _jobColor = Colors.purple;
  final _companyColor = Colors.brown;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardViewModel()..loadDashboard(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
          elevation: 0,

          actions: [
            IconButton(
              icon: Icon(Icons.logout_outlined),
              onPressed: () {
                _handleLogout(context);
              },
            ),
          ],
        ),
        body: Consumer<AdminDashboardViewModel>(
          builder: (context, viewModel, _) {
            if (viewModel.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading dashboard data...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            final userStats = viewModel.userStats;
            final postStats = viewModel.postStats;
            final jobStats = viewModel.jobStats;
            final companyStats = viewModel.companyStats;

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard header
                    DashboardHeader(),
                    SizedBox(height: 20),

                    // Summary Cards Row
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // For very small screens, use a 2x2 grid
                          if (constraints.maxWidth < 500) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    _buildSummaryCard(
                                      context,
                                      "Users",
                                      "${userStats['totalUsers']}",
                                      Icons.people_alt_rounded,
                                      _userColor,
                                    ),
                                    SizedBox(width: 12),
                                    _buildSummaryCard(
                                      context,
                                      "Posts",
                                      "${postStats['totalPosts']}",
                                      Icons.post_add_rounded,
                                      _postColor,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    _buildSummaryCard(
                                      context,
                                      "Jobs",
                                      "${jobStats['totalJobs']}",
                                      Icons.work_rounded,
                                      _jobColor,
                                    ),
                                    SizedBox(width: 12),
                                    _buildSummaryCard(
                                      context,
                                      "Companies",
                                      "${companyStats['totalCompanies']}",
                                      Icons.business_rounded,
                                      _companyColor,
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            // For larger screens, use one row
                            return Row(
                              children: [
                                _buildSummaryCard(
                                  context,
                                  "Users",
                                  "${userStats['totalUsers']}",
                                  Icons.people_alt_rounded,
                                  _userColor,
                                ),
                                SizedBox(width: 12),
                                _buildSummaryCard(
                                  context,
                                  "Posts",
                                  "${postStats['totalPosts']}",
                                  Icons.post_add_rounded,
                                  _postColor,
                                ),
                                SizedBox(width: 12),
                                _buildSummaryCard(
                                  context,
                                  "Jobs",
                                  "${jobStats['totalJobs']}",
                                  Icons.work_rounded,
                                  _jobColor,
                                ),
                                SizedBox(width: 12),
                                _buildSummaryCard(
                                  context,
                                  "Companies",
                                  "${companyStats['totalCompanies']}",
                                  Icons.business_rounded,
                                  _companyColor,
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),

                    // User Stats Section
                    SectionTitle(title: "👥 User Statistics"),
                    StatCardGrid(
                      stats: [
                        {
                          'title': 'Total Users',
                          'value': userStats['totalUsers'].toString(),
                          'icon': Icons.people,
                          'color': Colors.blue,
                        },
                        {
                          'title': 'Active Users',
                          'value': userStats['activeUsers'].toString(),
                          'icon': Icons.person_outline,
                          'color': Colors.green,
                        },
                        {
                          'title': 'Premium Users',
                          'value': userStats['premiumUsers'].toString(),
                          'icon': Icons.workspace_premium,
                          'color': Colors.amber,
                        },
                        {
                          'title': 'Avg Connections',
                          'value': userStats['averageConnections'].toString(),
                          'icon': Icons.handshake,
                          'color': Colors.deepPurple,
                        },
                      ],
                    ),
                    SizedBox(height: 24),

                    // User Privacy Donut Chart
                    DonutChartCard(
                      title: "User Profile Privacy",
                      data: userStats['usersByProfilePrivacy'],
                      colors: [
                        Colors.blueGrey[100] ?? Colors.blueGrey,
                        Colors.blueGrey[400] ?? Colors.blueGrey,
                        Colors.blueGrey[700] ?? Colors.blueGrey,
                      ],
                    ),
                    SizedBox(height: 24),

                    // Add User Default Mode Chart
                    DonutChartCard(
                      title: "User Theme Preference",
                      data: userStats['usersByDefaultMode'],
                      colors: [Colors.grey[100] ?? Colors.grey, Colors.black],
                      subtitle: "Light vs Dark mode distribution",
                    ),
                    SizedBox(height: 24),

                    // Add Connection Request Privacy Chart
                    DonutChartCard(
                      title: "Connection Request Privacy",
                      data: userStats['usersByConnectionRequestPrivacy'],
                      colors: [
                        Colors.deepPurple[200] ?? Colors.purple,
                        Colors.deepPurple[400] ?? Colors.purple,
                      ],
                      subtitle: "Who can send connection requests",
                    ),
                    SizedBox(height: 24),

                    // Add Employment Type Chart
                    BarChartCard(
                      title: "Employment Types",
                      subtitle: "Distribution of employment types across users",
                      data: userStats['employmentTypeCounts'],
                      gradientColors: [
                        Colors.purple.shade300,
                        Colors.purple.shade700,
                      ],
                    ),
                    SizedBox(height: 32),

                    // Post Stats Section
                    SectionTitle(title: "📝 Post Analytics"),
                    StatCardGrid(
                      stats: [
                        {
                          'title': 'Total Posts',
                          'value': postStats['totalPosts'].toString(),
                          'icon': Icons.post_add,
                          'color': Colors.indigo,
                        },
                        {
                          'title': 'Active Posts',
                          'value': postStats['activePosts'].toString(),
                          'icon': Icons.visibility,
                          'color': Colors.teal,
                        },
                        {
                          'title': 'Total Impressions',
                          'value': ChartUtils.formatNumber(
                            postStats['totalImpressions'],
                          ),
                          'icon': Icons.trending_up,
                          'color': Colors.orange,
                        },
                      ],
                    ),
                    SizedBox(height: 24),

                    // Post Engagement Bar Chart
                    BarChartCard(
                      title: "Average Post Engagement",
                      data: [
                        {
                          '_id': 'Impressions',
                          'count':
                              postStats['averageEngagement']['impressions'],
                        },
                        {
                          '_id': 'Comments',
                          'count': postStats['averageEngagement']['comments'],
                        },
                        {
                          '_id': 'Reposts',
                          'count': postStats['averageEngagement']['reposts'],
                        },
                      ],
                      gradientColors: [Colors.blueAccent, Colors.blue.shade800],
                    ),
                    SizedBox(height: 32),

                    // Job Stats Section
                    SectionTitle(title: "💼 Job Insights"),
                    StatCardGrid(
                      stats: [
                        {
                          'title': 'Total Jobs',
                          'value': jobStats['totalJobs'].toString(),
                          'icon': Icons.work,
                          'color': Colors.purple,
                        },
                        {
                          'title': 'Active Jobs',
                          'value': jobStats['activeJobs'].toString(),
                          'icon': Icons.business_center,
                          'color': Colors.red,
                        },
                        {
                          'title': 'Avg Applications',
                          'value': jobStats['averageApplications'].toString(),
                          'icon': Icons.assignment_turned_in,
                          'color': Colors.cyan,
                        },
                      ],
                    ),
                    SizedBox(height: 24),

                    // Add Job Type Distribution
                    DonutChartCard(
                      title: "Job Types",
                      data: jobStats['jobsByType'],
                      colors: [
                        Colors.blue.shade900,
                        Colors.blue.shade800,
                        Colors.blue.shade700,
                        Colors.blue.shade600,
                        Colors.blue.shade500,
                        Colors.blue.shade400,
                        Colors.blue.shade300,
                      ],
                      subtitle: "Distribution of job posting types",
                    ),
                    SizedBox(height: 24),

                    // Add Workplace Type Chart
                    BarChartCard(
                      title: "Workplace Types",
                      subtitle: "Remote vs hybrid vs onsite distribution",
                      data: jobStats['jobsByWorkplaceType'],
                      gradientColors: [
                        const Color.fromARGB(255, 4, 2, 109),
                        const Color.fromARGB(255, 7, 15, 176),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Company Stats Section
                    SectionTitle(title: "🏢 Company Metrics"),
                    StatCardGrid(
                      stats: [
                        {
                          'title': 'Total Companies',
                          'value': companyStats['totalCompanies'].toString(),
                          'icon': Icons.business,
                          'color': Colors.blueGrey,
                        },
                        {
                          'title': 'Active Companies',
                          'value': companyStats['activeCompanies'].toString(),
                          'icon': Icons.storefront,
                          'color': Colors.brown,
                        },
                        {
                          'title': 'Avg Followers',
                          'value': companyStats['averageFollowers'].toString(),
                          'icon': Icons.groups,
                          'color': Colors.pink,
                        },
                      ],
                    ),
                    SizedBox(height: 24),

                    // Add Company Size Distribution
                    DonutChartCard(
                      title: "Company Sizes",
                      data: companyStats['companiesBySize'],
                      colors: [
                        Colors.blue.shade300,
                        Colors.blue.shade400,
                        Colors.blue.shade500,
                        Colors.blue.shade600,
                        Colors.blue.shade700,
                        Colors.blue.shade800,
                        Colors.blue.shade900,
                      ],
                      subtitle: "Distribution of companies by employee count",
                    ),
                    SizedBox(height: 24),

                    // Add Top Industries Chart (showing only top 10)
                    BarChartCard(
                      title: "Top Industries",
                      subtitle: "Most common company industries",
                      data: _getTopIndustries(
                        companyStats['companiesByIndustry'],
                        10,
                      ),
                      gradientColors: [
                        Colors.brown.shade300,
                        Colors.brown.shade700,
                      ],
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Add this method to filter and get only the top N industries
  List<dynamic> _getTopIndustries(List<dynamic> industries, int topCount) {
    // Filter out nonsensical or placeholder entries like single letters
    final filteredIndustries =
        industries.where((industry) {
          final id = industry['_id'] as String?;
          if (id == null || id.isEmpty) return false;
          if (id.length < 3)
            return false; // Filter out very short industry names
          return true;
        }).toList();

    // Sort by count descending
    filteredIndustries.sort(
      (a, b) => (b['count'] as int).compareTo(a['count'] as int),
    );

    // Return only top N
    return filteredIndustries.take(topCount).toList();
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Icon(icon, size: 40, color: color),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Logout'),
            content: Text(
              'Are you sure you want to log out from admin dashboard?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('LOGOUT', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirm == true) {
      RequestService.post("/user/logout", body: {});
      await TokenService.deleteCookie();
      context.go('/');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logged out successfully')));
    }
  }
}
