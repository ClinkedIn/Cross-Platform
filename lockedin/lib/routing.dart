import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/core/services/token_services.dart';
import 'package:lockedin/features/auth/view/change_password_page.dart';
import 'package:lockedin/features/auth/view/edit_email_view.dart';
import 'package:lockedin/features/auth/view/forget%20Password/forgot_password_page.dart';
import 'package:lockedin/features/auth/view/login_page.dart';
import 'package:lockedin/features/auth/view/main_page.dart';
import 'package:lockedin/features/auth/view/signup/sign_up_view.dart';
import 'package:lockedin/features/chat/view/chat_list_page.dart';
import 'package:lockedin/features/home_page/view/home_page.dart';
import 'package:lockedin/features/jobs/view/jobs_page.dart';
import 'package:lockedin/features/networks/view/connections_page.dart';
import 'package:lockedin/features/networks/view/events_page.dart';
import 'package:lockedin/features/networks/view/groups_page.dart';
import 'package:lockedin/features/networks/view/invitations_page.dart';
import 'package:lockedin/features/networks/view/manage_page.dart';
import 'package:lockedin/features/networks/view/network_page.dart';
import 'package:lockedin/features/networks/view/newsletters_page.dart';
import 'package:lockedin/features/networks/view/pages_page.dart';
import 'package:lockedin/features/notifications/view/notifications_page.dart';
import 'package:lockedin/features/post/view/post_page.dart';
import 'package:lockedin/features/profile/state/profile_components_state.dart';
import 'package:lockedin/features/profile/utils/picture_loader.dart';
import 'package:lockedin/features/profile/view/add_education_page.dart';
import 'package:lockedin/features/profile/view/add_position_page.dart';
import 'package:lockedin/features/profile/view/add_resume_page.dart';
import 'package:lockedin/features/profile/view/add_section_window.dart';
import 'package:lockedin/features/profile/view/add_skill_page.dart';
import 'package:lockedin/features/profile/view/block_list_page.dart';
import 'package:lockedin/features/profile/view/edit_cover_photo.dart';
import 'package:lockedin/features/profile/view/edit_profile_photo.dart';
import 'package:lockedin/features/profile/view/other_profile_page.dart';
import 'package:lockedin/features/profile/view/profile_page.dart';
import 'package:lockedin/features/profile/view/setting_page.dart';
import 'package:lockedin/features/profile/view/update_page.dart';
import 'package:lockedin/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:lockedin/shared/widgets/side_bar.dart';
import 'package:lockedin/shared/widgets/upper_navbar.dart';
import 'package:lockedin/shared/widgets/bottom_navbar.dart';
import 'package:lockedin/features/home_page/view/detailed_post.dart';
import './features/home_page/view/editpost_view.dart';
import './features/home_page/model/post_model.dart';
import 'package:lockedin/features/home_page/view/post_likes_view.dart';
import 'package:lockedin/features/jobs/view/application_status.dart';


// Use this to control drawer state
final scaffoldKeyProvider = Provider((ref) => GlobalKey<ScaffoldState>());

