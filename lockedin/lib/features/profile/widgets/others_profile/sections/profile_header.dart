import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/repository/other_profile_repository.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final Map<String, bool> connectionStatus;

  const ProfileHeader({
    Key? key,
    required this.user,
    required this.connectionStatus,
  }) : super(key: key);

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
            '${user.firstName} ${user.lastName}',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (user.headline != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                user.headline!,
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          if (user.location != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 16, color: theme.hintColor),
                  const SizedBox(width: 4),
                  Text(
                    user.location!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
          if (connectionStatus["connected"] == false &&
              connectionStatus["sentConnectionRequest"] == false &&
              connectionStatus["pending"] == false)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  OtherProfileRepository().sendConnectionRequest(user.id).then((
                    result,
                  ) {
                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connection request sent'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to send request')),
                      );
                    }
                  });
                },
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
          if (connectionStatus["pending"] == true)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  OtherProfileRepository().sendFollowRequest(user.id).then((
                    result,
                  ) {
                    if (result) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connection request sent'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to send request')),
                      );
                    }
                  });
                },
                icon: const Icon(Icons.pending_actions),
                label: const Text('pening'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          if (connectionStatus["sentConnectionRequest"] == true)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      OtherProfileRepository()
                          .handleConnectionRequest(user.id, "accept")
                          .then((result) {
                            if (result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Connection request accepted'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to accept request'),
                                ),
                              );
                            }
                          });
                    },
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
                    onPressed: () {
                      OtherProfileRepository()
                          .handleConnectionRequest(user.id, "reject")
                          .then((result) {
                            if (result) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Connection request rejected'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to reject request'),
                                ),
                              );
                            }
                          });
                    },
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
            ),

          if (connectionStatus["connected"] == true)
            // Already connected button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showDisconnectConfirmation(context, user);
                },
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
          if (connectionStatus["connected"] == true)
            // Message button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Message feature coming soon'),
                    ),
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
      ),
    );
  }

  // Add this method inside the ProfileHeader class
  void _showDisconnectConfirmation(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Disconnect Connection'),
          content: Text(
            'Are you sure you want to disconnect ${user.firstName} ${user.lastName}? '
            'This will remove them from your connections list.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.black),

              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.pop();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                OtherProfileRepository().unConnectUser(user.id).then((result) {
                  if (result) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully disconnected'),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to disconnect')),
                    );
                  }
                });
              },
              child: const Text('DISCONNECT'),
            ),
          ],
        );
      },
    );
  }
}
