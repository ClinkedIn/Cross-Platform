import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:sizer/sizer.dart';

class Connection extends StatelessWidget {
  final ImageProvider profileImage;
  final String firstName;
  final String lastName;
  final String lastJobTitle;
  final VoidCallback onNameTap;
  final VoidCallback? onRemove; // Added callback for removal action

  const Connection({
    required this.profileImage,
    required this.firstName,
    required this.lastName,
    required this.lastJobTitle,
    required this.onNameTap,
    this.onRemove,
    super.key,
  });

  get profilePicture => null;

  // Show confirmation dialog for removal
  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Connection'),
          content: Text(
            'Are you sure you want to remove ${firstName} ${lastName} from your connections?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel action
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                if (onRemove != null) {
                  onRemove!(); // Execute removal callback
                }
              },
              child: Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: profileImage,
        ),
        SizedBox(width: 1.5.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onNameTap,
                child: Text(
                  '${firstName} ${lastName}',
                  style: TextStyle(
                    fontSize: 16.px,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(lastJobTitle),
            ],
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'remove') {
              _showRemoveConfirmation(context);
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem<String>(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, color: Colors.red[500]),
                      SizedBox(width: 8),
                      Text('Remove connection'),
                    ],
                  ),
                ),
              ],
        ),
        IconButton(onPressed: () {}, icon: Icon(Icons.send)),
      ],
    );
  }
}
