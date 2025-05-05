import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/viewmodel/message_view_model.dart';
import 'package:provider/provider.dart';

class CatchUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageRequestViewModel(),
      child: Scaffold(
        appBar: AppBar(title: Text('Catch Up'), centerTitle: true),
        body: Consumer<MessageRequestViewModel>(
          builder: (context, viewModel, child) {
            return Center(child: Text('No new messages yet!'));
          },
        ),
      ),
    );
  }
}
