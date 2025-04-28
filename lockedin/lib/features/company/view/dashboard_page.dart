import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/viewmodel/dashboard_viewmodel.dart';
import 'package:lockedin/features/jobs/view/jobs_page.dart';
import 'package:sizer/sizer.dart'; // <--- make sure you have sizer
import '../widgets/action_card.dart';
import '../widgets/post_card.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(dashboardViewModelProvider);
    final posts = viewModel.getPosts();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 12.w,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 6.w),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const JobsPage()),
            );
          },
        ),
        title: Text(
          'TCCD - Career Center',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              _showDashboardOptions(context);
            },
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 6.w,
            ),
            label: Text(
              'Dashboard',
              style: TextStyle(color: Colors.white, fontSize: 15.sp),
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications, size: 6.w),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Text(
              "Today's actions",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          ActionCard(
            title: "Add services to your company page",
            description:
                "Let potential clients know about services from your company page.",
            onTap: () {},
          ),
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Text(
              "Manage recent posts",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          ...posts.map((post) => PostCard(post: post)).toList(),
        ],
      ),
    );
  }

  void _showDashboardOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (context) {
        return ListView(
          padding: EdgeInsets.all(4.w),
          shrinkWrap: true,
          children: [
            _buildOption(context, "Dashboard"),
            _buildOption(context, "Page posts"),
            _buildOption(context, "Analytics"),
            _buildOption(context, "Feed"),
            _buildOption(context, "Activity"),
            _buildOption(context, "Inbox"),
            _buildOption(context, "Edit page"),
            _buildOption(context, "Jobs", isNew: true),
            Divider(thickness: 0.2.h),
            _buildOption(context, "Start a post"),
            _buildOption(context, "View as a member"),
            _buildOption(context, "Share page"),
          ],
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context,
    String title, {
    bool isNew = false,
  }) {
    return ListTile(
      title: Row(
        children: [
          Text(title, style: TextStyle(fontSize: 15.sp)),
          if (isNew)
            Container(
              margin: EdgeInsets.only(left: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius: BorderRadius.circular(3.w),
              ),
              child: Text(
                "NEW",
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title clicked')));
      },
    );
  }
}
