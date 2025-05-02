import 'package:flutter/material.dart';
import 'package:lockedin/features/company/view/review_job_post_screen.dart';
import 'package:sizer/sizer.dart';

class JobDetailsScreen extends StatefulWidget {
  final String initialJobTitle;
  final String companyId;

  const JobDetailsScreen({super.key, required this.initialJobTitle, required this.companyId,});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  late TextEditingController _jobTitleController;
  final TextEditingController _companyController = TextEditingController(text: "EJADA");
  final TextEditingController _locationController = TextEditingController(text: "Giza, Al Jizah, Egypt");

  String _selectedWorkplaceType = "On-site";
  String _selectedJobType = "Full-time";

  @override
  void initState() {
    super.initState();
    _jobTitleController = TextEditingController(text: widget.initialJobTitle);
  }

  void _selectWorkplaceType() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _buildWorkplaceTypeSheet(),
    );
    if (result != null) {
      setState(() {
        _selectedWorkplaceType = result;
      });
    }
  }

  void _selectJobType() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => _buildJobTypeSheet(),
    );
    if (result != null) {
      setState(() {
        _selectedJobType = result;
      });
    }
  }

  Widget _buildWorkplaceTypeSheet() {
    return _buildRadioBottomSheet(
      title: "Choose the workplace type",
      options: {
        "On-site": "Employees come to work in-person.",
        "Hybrid": "Employees work on-site and off-site.",
        "Remote": "Employees work off-site.",
      },
      selected: _selectedWorkplaceType,
    );
  }

  Widget _buildJobTypeSheet() {
    return _buildRadioBottomSheet(
      title: "Choose the job type",
      options: {
        "Full-time": "",
        "Part-time": "",
        "Contract": "",
        "Temporary": "",
        "Other": "",
        "Volunteer": "",
        "Internship": "",
      },
      selected: _selectedJobType,
    );
  }

  Widget _buildRadioBottomSheet({
    required String title,
    required Map<String, String> options,
    required String selected,
  }) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 2.h),
            ...options.entries.map(
              (entry) => RadioListTile<String>(
                value: entry.key,
                groupValue: selected,
                title: Text(entry.key, style: TextStyle(fontSize: 16.sp)),
                subtitle: entry.value.isNotEmpty
                    ? Text(entry.value, style: TextStyle(fontSize: 14.sp))
                    : null,
                onChanged: (value) {
                  Navigator.pop(context, value);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: Text("Edit job details", style: TextStyle(fontSize: 18.sp)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewJobPostScreen(
                    jobTitle: _jobTitleController.text,
                    company: _companyController.text,
                    location: _locationController.text,
                    jobType: _selectedJobType,
                    workplaceType: _selectedWorkplaceType,
                    companyId: widget.companyId,
                  ),
                ),
              );
            },
            child: Text("Next", style: TextStyle(fontSize: 18.sp)),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldLabel("Job title"),
              TextField(
                controller: _jobTitleController,
                style: TextStyle(fontSize: 17.sp),
                decoration: const InputDecoration(border: UnderlineInputBorder()),
              ),
              SizedBox(height: 3.h),
              _buildFieldLabel("Company"),
              TextField(
                controller: _companyController,
                style: TextStyle(fontSize: 16.sp),
                decoration: const InputDecoration(border: UnderlineInputBorder()),
              ),
              SizedBox(height: 3.h),
              _buildFieldLabel("Workplace type"),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedWorkplaceType, style: TextStyle(fontSize: 17.sp)),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _selectWorkplaceType,
              ),
              Divider(),
              _buildFieldLabel("Job location"),
              TextField(
                controller: _locationController,
                style: TextStyle(fontSize: 16.sp),
                decoration: const InputDecoration(border: UnderlineInputBorder()),
              ),
              SizedBox(height: 3.h),
              _buildFieldLabel("Job type"),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_selectedJobType, style: TextStyle(fontSize: 17.sp)),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: _selectJobType,
              ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600));
  }
}