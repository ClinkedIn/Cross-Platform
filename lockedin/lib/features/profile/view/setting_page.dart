import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/core/services/request_services.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/profile/repository/update_profile_repository.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';

final privacySettingProvider = StateProvider<String>((ref) {
  // Initialize with the user's current setting or default to 'public'
  final userState = ref.watch(userProvider);
  return userState.valueOrNull?.profilePrivacySettings ?? 'public';
});

final connectionPrivacySettingProvider = StateProvider<String>((ref) {
  // Initialize with the user's current setting or default to 'everyone'
  final userState = ref.watch(userProvider);
  return userState.valueOrNull?.connectionRequestPrivacySetting ?? 'everyone';
});

final updateProfileRepositoryProvider = Provider<UpdateProfileRepository>((
  ref,
) {
  return UpdateProfileRepository();
});

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the privacy setting value
    final privacySetting = ref.watch(privacySettingProvider);
    final repository = ref.read(updateProfileRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection(
            title: 'Account',
            items: [
              _SettingsTile(
                icon: Icons.email_outlined,
                label: 'Update Email',
                onTap: () => context.push('/update-email'),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                label: 'Update Password',
                onTap: () => context.push('/update-password'),
              ),
              _SettingsTile(
                icon: Icons.lock_outline,
                label: 'Manage Blocklist',
                onTap: () => context.push('/blocklist'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Add Privacy Settings Section
          _SettingsSection(
            title: 'Privacy',
            items: [
              // Keep your existing profile privacy card
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.visibility,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Profile Privacy',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: privacySetting,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'public',
                            child: Text('Public'),
                          ),
                          DropdownMenuItem(
                            value: 'private',
                            child: Text('Private'),
                          ),
                          DropdownMenuItem(
                            value: 'connectionsOnly',
                            child: Text('Connections Only'),
                          ),
                        ],
                        onChanged: (String? newValue) async {
                          if (newValue != null && newValue != privacySetting) {
                            try {
                              // Show loading indicator
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Updating privacy settings...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );

                              // Update the provider state
                              ref.read(privacySettingProvider.notifier).state =
                                  newValue;

                              // Call the repository method
                              await repository.updatePrivacySettings(newValue);

                              // Show success message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Privacy settings updated successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Show error message and revert to previous value
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to update privacy settings: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );

                                // Revert the dropdown value
                                ref
                                    .read(privacySettingProvider.notifier)
                                    .state = privacySetting;
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getPrivacyDescription(privacySetting),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              // Add new connection request privacy card
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Connection Requests',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: ref.watch(connectionPrivacySettingProvider),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'everyone',
                            child: Text('Everyone'),
                          ),
                          DropdownMenuItem(
                            value: 'mutual',
                            child: Text('Mutual Connections Only'),
                          ),
                        ],
                        onChanged: (String? newValue) async {
                          final currentValue = ref.read(
                            connectionPrivacySettingProvider,
                          );

                          if (newValue != null && newValue != currentValue) {
                            try {
                              // Show loading indicator
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Updating connection request settings...',
                                  ),
                                  duration: Duration(seconds: 1),
                                ),
                              );

                              // Update the provider state
                              ref
                                  .read(
                                    connectionPrivacySettingProvider.notifier,
                                  )
                                  .state = newValue;

                              // Call the repository method
                              await repository.updateConnectionPrivacySettings(
                                newValue,
                              );

                              // Show success message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Connection request settings updated successfully',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              // Show error message and revert to previous value
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to update connection request settings: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );

                                // Revert the dropdown value
                                ref
                                    .read(
                                      connectionPrivacySettingProvider.notifier,
                                    )
                                    .state = currentValue;
                              }
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getConnectionPrivacyDescription(
                          ref.watch(connectionPrivacySettingProvider),
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          _SettingsSection(
            title: 'Security',
            items: [
              _SettingsTile(
                icon: Icons.logout,
                label: 'Sign Out',
                onTap: () async {
                  RequestService.post("/user/logout", body: {});
                  await TokenService.deleteCookie();
                  context.go('/');
                },
              ),
              _SettingsTile(
                icon: Icons.delete_forever,
                label: 'Delete Account',
                isDestructive: true,
                onTap: () => _confirmDeleteAccount(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to permanently delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  print('Account deleted');
                  context.go('/welcome');
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? Colors.red : Theme.of(context).iconTheme.color;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: TextStyle(color: color)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// Helper method to get privacy setting descriptions
String _getPrivacyDescription(String privacySetting) {
  switch (privacySetting) {
    case 'public':
      return 'Anyone can view your profile';
    case 'private':
      return 'Only you can view your profile';
    case 'connectionsOnly':
      return 'Only your connections can view your profile';
    default:
      return '';
  }
}

String _getConnectionPrivacyDescription(String privacySetting) {
  switch (privacySetting) {
    case 'everyone':
      return 'Anyone can send you connection requests';
    case 'mutual':
      return 'Only people who share mutual connections can send you requests';
    default:
      return '';
  }
}
