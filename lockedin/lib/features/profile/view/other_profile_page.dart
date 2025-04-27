import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/utils/profile_converters.dart';
import 'package:lockedin/features/profile/viewmodel/other_profile_view_model.dart';

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
      appBar: AppBar(title: const Text('Profile')),
      body: profileState.when(
        data: (user) => _buildProfile(context, user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }

  // Rest of your _buildProfile method remains the same
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
