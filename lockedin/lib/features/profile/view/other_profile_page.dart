import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/repository/blocked_repository.dart';
import 'package:lockedin/features/profile/utils/profile_converters.dart';
import 'package:lockedin/features/profile/viewmodel/other_profile_view_model.dart';

// Add this provider for the repository
final blockedRepositoryProvider = Provider<BlockedRepository>((ref) {
  return BlockedRepository();
});

class ViewOtherProfilePage extends ConsumerStatefulWidget {
  final String userId;

  const ViewOtherProfilePage({Key? key, required this.userId})
    : super(key: key);

  @override
  ConsumerState<ViewOtherProfilePage> createState() =>
      _ViewOtherProfilePageState();
}

class _ViewOtherProfilePageState extends ConsumerState<ViewOtherProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(otherProfileViewModelProvider.notifier)
          .fetchUserProfile(widget.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(otherProfileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Add the report/block menu icon
          profileState.when(
            data: (user) => _buildMoreActionsButton(context, user),
            loading: () => Container(),
            error: (_, __) => Container(),
          ),
        ],
      ),
      body: profileState.when(
        data: (user) => _buildProfile(context, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildMoreActionsButton(BuildContext context, UserModel user) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'report') {
          _showReportDialog(context, user);
        } else if (value == 'block') {
          _showBlockDialog(context, user);
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

  void _showReportDialog(BuildContext context, UserModel user) {
    final reasons = [
      "Harassment",
      "Fraud or scam",
      "Spam",
      "Misinformation",
      "Hateful speech",
      "Threats or violence",
      "Self-harm",
      "Graphic content",
      "Dangerous or extremist organizations",
      "Sexual content",
      "Fake account",
      "Child exploitation",
      "Illegal goods and services",
      "Infringement",
      "This person is impersonating someone",
      "This account has been hacked",
      "This account is not a real person",
    ];

    String selectedReason = reasons.first;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Report ${user.firstName} ${user.lastName}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please select a reason for your report:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedReason,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          reasons.map((reason) {
                            return DropdownMenuItem<String>(
                              value: reason,
                              child: Text(
                                reason,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedReason = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    // Show loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Submitting report...'),
                        duration: Duration(seconds: 1),
                      ),
                    );

                    try {
                      await ref
                          .read(blockedRepositoryProvider)
                          .reportUser(user.id, selectedReason);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Report submitted successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to submit report: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit Report'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showBlockDialog(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Block ${user.firstName} ${user.lastName}?'),
          content: Text(
            'When you block someone:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                // Show loading indicator
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Blocking user...'),
                    duration: Duration(seconds: 1),
                  ),
                );

                try {
                  // Call the block repository
                  await ref.read(blockedRepositoryProvider).blockUser(user.id);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User blocked successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    // Navigate back after successful block
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to block user: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Block'),
            ),
          ],
        );
      },
    );
  }

  // Rest of your existing code for _buildProfile method...
  Widget _buildProfile(BuildContext context, UserModel user) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              // Cover Photo
              user.coverPicture != null
                  ? Image.network(
                    user.coverPicture!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  )
                  : Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade300,
                  ),

              Positioned(
                bottom: 0,
                left: 16,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      user.profilePicture != null
                          ? NetworkImage(user.profilePicture!)
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            '${user.firstName} ${user.lastName}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          if (user.headline != null)
            Text(user.headline!, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          if (user.location != null)
            Text(user.location!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Connection request sent')),
                );
              },
              child: const Text('Connect'),
            ),
          ),

          const Divider(),

          if (user.about?.description != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                user.about!.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),

          if (user.workExperience.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Experience',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...user.workExperience.map((edu) {
                    final duration =
                        "${ProfileConverters.formatDate(edu.fromDate)} - ${edu.toDate != null ? ProfileConverters.formatDate(edu.toDate) : 'Present'}";

                    return ListTile(
                      leading:
                          edu.media != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  edu.media!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.school),
                                ),
                              )
                              : const Icon(Icons.school),
                      title: Text(edu.jobTitle),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${edu.companyName} • ${edu.employmentType}'),
                          if (duration.isNotEmpty)
                            Text(
                              duration,
                              style: const TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

          if (user.education.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Education',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...user.education.map((edu) {
                    final duration =
                        edu.startDate != null
                            ? "${ProfileConverters.formatDate(edu.startDate)} - ${edu.endDate != null ? ProfileConverters.formatDate(edu.endDate) : 'Present'}"
                            : "";

                    return ListTile(
                      leading:
                          edu.media != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  edu.media!,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Icon(Icons.school),
                                ),
                              )
                              : const Icon(Icons.school),
                      title: Text(edu.degree ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${edu.fieldOfStudy} • ${edu.school}'),
                          if (duration.isNotEmpty)
                            Text(
                              duration,
                              style: const TextStyle(color: Colors.grey),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),

          // Skills Section
          if (user.about?.skills != null && user.about!.skills.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),

              child: Column(
                children: [
                  const Text(
                    'skills',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Wrap(
                    spacing: 8,
                    children:
                        user.about!.skills
                            .map((skill) => Chip(label: Text(skill)))
                            .toList(),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
