import 'package:flutter/material.dart';

class JobManagementView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Job Management")),
      body: Center(
        child: Text("Here you can manage jobs and flagged listings"),
      ),
    );
  }
}
