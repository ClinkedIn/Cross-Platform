import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import '../viewmodel/message_view_model.dart';

class Connection extends StatelessWidget {
  final ImageProvider profileImage;
  final String firstName;
  final String lastName;
  final String lastJobTitle;
  final VoidCallback onNameTap;
  final VoidCallback? onRemove;
  final String userId; // Add userId to identify the connection

  const Connection({
    required this.profileImage,
    required this.firstName,
    required this.lastName,
    required this.lastJobTitle,
    required this.onNameTap,
    required this.userId, // Make userId required
    this.onRemove,
    super.key,
  });

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

  // Show message request status dialog
  void _showMessageSentConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message Request Sent'),
          content: Text(
            'Your message request has been sent to ${firstName} ${lastName}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Show error dialog when message request fails
  void _showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get access to the MessageRequestViewModel
    final messageRequestViewModel = Provider.of<MessageRequestViewModel>(context, listen: false);

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
          itemBuilder: (context) => [
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
        // Updated message button with proper handling
        IconButton(
          onPressed: () async {
            try {
              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Sending message request...'),
                  duration: Duration(seconds: 1),
                ),
              );
              
              // Send the message request
              await messageRequestViewModel.sendRequest(userId);
              
              // Show success dialog
              _showMessageSentConfirmation(context);
            } catch (e) {
              // Show error dialog
              _showErrorDialog(context, 'Failed to send message request: $e');
            }
          }, 
          icon: Icon(Icons.send),
          tooltip: 'Send message request',
        ),
      ],
    );
  }
}