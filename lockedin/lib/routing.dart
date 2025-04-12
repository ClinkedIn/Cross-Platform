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
import 'package:lockedin/features/networks/view/network_page.dart';
import 'package:lockedin/features/notifications/view/notifications_page.dart';
import 'package:lockedin/features/post/view/post_page.dart';
import 'package:lockedin/features/profile/state/user_state.dart';
import 'package:lockedin/features/profile/view/add_education_page.dart';
import 'package:lockedin/features/profile/view/add_position_page.dart';
import 'package:lockedin/features/profile/view/add_section_window.dart';
import 'package:lockedin/features/profile/view/add_skill_page.dart';
import 'package:lockedin/features/profile/view/profile_page.dart';
import 'package:lockedin/features/profile/view/setting_page.dart';
import 'package:lockedin/shared/widgets/side_bar.dart';
import 'package:lockedin/shared/widgets/upper_navbar.dart';
import 'package:lockedin/shared/widgets/bottom_navbar.dart';

// Track whether user data has been loaded
final userDataLoadedProvider = StateProvider<bool>((ref) => false);

// Use this to control drawer state
final scaffoldKeyProvider = Provider((ref) => GlobalKey<ScaffoldState>());

final goRouterProvider = Provider<GoRouter>((ref) {
  final globalKey = ref.watch(scaffoldKeyProvider);
  final currentUser = ref.watch(userProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Define public routes that don't require authentication
      final publicRoutes = ['/login', '/forgot-password', '/sign-up'];

      // Get authentication status
      final isAuthenticated = await TokenService.hasCookie();

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
            appBar: UpperNavbar(
              leftIcon: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                backgroundImage:
                    currentUser != null && currentUser.profilePicture.isNotEmpty
                        ? NetworkImage(currentUser.profilePicture)
                        : const AssetImage(
                              'assets/images/default_profile_photo.png',
                            )
                            as ImageProvider,
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
