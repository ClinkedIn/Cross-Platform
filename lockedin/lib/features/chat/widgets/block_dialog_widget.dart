import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/chat/viewModel/chat_conversation_viewmodel.dart';

class BlockDialogWidget extends ConsumerWidget {
  final String chatId;
  final bool isBlocked;
  
  const BlockDialogWidget({
    Key? key,
    required this.chatId,
    required this.isBlocked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: Text(isBlocked ? 'Unblock User' : 'Block User'),
      content: Text(
        isBlocked
            ? 'Would you like to unblock this user? They will be able to send you messages again.'
            : 'Would you like to block this user? You won\'t receive any more messages from them.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            // Update the UI state immediately before API call
            // This provides instant feedback to the user
            final viewModel = ref.read(chatConversationProvider(chatId).notifier);
            
            // Optimistically update the state
            viewModel.setBlockedState(!isBlocked);
            
            // Close the dialog first
            Navigator.pop(context);
            
            // Call the API to toggle block user
            final result = await viewModel.toggleBlockUser();
            
            if (result['success'] == true) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isBlocked
                        ? 'User has been unblocked'
                        : 'User has been blocked',
                  ),
                  backgroundColor: isBlocked ? Colors.green : Colors.red,
                ),
              );
            } else {
              // Show error message and revert UI state
              viewModel.setBlockedState(isBlocked); // Revert to original state
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${result['error']}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Text(
            isBlocked ? 'Unblock' : 'Block',
            style: TextStyle(
              color: isBlocked ? Colors.green : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}