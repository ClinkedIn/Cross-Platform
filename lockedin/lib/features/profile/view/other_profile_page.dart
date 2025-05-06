import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/profile/model/user_model.dart';
import 'package:lockedin/features/profile/repository/blocked_repository.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:lockedin/features/profile/viewmodel/other_profile_view_model.dart';

// Import widgets
import 'package:lockedin/features/profile/widgets/others_profile/actions_menu.dart';
import 'package:lockedin/features/profile/widgets/others_profile/shared/profile_picture.dart';
import 'package:lockedin/features/profile/widgets/others_profile/sections/profile_header.dart';
import 'package:lockedin/features/profile/widgets/others_profile/sections/about_section.dart';
import 'package:lockedin/features/profile/widgets/others_profile/sections/experience_section.dart';
import 'package:lockedin/features/profile/widgets/others_profile/sections/education_section.dart';
import 'package:lockedin/features/profile/widgets/others_profile/sections/skills_section.dart';

// Add repository provider
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
  bool? canView;
  bool isLoading = true;
  late final AsyncValue<UserModel> userState; // Properly define the userState
  String userId = '';
  final Map<String, bool> connectionStatus = {
    'connected': false,
    'pending': false,
    'sentConnectionRequest': false,
    'followed': false,
  };
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    userId = ref
        .read(userProvider)
        .when(
          data: (user) {
            return user.id;
          },
          loading: () {
            return "";
          },
          error: (error, stackTrace) {
            return "";
          },
        );

    _init();
  }

  // Refresh the entire profile data - used by RefreshIndicator
  Future<void> _refreshProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      await _loadUserProfile();
    } catch (e) {
      // Show error if needed
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing profile: ${e.toString()}')),
        );
      }
    } finally {
      // Always update loading state if mounted
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Initial load
  Future<void> _init() async {
    try {
      // Initial loading state set in class declaration
      final result = await ref
          .read(profileStateProvider.notifier)
          .loadUserProfile(widget.userId);

      // Update connection status on initial load
      await _handleConnectionStatusChanged();

      if (mounted) {
        setState(() {
          canView = result;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle errors during initialization
      if (mounted) {
        setState(() {
          isLoading = false;
          canView = false; // Default to not viewable on error
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  // Load user profile and connection status
  Future<void> _loadUserProfile() async {
    try {
      // 1. First, invalidate the relevant providers to ensure fresh data
      ref.invalidate(profileStateProvider);
      ref.invalidate(userProvider);

      // 2. Load the profile with the updated repository data
      final result = await ref
          .read(profileStateProvider.notifier)
          .loadUserProfile(widget.userId);
      if (mounted) {
        setState(() {
          canView = result;
        });
      }
    } catch (e) {
      // Rethrow to be handled by calling methods
      rethrow;
    }
  }

  Future<void> _handleConnectionStatusChanged() async {
    try {
      print("🔄 Connection status changed");

      // Reset connection status to defaults
      connectionStatus.forEach((key, value) {
        connectionStatus[key] = false;
      });

      // Update UI to ensure it reflects the reset state
      if (mounted) {
        setState(() {});
      }
      final profileState = ref.read(profileStateProvider);
      final user = profileState.user;

      // Check if this user is in sent connection requests
      connectionStatus['pending'] = user.receivedConnectionRequests.contains(
        userId,
      );

      // Check if this user has sent us a connection request
      connectionStatus['sentConnectionRequest'] = user.sentConnectionRequests
          .contains(userId);

      // Check if this user is connected
      connectionStatus['connected'] = user.connectionList.contains(userId);

      // Check if this user is being followed
      connectionStatus['followed'] = false;
      if (user.followers.isNotEmpty) {
        for (var follower in user.followers) {
          if (follower.entity == userId) {
            connectionStatus['followed'] = true;
            break;
          }
        }
      }

      // Force UI update
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Exception in _handleConnectionStatusChanged: ${e.toString()}');
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating connection: ${e.toString()}')),
        );

        // Reset all statuses on error
        setState(() {
          connectionStatus.forEach((key, value) {
            connectionStatus[key] = false;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Handle null canView case (shouldn't normally happen with proper error handling)
    if (canView == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error'), centerTitle: true),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'An error occurred loading this profile',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    // User cannot view the profile
    if (!canView!) {
      return _buildPrivateProfileView();
    }

    // User can view the profile - get connection status information
    final profileState = ref.watch(profileStateProvider);
    final user = profileState.user;

    // Build the profile view
    return Scaffold(
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refreshProfile,
        child: _buildProfileView(context, user, connectionStatus),
      ),
    );
  }

  // Build the private profile view
  Widget _buildPrivateProfileView() {
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
                icon: const Icon(Icons.arrow_back),
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

  // Build the main profile view
  Widget _buildProfileView(
    BuildContext context,
    UserModel user,
    Map<String, bool> connectionStatus,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () async {
                final result = await ref
                    .read(profileStateProvider.notifier)
                    .loadUserProfile(widget.userId);
                await _handleConnectionStatusChanged();

                if (mounted) {
                  setState(() {
                    canView = result;
                    isLoading = false;
                  });
                }
              },
            ),
            ProfileActionsMenu(user: user),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (user.coverPicture != null && user.coverPicture!.isNotEmpty)
                  Image.network(
                    user.coverPicture!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Container(color: Colors.grey.shade300),
                  )
                else
                  Image.asset(
                    'assets/images/default_cover_photo.jpeg',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) =>
                            Container(color: Colors.grey.shade300),
                  ),
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
          child: Center(
            child: ProfilePicture(profilePictureUrl: user.profilePicture),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, 10),
            child: ProfileHeader(
              user: user,
              connectionStatus: connectionStatus,
              onConnectionStatusChanged: () async {
                final result = await ref
                    .read(profileStateProvider.notifier)
                    .loadUserProfile(widget.userId);
                await _handleConnectionStatusChanged();

                if (mounted) {
                  setState(() {
                    canView = result;
                    isLoading = false;
                  });
                }
              },
            ),
          ),
        ),
        SliverToBoxAdapter(child: AboutSection(user: user)),
        SliverToBoxAdapter(
          child: ExperienceSection(experiences: user.workExperience),
        ),
        SliverToBoxAdapter(child: EducationSection(educations: user.education)),
        SliverToBoxAdapter(child: SkillsSection(user: user)),
        const SliverToBoxAdapter(child: SizedBox(height: 50)),
      ],
    );
  }
}
