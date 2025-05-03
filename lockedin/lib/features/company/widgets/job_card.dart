import 'package:flutter/material.dart';
import 'package:lockedin/features/company/model/company_job_model.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class JobCard extends StatelessWidget {
  final CompanyJob job;

  const JobCard({required this.job, Key? key}) : super(key: key);

  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return DateFormat.yMMMEd().format(date);
    } else if (date is String) {
      final parsed = DateTime.tryParse(date);
      if (parsed != null) return DateFormat.yMMMEd().format(parsed);
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.work, size: 22),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job.description ?? '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                Chip(label: Text("Type: ${job.jobType}")),
                Chip(label: Text("Workplace: ${job.workplaceType}")),
                Chip(label: Text("Location: ${job.jobLocation}")),
              ],
            ),
            SizedBox(height: 12),
            Text("Email to apply:", style: TextStyle(fontWeight: FontWeight.w500)),
            Text(job.applicationEmail, style: TextStyle(color: Colors.blue)),
            if (job.screeningQuestions != null && job.screeningQuestions.isNotEmpty) ...[
              SizedBox(height: 16),
              Text("Screening Questions:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              ...List.generate(job.screeningQuestions.length, (index) {
                final question = job.screeningQuestions[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Row(
                    children: [
                      Icon(
                        question['mustHave'] == true ? Icons.check_circle : Icons.radio_button_unchecked,
                        size: 18,
                        color: question['mustHave'] == true ? Colors.green : Colors.grey,
                      ),
                      SizedBox(width: 8),
                      Expanded(child: Text(question['question'] ?? '', style: TextStyle(fontSize: 14))),
                    ],
                  ),
                );
              }),
            ],
            if (job.autoRejectMustHave == true) ...[
              SizedBox(height: 12),
              Text("Auto reject is enabled", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
            ],
            if (job.rejectPreview != null && job.rejectPreview.toString().isNotEmpty) ...[
              SizedBox(height: 6),
              Text("Rejection Message:", style: TextStyle(fontWeight: FontWeight.w500)),
              Text(job.rejectPreview!, style: TextStyle(fontStyle: FontStyle.italic)),
            ],
            Divider(height: 24, thickness: 1.2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Applicants: ${job.applicants?.length ?? 0}"),
                Text("Accepted: ${job.accepted?.length ?? 0}"),
                Text("Rejected: ${job.rejected?.length ?? 0}"),
              ],
            ),
            SizedBox(height: 12),
            Text("Created: ${_formatDate(job.createdAt)}"),
            Text("Updated: ${_formatDate(job.updatedAt)}"),
          ],
        ),
      ),
    );
  }
}
