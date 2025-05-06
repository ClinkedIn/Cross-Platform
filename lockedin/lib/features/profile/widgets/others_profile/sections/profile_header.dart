import 'package:flutter/material.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/repository/other_profile_repository.dart';

class ProfileHeader extends StatefulWidget {
  final UserModel user;
  final Map<String, bool> connectionStatus;
  final VoidCallback onConnectionStatusChanged;

  const ProfileHeader({
    Key? key,
    required this.user,
    required this.connectionStatus,
    required this.onConnectionStatusChanged,
  }) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  // Local state to handle button loading states
  bool _isActionInProgress = false;
  final OtherProfileRepository _repository = OtherProfileRepository();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Name and headline - centered
          Text(
            '${widget.user.firstName} ${widget.user.lastName}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.user.headline != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                widget.user.headline!,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          if (widget.user.location != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 16, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text(
                    widget.user.location!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Connection action buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // Extract connection status values for easier access
    final bool isConnected = widget.connectionStatus["connected"] ?? false;
    final bool isPending = widget.connectionStatus["pending"] ?? false;
    final bool isRequestReceived =
        widget.connectionStatus["sentConnectionRequest"] ?? false;
    final bool isFollowed = widget.connectionStatus["followed"] ?? false;

    // Show loading indicator during any action
    if (_isActionInProgress) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Connect/Follow section
    if (!isConnected && !isPending && !isRequestReceived) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleSendConnectionRequest(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Connect'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          if (!isFollowed)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleFollowRequest(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Follow'), // Fixed capitalization
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // Pending connection request sent
    if (isPending) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _handleRemoveConnectionRequest(context),
          icon: const Icon(Icons.pending_actions),
          label: const Text('Pending'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    // Connection request received
    if (isRequestReceived) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleConnectionRequest(context, "accept"),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Accept'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _handleConnectionRequest(context, "reject"),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showDisconnectConfirmation(context),
            icon: const Icon(Icons.check),
            label: const Text('Connected'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message feature coming soon')),
              );
            },
            icon: const Icon(Icons.message),
            label: const Text('Message'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to handle API requests with loading state and error handling
  Future<void> _performAction(
    BuildContext context,
    Future<bool> Function() action,
    String successMessage,
    String failureMessage,
  ) async {
    try {
      // Set loading state
      setState(() {
        _isActionInProgress = true;
      });

      final result = await action();

      // Update UI on success
      if (result) {
        // Only show success message if we're still mounted
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMessage)));
        }

        // Call the refresh callback right after successful action
        widget.onConnectionStatusChanged();
      } else if (mounted) {
        // Show failure message
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failureMessage)));
      }
    } catch (e) {
      // Show error message if we're still mounted
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      // Ensure we reset loading state if component is still mounted
      if (mounted) {
        setState(() {
          _isActionInProgress = false;
        });
      }
    }
  }

  Future<void> _handleRemoveConnectionRequest(BuildContext context) async {
    await _performAction(
      context,
      () => _repository.unConnectUser(widget.user.id),
      'Connection request removed',
      'Failed to remove request',
    );
  }

  Future<void> _handleSendConnectionRequest(BuildContext context) async {
    await _performAction(
      context,
      () => _repository.sendConnectionRequest(widget.user.id),
      'Connection request sent',
      'Failed to send request',
    );
  }

  Future<void> _handleFollowRequest(BuildContext context) async {
    await _performAction(
      context,
      () => _repository.sendFollowRequest(widget.user.id),
      'Follow request sent',
      'Failed to send follow request',
    );
  }

  Future<void> _handleConnectionRequest(
    BuildContext context,
    String action,
  ) async {
    final String successMessage =
        action == "accept"
            ? 'Connection request accepted'
            : 'Connection request rejected';

    final String failMessage =
        action == "accept"
            ? 'Failed to accept request'
            : 'Failed to reject request';

    await _performAction(
      context,
      () => _repository.handleConnectionRequest(widget.user.id, action),
      successMessage,
      failMessage,
    );
  }

  void _showDisconnectConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Disconnect Connection'),
          content: Text(
            'Are you sure you want to disconnect ${widget.user.firstName} ${widget.user.lastName}? '
            'This will remove them from your connections list.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleDisconnect(context);
              },
              child: const Text('DISCONNECT'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDisconnect(BuildContext context) async {
    await _performAction(
      context,
      () => _repository.unConnectUser(widget.user.id),
      'Successfully disconnected',
      'Failed to disconnect',
    );
  }
}
