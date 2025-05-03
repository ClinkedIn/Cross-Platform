import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/utils/constants.dart';
import 'package:lockedin/features/company/view/create_post_screen.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';

class CompanyAnalyticsScreen extends StatefulWidget {
  final String companyId;

  const CompanyAnalyticsScreen({super.key, required this.companyId});

  @override
  State<CompanyAnalyticsScreen> createState() => _CompanyAnalyticsScreenState();
}

class _CompanyAnalyticsScreenState extends State<CompanyAnalyticsScreen> {
  String selectedTab = "Content";
  DateTime startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime endDate = DateTime.now();
  String interval = 'day';

  int totalVisitors = 0;
  int totalFollowers = 0;
  bool isLoading = false;
  List<dynamic> followers = [];

  @override
  void initState() {
    super.initState();
    fetchCompanyAnalytics();
  }

  Future<void> fetchCompanyAnalytics() async {
    setState(() => isLoading = true);

    final formatter = DateFormat('yyyy-MM-dd');
    final start = formatter.format(startDate);
    final end = formatter.format(endDate);

    final endpoint = Constants.getCompanyAnalyticsEndpointFormatted(
      companyId: widget.companyId,
      startDate: start,
      endDate: end,
      interval: interval,
    );

    try {
      final response = await RequestService.get(endpoint);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final visitors = data['analytics']['summary']['totalVisitors'];
        final followersCount = data['analytics']['summary']['totalFollowers'];

        setState(() {
          totalVisitors = visitors;
          totalFollowers = followersCount;
          isLoading = false;
        });
        print('Follorefefwrefre: ${isLoading}');
      } else {
        setState(() => isLoading = false);
      }
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchFollowers() async {
    setState(() => isLoading = true);
    print('Fetching followers for company ID: ${widget.companyId}');

    final response = await RequestService.get(
      '/companies/${widget.companyId}/follow',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Follodhkwebfbewers data: ${data['followers']}');

      setState(() {
        followers = data['followers'];
        totalFollowers = followers.length;
        isLoading = false;
      });

      print('Follorefefwrhhefre: $isLoading');

      if (followers.isEmpty)
        print('No followers found');
      else
        print('First follower: ${followers.first}');
    } else {
      setState(() => isLoading = false);
      print('Failed to fetch followers: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Analytics"),
          bottom: TabBar(
            onTap: (index) async {
              final newTab = index == 0 ? "Content" : "Followers";
              setState(() => selectedTab = newTab);
              if (newTab == "Content") {
                await fetchCompanyAnalytics();
              } else {
                await fetchFollowers();
              }
            },
            tabs: const [Tab(text: "Content"), Tab(text: "Followers")],
          ),
        ),
        body:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : selectedTab == "Content"
                ? buildContentTab()
                : buildFollowersTab(),
      ),
    );
  }

  Widget buildContentTab() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildDateRangePicker(),
          SizedBox(height: 2.h),
          buildIntervalDropdown(),
          SizedBox(height: 2.h),
          Text(
            "Highlights",
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStat("Visitors", totalVisitors),
              buildStat("Followers", totalFollowers),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFollowersTab() {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: ListView(
        children: [
          Text(
            "Follower Highlights",
            style: TextStyle(
              fontSize: 19.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Total followers: $totalFollowers",
            style: TextStyle(fontSize: 18.sp, color: Colors.black),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            color: Colors.yellow[100],
            child: Row(
              children: [
                Icon(Icons.campaign, color: Colors.orange),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    "Grow your audience. Pages that post at least once a week see 5x more followers.",
                    style: TextStyle(fontSize: 15.sp, color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/post");
                  },
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CreatePostScreen(
                                companyId: widget.companyId,
                                description: "", // or any default you want
                              ),
                        ),
                      );
                    },
                    child: Text(
                      "Start a post",
                      style: TextStyle(fontSize: 17.sp, color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            "Followers",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 1.h),
          ...followers.map((follower) {
            final String? firstName = follower['firstName'];
            final String? lastName = follower['lastName'];
            final String? profilePicture = follower['profilePicture'];
            final String? bio = follower['bio'];
            final String? industry = follower['industry'];
            final String followedAt = follower['followedAt'];

            // Skip followers with no profile info
            if (firstName == null || profilePicture == null) return SizedBox();

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(profilePicture),
              ),
              title: Text(
                "$firstName $lastName",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "${bio ?? 'No bio'}, ${industry ?? 'No industry'}",
                style: TextStyle(fontSize: 14.sp, color: Colors.black),
              ),
              trailing: Text(
                DateFormat.yMMMd().format(DateTime.parse(followedAt)),
                style: TextStyle(fontSize: 15.sp, color: Colors.black),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget buildStat(String label, int count) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 14.sp)),
      ],
    );
  }

  Widget buildDateRangePicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${DateFormat("MMM d, yyyy").format(startDate)} - ${DateFormat("MMM d, yyyy").format(endDate)}",
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
        ),
        ElevatedButton(
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2023, 1, 1),
              lastDate: DateTime.now(),
              initialDateRange: DateTimeRange(start: startDate, end: endDate),
            );
            if (picked != null) {
              setState(() {
                startDate = picked.start;
                endDate = picked.end;
              });
              await fetchCompanyAnalytics();
            }
          },
          child: const Text("Update"),
        ),
      ],
    );
  }

  Widget buildIntervalDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Interval:",
          style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold),
        ),
        DropdownButton<String>(
          value: interval,
          items:
              ['day', 'week', 'month'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value[0].toUpperCase() + value.substring(1)),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                interval = newValue;
              });
              fetchCompanyAnalytics();
            }
          },
        ),
      ],
    );
  }
}
