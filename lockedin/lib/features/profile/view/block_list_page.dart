import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/viewmodel/blocked_users_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';

class BlockedUsersPage extends ConsumerStatefulWidget {
  const BlockedUsersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends ConsumerState<BlockedUsersPage> {
  @override
  void initState() {
    super.initState();
    // Fetch blocked users when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blockedUsersViewModelProvider.notifier).fetchBlockedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blockedUsersViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Blocked Users',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(BlockedUsersState state, ThemeData theme) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red[700],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(blockedUsersViewModelProvider.notifier)
                    .fetchBlockedUsers();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state.blockedUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.block, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text('No Blocked Users', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'You haven\'t blocked any users yet.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: state.blockedUsers.length,
      itemBuilder: (context, index) {
        final user = state.blockedUsers[index];
        return _buildUserListTile(user, theme);
      },
    );
  }

  Widget _buildUserListTile(Map<String, dynamic> user, ThemeData theme) {
    final userId = user['_id'] as String;
    final firstName = user['firstName'] as String? ?? 'Unknown';
    final lastName = user['lastName'] as String? ?? 'User';
    final profilePicture = user['profilePicture'] as String?;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.gray,
        backgroundImage:
            profilePicture != null ? NetworkImage(profilePicture) : null,
        child:
            profilePicture == null
                ? Text(
                  firstName[0].toUpperCase(),
                  style: TextStyle(color: Colors.white),
                )
                : null,
      ),
      title: Text('$firstName $lastName'),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.secondary,
          side: BorderSide(color: AppColors.secondary),
        ),
        onPressed: () {
          _showUnblockConfirmationDialog(
            context,
            userId,
            '$firstName $lastName',
          );
        },
        child: const Text('Unblock'),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Future<void> _showUnblockConfirmationDialog(
    BuildContext context,
    String userId,
    String userName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Unblock User'),
            content: Text('Are you sure you want to unblock $userName?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Unblock'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(blockedUsersViewModelProvider.notifier)
          .unblockUser(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$userName has been unblocked'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
