import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../model/message_request_model.dart';
import '../viewmodel/message_view_model.dart';

class MessageRequestItem extends StatelessWidget {
  final MessageRequest request;
  final bool showActions;

  const MessageRequestItem({
    Key? key,
    required this.request,
    this.showActions = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(request.senderAvatar),
                  radius: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        timeago.format(request.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (!showActions && request.status != RequestStatus.pending)
                  _buildStatusChip(),
              ],
            ),
            const SizedBox(height: 12),
            Text(request.message),
            if (showActions && request.status == RequestStatus.pending)
              _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    final isAccepted = request.status == RequestStatus.accepted;

    return Chip(
      label: Text(isAccepted ? 'Accepted' : 'Declined'),
      backgroundColor: isAccepted ? Colors.green[100] : Colors.red[100],
      labelStyle: TextStyle(
        color: isAccepted ? Colors.green[700] : Colors.red[700],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final viewModel = Provider.of<MessageRequestViewModel>(
      context,
      listen: false,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => viewModel.declineRequest(request.id),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.blue),
            child: const Text('Decline'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => viewModel.acceptRequest(request.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }
}
