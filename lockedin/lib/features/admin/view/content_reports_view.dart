import 'package:flutter/material.dart';
import 'package:lockedin/features/admin/viewModel/report_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:lockedin/features/admin/utils/snack_bar.dart';

class ReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ReportViewModel()..loadReports(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Reported Content')),
        body: Consumer<ReportViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.reports.isEmpty) {
              return const Center(child: Text("No reports found."));
            }

            final filteredReports = vm.filteredReports;

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
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Text("Filter: "),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: vm.selectedStatus,
                          items: const [
                            DropdownMenuItem(value: "All", child: Text("All")),
                            DropdownMenuItem(
                              value: "Pending",
                              child: Text("Pending"),
                            ),
                            DropdownMenuItem(
                              value: "Approved",
                              child: Text("Approved"),
                            ),
                            DropdownMenuItem(
                              value: "Rejected",
                              child: Text("Rejected"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) vm.setFilter(value);
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredReports.length,
                      itemBuilder: (context, index) {
                        final report = filteredReports[index];
                        final isUserReport = report.reportedUser != null;
                        final reporter = report.report.user!;
                        final status =
                            report.report.status?.toLowerCase() ?? 'pending';
                        final reason =
                            report.report.reason ?? 'No reason provided';

                        // Determine card color
                        Color cardColor;
                        switch (status) {
                          case 'approved':
                            cardColor = Colors.green.shade50;
                            break;
                          case 'rejected':
                            cardColor = Colors.red.shade50;
                            break;
                          default:
                            cardColor = Colors.white;
                        }

                        return Card(
                          margin: const EdgeInsets.all(8),
                          color: cardColor,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isUserReport
                                      ? 'User Report: ${report.reportedUser!.firstName} ${report.reportedUser!.lastName}'
                                      : 'Post Report: ${report.reportedPost?.description ?? "No description"}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage:
                                          reporter.profilePicture != ""
                                              ? NetworkImage(
                                                reporter.profilePicture,
                                              )
                                              : const AssetImage(
                                                'assets/images/default_profile_photo.png',
                                              ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Reported by: ${reporter.firstName} ${reporter.lastName}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text('Reason: $reason'),
                                Text(
                                  'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            String selectedAction =
                                                status; // default to current status
                                            TextEditingController
                                            reasonController =
                                                TextEditingController(
                                                  text: reason,
                                                );

                                            return AlertDialog(
                                              title: const Text(
                                                'Take Action on Report',
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  DropdownButtonFormField<
                                                    String
                                                  >(
                                                    value: selectedAction,
                                                    items: const [
                                                      DropdownMenuItem(
                                                        value: 'approved',
                                                        child: Text('Approved'),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'rejected',
                                                        child: Text('Rejected'),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: 'pending',
                                                        child: Text('Pending'),
                                                      ),
                                                    ],
                                                    onChanged: (value) {
                                                      if (value != null)
                                                        selectedAction = value;
                                                    },
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Action',
                                                        ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  TextField(
                                                    controller:
                                                        reasonController,
                                                    maxLines: 2,
                                                    decoration:
                                                        const InputDecoration(
                                                          labelText: 'Reason',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    String message = await vm
                                                        .takeActionOnReport(
                                                          report.report.id,
                                                          selectedAction,
                                                          reasonController.text,
                                                        );
                                                    CustomSnackBar()
                                                        .showSnackBar(
                                                          context,
                                                          message,
                                                        );
                                                    Navigator.of(context).pop();
                                                    await vm.loadReports();
                                                  },
                                                  child: const Text('Submit'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Text('Take Action'),
                                    ),

                                    const SizedBox(width: 10),
                                    OutlinedButton(
                                      onPressed: () async {
                                        final message = await vm.dismissReport(
                                          report.report.id,
                                        );
                                        CustomSnackBar().showSnackBar(
                                          context,
                                          message,
                                        );
                                        await vm
                                            .loadReports(); // optional await to ensure updated state
                                      },
                                      child: const Text('Dismiss'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