final goRouterProvider = Provider<GoRouter>((ref) {
  final globalKey = ref.watch(scaffoldKeyProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final publicRoutes = ['/login', '/forgot-password', '/sign-up'];

      var isAuthenticated = await TokenService.hasCookie();

      // Don't redirect when navigating to the root page, let MainPage handle it
      if (state.fullPath == '/') {
        return null;
      }

      // Going to a public route while authenticated
      if (isAuthenticated && publicRoutes.contains(state.fullPath)) {
        return '/home';
      }
      // Going to a protected route while not authenticated
      if (!isAuthenticated && !publicRoutes.contains(state.fullPath)) {
        return '/login';
      }
      if (isAuthenticated) {
        ref.read(profileViewModelProvider).fetchAllProfileData();
      }
      // Otherwise, allow the navigation
      return null;
    },

    routes: [
      GoRoute(path: '/', name: 'root', builder: (context, state) => MainPage()),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => ProfilePage(),
      ),
      GoRoute(
        path: '/chats',
        name: 'chats',
        builder: (context, state) => ChatListScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => ForgotPasswordScreen(),
      ),
      GoRoute(
        path: "/sign-up",
        name: "sign-up",
        builder: (context, state) => SignUpView(),
      ),
      GoRoute(
        path: "/add-section",
        name: "add-section",
        builder: (context, state) => AddToProfilePage(),
      ),
      GoRoute(
        path: "/add-education",
        name: "add-education",
        builder: (context, state) => AddEducationPage(),
      ),
      GoRoute(
        path: "/detailed-post/:postId",
        name: "detailed-post",
        builder:
            (context, state) =>
                PostDetailView(postId: state.pathParameters['postId']!),
      ),
      GoRoute(
        path: "/add-position",
        name: "add-position",
        builder: (context, state) => AddPositionPage(),
      ),
      GoRoute(
        path: "/add-skills",
        name: "add-skills",
        builder: (context, state) => AddSkillPage(),
      ),
      GoRoute(
        path: "/settings",
        name: "settings",
        builder: (context, state) => SettingsPage(),
      ),
      GoRoute(
        path: "/update-email",
        name: "update-email",
        builder: (context, state) => EditEmailView(),
      ),
      GoRoute(
        path: "/update-password",
        name: "update-password",
        builder: (context, state) => ChangePasswordPage(),
      ),
      GoRoute(
        path: "/manage-page",
        name: "manage-page",
        builder: (context, state) => ManagePage(),
      ),
      GoRoute(
        path: "/connections",
        name: "connection-page",
        builder: (context, state) => ConnectionsPage(),
      ),
      GoRoute(
        path: "/groups",
        name: "groups-page",
        builder: (context, state) => GroupsPage(),
      ),
      GoRoute(
        path: "/events",
        name: "events-page",
        builder: (context, state) => EventsPage(),
      ),
      GoRoute(
        path: "/pages",
        name: "pages-page",
        builder: (context, state) => PagesPage(),
      ),
      GoRoute(
        path: "/newsletter",
        name: "newsletter-page",
        builder: (context, state) => NewsletterPage(),
      ),
      GoRoute(
        path: "/invitations",
        name: "invitation-page",
        builder: (context, state) => InvitationPage(),
      ),
      GoRoute(
        path: '/edit-profile-photo',
        name: 'edit-profile-photo',
        builder: (context, state) => EditProfilePhoto(),
      ),
      GoRoute(
        path: '/edit-cover-photo',
        name: 'edit-cover-photo',
        builder: (context, state) => EditCoverPhoto(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => UpdateProfileView(),
      ),
      GoRoute(
        path: "/add-resume",
        name: "add-resume",
        builder: (context, state) => AddResumePage(),
      ),
      GoRoute(
        path: '/blocklist',
        name: 'blocklist',
        builder: (context, state) => BlockedUsersPage(),
      ),
      GoRoute(
        path: '/other-profile/:userId',
        name: 'other-profile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ViewOtherProfilePage(userId: userId);
        },
      ),
      // Add the new route
      GoRoute(
        path: '/edit-post',
        builder: (context, state) {
          final post = state.extra as PostModel;
          return EditPostPage(post: post);
        },
      ),

      GoRoute(
        path: '/post-likes/:postId',
        name: 'post-likes',
        builder: (context, state) {
          final postId = state.pathParameters['postId']!;
          return PostLikesPage(postId: postId);
        },
      ),

      GoRoute(
        path: '/application-status/:jobId', // Include jobId in the path
        name:
            'application-status', // Correct the name (remove the leading slash)
        builder: (context, state) {
          final jobId =
              state
                  .pathParameters['jobId']!; // Retrieve jobId from the URL parameters
          return ApplicationStatusPage(jobId: jobId);
        },
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Get the current tab index from the navigation shell
          final currentIndex = navigationShell.currentIndex;

          // When tab changes, close the drawer if it's open
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (globalKey.currentState?.isDrawerOpen ?? false) {
              globalKey.currentState?.closeDrawer();
            }
          });

          return Scaffold(
            key: globalKey,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(
                kToolbarHeight,
              ), // Standard app bar height
              child: Consumer(
                builder: (context, ref, _) {
                  final currentUser = ref.watch(userProvider);

                  return currentUser.when(
                    data:
                        (user) => UpperNavbar(
                          leftIcon: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.transparent,
                            backgroundImage: getUserProfileImage(currentUser),
                          ),
                          leftOnPress: () {
                            // Toggle drawer only when profile icon is clicked
                            if (globalKey.currentState?.isDrawerOpen ?? false) {
                              globalKey.currentState?.closeDrawer();
                            } else {
                              globalKey.currentState?.openDrawer();
                            }
                          },
                        ),
                    loading: () => AppBar(title: Text("Loading...")),
                    error: (err, _) => AppBar(title: Text("error")),
                  );
                },
              ),
            ),

            // Drawer is only opened when the profile icon is clicked
            drawer: SidebarDrawer(),
            body: navigationShell,
            bottomNavigationBar: BottomNavBar(
              currentIndex: currentIndex,
              onTap: (index) {
                // Close drawer before navigating to new tab
                if (globalKey.currentState?.isDrawerOpen ?? false) {
                  globalKey.currentState?.closeDrawer();
                }
                navigationShell.goBranch(
                  index,
                  initialLocation: index == navigationShell.currentIndex,
                );
              },
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/home', builder: (context, state) => HomePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/network',
                builder: (context, state) => NetworksPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/post', builder: (context, state) => PostPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (context, state) => NotificationsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/jobs', builder: (context, state) => JobsPage()),
            ],
          ),
        ],
      ),
    ],
  );
});
