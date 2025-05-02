import 'package:flutter/material.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:intl/intl.dart';
import 'package:lockedin/core/utils/constants.dart';
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
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();
  String interval = 'day';
  int totalVisitors = 0;
  int totalFollowers = 0;
  bool isLoading = false;

  Future<void> fetchCompanyAnalytics({
    required String companyId,
    required DateTime startDate,
    required DateTime endDate,
    required String interval,
  }) async {
    final formatter = DateFormat('yyyy-MM-dd');
    final start = formatter.format(startDate);
    final end = formatter.format(endDate);
    print("company id inside analytics : $companyId");
    final endpoint = Constants.getCompanyAnalyticsEndpointFormatted(
      companyId: widget.companyId,
      startDate: start,
      endDate: end,
      interval: interval,
    );
    print("📡 job analytics endpoint: $endpoint");
    setState(() => isLoading = true);

    try {
      final response = await RequestService.get(endpoint);
      print("📡 job analytics Response Status: ${response.statusCode}");
      print("📡 Response Body: ${response.body}");
      if (response.statusCode == 200) {
        print("job analytics successfully fetched");
        final data = json.decode(response.body);
        final visitors = data['analytics']['summary']['totalVisitors'];
        final followers = data['analytics']['summary']['totalFollowers'];

        setState(() {
          totalVisitors = visitors;
          totalFollowers = followers;
          isLoading = false;
        });
      } else {
        debugPrint("❌ Error ${response.statusCode}: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompanyAnalytics(
      companyId: widget.companyId,
      startDate: startDate,
      endDate: endDate,
      interval: interval,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Analytics"),
          bottom: TabBar(
            tabs: const [Tab(text: "Content"), Tab(text: "Followers")],
            onTap: (index) {
              setState(
                () => selectedTab = index == 0 ? "Content" : "Followers",
              );
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(4.w),
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${DateFormat("MMM d, yyyy").format(startDate)} - ${DateFormat("MMM d, yyyy").format(endDate)}",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2023, 1, 1),
                                lastDate: DateTime.now(),
                                initialDateRange: DateTimeRange(
                                  start: startDate,
                                  end: endDate,
                                ),
                              );

                              if (picked != null) {
                                setState(() {
                                  startDate = picked.start;
                                  endDate = picked.end;
                                });

                                await fetchCompanyAnalytics(
                                  companyId: widget.companyId,
                                  startDate: picked.start,
                                  endDate: picked.end,
                                  interval: interval,
                                );
                              }
                            },
                            child: const Text("Update"),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Interval:",
                            style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold),
                          ),
                          DropdownButton<String>(
                            value: interval,
                            items: ['day', 'week', 'month'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value[0].toUpperCase() + value.substring(1)), // Capitalize
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  interval = newValue;
                                });

                                fetchCompanyAnalytics(
                                  companyId: widget.companyId,
                                  startDate: startDate,
                                  endDate: endDate,
                                  interval: interval,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),                      
                      Text(
                        "Highlights",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                "$totalVisitors",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Visitors",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "$totalFollowers",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Followers",
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
