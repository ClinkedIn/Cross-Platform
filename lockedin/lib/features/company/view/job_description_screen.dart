import 'package:flutter/material.dart';
import 'package:lockedin/features/company/view/review_job_post_screen.dart';
import 'package:sizer/sizer.dart';

class JobDescriptionScreen extends StatefulWidget {
  final String? initialText;
  final String jobTitle;
  final String company;
  final String location;
  final String jobType;
  final String workplaceType;
  final String companyId;

  const JobDescriptionScreen({
    super.key,
    this.initialText,
    required this.jobTitle,
    required this.company,
    required this.location,
    required this.jobType,
    required this.workplaceType,
    required this.companyId,
  });

  @override
  State<JobDescriptionScreen> createState() => _JobDescriptionScreenState();
}

class _JobDescriptionScreenState extends State<JobDescriptionScreen> {
  late TextEditingController _controller;
  bool isBold = false;
  bool isItalic = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? "");
  }

  void _toggleBold() => setState(() => isBold = !isBold);
  void _toggleItalic() => setState(() => isItalic = !isItalic);

  TextStyle get _textStyle {
    return TextStyle(
      fontSize: 17.sp,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
    );
  }

  void saveAndReturn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewJobPostScreen(
          jobTitle: widget.jobTitle,
          company: widget.company,
          location: widget.location,
          jobType: widget.jobType,
          workplaceType: widget.workplaceType,
          companyId: widget.companyId,
          jobDescription: _controller.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool enableSave = _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Job description", style: TextStyle(fontSize: 18.sp)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: enableSave ? saveAndReturn  : null,
            child: Text(
              "Save",
              style: TextStyle(
                fontSize: 18.sp,
                color: enableSave ? Colors.blue : Colors.grey,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: TextField(
                controller: _controller,
                maxLines: null,
                onChanged: (_) => setState(() {}),
                style: _textStyle,
                decoration: const InputDecoration(border: InputBorder.none),
              ),
            ),
          ),
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.format_bold, color: isBold ? Colors.blue : Colors.black),
                  onPressed: _toggleBold,
                ),
                IconButton(
                  icon: Icon(Icons.format_italic, color: isItalic ? Colors.blue : Colors.black),
                  onPressed: _toggleItalic,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}