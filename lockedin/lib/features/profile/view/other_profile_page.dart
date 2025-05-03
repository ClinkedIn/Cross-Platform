import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/repository/blocked_repository.dart';
import 'package:lockedin/features/profile/viewmodel/other_profile_view_model.dart';

// Import widgets
import '../widgets/others_profile/actions_menu.dart';
import '../widgets/others_profile/shared/profile_picture.dart';
import '../widgets/others_profile/sections/profile_header.dart';
import '../widgets/others_profile/sections/about_section.dart';
import '../widgets/others_profile/sections/experience_section.dart';
import '../widgets/others_profile/sections/education_section.dart';
import '../widgets/others_profile/sections/skills_section.dart';

// Add repository provider
final blockedRepositoryProvider = Provider<BlockedRepository>((ref) {
  return BlockedRepository();
});

class ViewOtherProfilePage extends ConsumerStatefulWidget {
  final String userId;

  const ViewOtherProfilePage({Key? key, required this.userId})
    : super(key: key);

  @override
  _ViewOtherProfilePageState createState() => _ViewOtherProfilePageState();
}

class _ViewOtherProfilePageState extends ConsumerState<ViewOtherProfilePage> {
  bool? canView; // null = loading

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final result = await ref
        .read(profileStateProvider.notifier)
        .loadUserProfile(widget.userId);
    setState(() {
      canView = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (canView == null) {
      // Still loading
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!canView!) {
      // User cannot view the profile
      return _cannotViewProfile();
    }

    final profileState = ref.watch(profileStateProvider);
    final user = profileState.user;
    final canSendConnectionRequest = profileState.canSendConnectionRequest;

    return Scaffold(
      body: _buildProfile(context, user, theme, canSendConnectionRequest),
    );
  }

  Widget _cannotViewProfile() {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 80, color: Colors.grey.shade600),
              const SizedBox(height: 20),
              Text(
                'This profile is private',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'You do not have permission to view this profile. '
                'This could be due to privacy settings or a block.',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text('Go Back'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfile(
    BuildContext context,
    UserModel user,
    ThemeData theme,
    bool canSendConnectionRequest,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          actions: [ProfileActionsMenu(user: user)],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                user.coverPicture != null
                    ? Image.network(user.coverPicture!, fit: BoxFit.cover)
                    : Container(color: Colors.grey.shade300),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              ProfilePicture(profilePictureUrl: user.profilePicture),
              Transform.translate(
                offset: const Offset(0, 10),
                child: Column(
                  children: [
                    ProfileHeader(
                      user: user,
                      canconnect: canSendConnectionRequest,
                    ),
                    AboutSection(user: user),
                    ExperienceSection(experiences: user.workExperience),
                    EducationSection(educations: user.education),
                    SkillsSection(user: user),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
