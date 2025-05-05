import 'package:flutter/material.dart';
import 'package:lockedin/features/networks/view/message_view.dart';
import 'package:lockedin/features/networks/viewmodel/message_view_model.dart';
import 'package:provider/provider.dart';

class CatchUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MessageRequestViewModel(),
      child: MessageRequestListScreen(),
    );
  }
}
