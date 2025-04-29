import 'package:flutter/material.dart';

class ContentReportsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inappropriate Reports")),
      body: Center(
        child: Text("Here you can monitor and review reported content"),
      ),
    );
  }
}
