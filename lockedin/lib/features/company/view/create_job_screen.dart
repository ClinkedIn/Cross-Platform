import 'package:flutter/material.dart';
import 'package:lockedin/features/company/viewmodel/job_creation_viewmodel.dart';
import 'package:sizer/sizer.dart';

class JobCreationView extends StatefulWidget {
  final String companyId;

  JobCreationView({required this.companyId});

  @override
  _JobCreationViewState createState() => _JobCreationViewState();
}

class _JobCreationViewState extends State<JobCreationView> {
  late JobCreationViewModel viewModel;

  final List<String> screeningQuestionOptions = [
    "Background Check",
    "Driver's License",
    "Drug Test",
    "Education",
    "Expertise with Skill",
    "Hybrid Work",
    "Industry Experience",
    "Language",
    "Location",
    "Onsite Work",
    "Remote Work",
    "Urgent Hiring Need",
    "Visa Status",
    "Work Authorization",
    "Work Experience",
    "Custom Question",
  ];

  @override
  void initState() {
    super.initState();
    viewModel = JobCreationViewModel(widget.companyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Job')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: viewModel.titleController,
              decoration: InputDecoration(labelText: 'Job Title'),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: viewModel.industryController,
              decoration: InputDecoration(labelText: 'Industry'),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: viewModel.jobLocationController,
              decoration: InputDecoration(labelText: 'Job Location'),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: viewModel.descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: viewModel.applicationEmailController,
              decoration: InputDecoration(labelText: 'Application Email'),
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              value: viewModel.workplaceType,
              items: ['Onsite', 'Hybrid', 'Remote']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  viewModel.workplaceType = val!;
                });
              },
              decoration: InputDecoration(labelText: 'Workplace Type'),
            ),
            SizedBox(height: 2.h),
            DropdownButtonFormField<String>(
              value: viewModel.jobType,
              items: ['Full Time', 'Part Time', 'Contract', 'Temporary', 'Other', 'Volunteer', 'Internship']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  viewModel.jobType = val!;
                });
              },
              decoration: InputDecoration(labelText: 'Job Type'),
            ),
            SizedBox(height: 2.h),
            SwitchListTile(
              title: Text('Auto Reject Must Have'),
              value: viewModel.autoRejectMustHave,
              onChanged: (val) {
                setState(() {
                  viewModel.autoRejectMustHave = val;
                });
              },
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: viewModel.rejectPreviewController,
              decoration: InputDecoration(labelText: 'Reject Preview'),
            ),
            SizedBox(height: 2.h),
            Text('Screening Questions', style: TextStyle(fontWeight: FontWeight.bold)),

            if (viewModel.screeningQuestionControllers.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      viewModel.addScreeningQuestion();
                    });
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Screening Question'),
                ),
              )
            else
              ...[
                ...viewModel.screeningQuestionControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  var map = entry.value;
                  return Column(
                    children: [
                      SizedBox(height: 2.h),
                      DropdownButtonFormField<String>(
                        value: screeningQuestionOptions.contains(viewModel.screeningQuestionValues[index])
                            ? viewModel.screeningQuestionValues[index]
                            : null,
                        items: screeningQuestionOptions
                            .map((option) => DropdownMenuItem(value: option, child: Text(option)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            viewModel.screeningQuestionValues[index] = val;
                          });
                        },
                        decoration: InputDecoration(labelText: 'Question'),
                      ),
                      TextField(
                        controller: map['idealAnswer'],
                        decoration: InputDecoration(labelText: 'Ideal Answer'),
                      ),
                      CheckboxListTile(
                        title: Text("Must Have"),
                        value: viewModel.mustHaveValues[index],
                        onChanged: (val) {
                          setState(() {
                            viewModel.mustHaveValues[index] = val ?? false;
                          });
                        },
                      ),
                    ],
                  );
                }).toList(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        viewModel.addScreeningQuestion();
                      });
                    },
                    icon: Icon(Icons.add),
                    label: Text('Add Screening Question'),
                  ),
                ),
              ],

            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => viewModel.submitJob(context),
              child: Text('Submit'),
            )
          ],
        ),
      ),
    );
  }
}

