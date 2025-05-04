import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/message_view_model.dart';

class MessageRequestSendButton extends StatefulWidget {
  final String recipientUserId;
  final TextEditingController messageController;
  final Function()? onSent;

  const MessageRequestSendButton({
    Key? key,
    required this.recipientUserId,
    required this.messageController,
    this.onSent,
  }) : super(key: key);

  @override
  State<MessageRequestSendButton> createState() =>
      _MessageRequestSendButtonState();
}

class _MessageRequestSendButtonState extends State<MessageRequestSendButton> {
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MessageRequestViewModel>(
      context,
      listen: false,
    );

    return IconButton(
      icon:
          _isSending
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              )
              : const Icon(Icons.send),
      onPressed:
          _isSending
              ? null
              : () async {
                if (widget.messageController.text.trim().isEmpty) {
                  // Don't send empty messages
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message cannot be empty')),
                  );
                  return;
                }

                setState(() {
                  _isSending = true;
                });

                try {
                  await viewModel.sendRequest(
                    widget.recipientUserId,
                    widget.messageController.text.trim(),
                  );

                  // Clear the message input after sending
                  widget.messageController.clear();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message request sent successfully'),
                    ),
                  );

                  // Call the onSent callback if provided
                  if (widget.onSent != null) {
                    widget.onSent!();
                  }
                } catch (e) {
                  // Error handling is already in the view model,
                  // but we can show a more specific message here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to send message: ${viewModel.error}',
                      ),
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      _isSending = false;
                    });
                  }
                }
              },
    );
  }
}
