import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import './dialogs/block_dialog.dart';
import './dialogs/report_dialog.dart';

class ProfileActionsMenu extends ConsumerWidget {
  final UserModel user;

  const ProfileActionsMenu({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'report') {
          showReportDialog(context, ref, user);
        } else if (value == 'block') {
          showBlockDialog(context, ref, user);
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.flag_outlined, color: Colors.orange),
                  SizedBox(width: 8),
                  Text('Report'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'block',
              child: Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Block'),
                ],
              ),
            ),
          ],
    );
  }
}
