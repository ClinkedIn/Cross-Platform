import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/networks/viewmodel/user_search_viewmodel.dart';
import 'package:lockedin/features/networks/widgets/search_widget.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:lockedin/features/chat/view/chat_list_page.dart';
import 'package:lockedin/features/home_page/viewmodel/search_viewmodel.dart'; // Added import
import 'package:lockedin/features/home_page/widgets/search_results_overlay.dart';
import 'dart:async';

final navigationProvider = StateProvider<String>((ref) => '/');

class UpperNavbar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final Widget leftIcon;
  final VoidCallback leftOnPress;

  const UpperNavbar({
    super.key,
    required this.leftIcon,
    required this.leftOnPress,
  });

  @override
  ConsumerState<UpperNavbar> createState() => _UpperNavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _UpperNavbarState extends ConsumerState<UpperNavbar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _searchBarKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        // Show appropriate results based on current route
        if (_getCurrentRoute(context) == "/network") {
          ref.read(userSearchViewModelProvider.notifier).showResults();
        } else {
          ref.read(searchViewModelProvider.notifier).showResults();
        }
        _showOverlay();
      } else {
        // Slight delay before hiding to allow for taps on results
        Future.delayed(Duration(milliseconds: 200), () {
          if (!_searchFocusNode.hasFocus) {
            _removeOverlay();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  // In the _onSearchChanged method:

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Ensure minimum 2 characters before triggering search
      if (_searchController.text.trim().length >= 2) {
        final currentRoute = _getCurrentRoute(context);

        // Use appropriate search based on current route
        if (currentRoute == "/network") {
          ref
              .read(userSearchViewModelProvider.notifier)
              .searchUsers(_searchController.text);
        } else {
          ref
              .read(searchViewModelProvider.notifier)
              .searchPosts(_searchController.text);
        }

        if (!_searchFocusNode.hasFocus) {
          _searchFocusNode.requestFocus();
        }
      } else if (_searchController.text.isEmpty) {
        // Clear appropriate search based on current route
        if (_getCurrentRoute(context) == "/network") {
          ref.read(userSearchViewModelProvider.notifier).clearSearch();
        } else {
          ref.read(searchViewModelProvider.notifier).clearSearch();
        }
      } else {
        // Handle case when text is 1 character - show warning
        final currentRoute = _getCurrentRoute(context);
        if (currentRoute == "/network") {
          ref.read(userSearchViewModelProvider.notifier).clearSearch();
          ref.read(userSearchViewModelProvider.notifier).state = ref
              .read(userSearchViewModelProvider.notifier)
              .state
              .copyWith(
                error: "Search term must be at least 2 characters",
                keyword: _searchController.text,
                showResults: true,
                isLoading: false,
              );
        }
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();
    final currentRoute = _getCurrentRoute(context);

    // Create appropriate overlay based on current route
    if (currentRoute == "/network") {
      _overlayEntry = OverlayEntry(
        builder:
            (context) => UserSearchResultsOverlay(
              link: _layerLink,
              searchBarKey: _searchBarKey,
              onUserSelected: (user) {
                _searchFocusNode.unfocus();

                debugPrint('User selected: ${user.id}');
                if (user.id.isNotEmpty) {
                  context.push('/other-profile/${user.id}');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: Could not find user ID')),
                  );
                }
              },
            ),
      );
    } else {
      _overlayEntry = OverlayEntry(
        builder:
            (context) => SearchResultsOverlay(
              link: _layerLink,
              onCompanySelected: (company) {
                _searchFocusNode.unfocus();
                if (company.id != null) {
                  context.push('/company/${company.id}');
                }
              },
              searchBarKey: _searchBarKey,
              onPostSelected: (post) {
                _searchFocusNode.unfocus();

                final postId = post.id;
                debugPrint('Post selected: $postId');

                if (postId.isNotEmpty) {
                  context.push('/detailed-post/$postId');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: Could not find post ID')),
                  );
                }
              },
            ),
      );
    }

    if (_overlayEntry != null) {
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  String _getCurrentRoute(BuildContext context) {
    final GoRouterState routerState = GoRouterState.of(context);
    return routerState.matchedLocation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme == AppTheme.darkTheme;
    final currentRoute = _getCurrentRoute(context);

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      leading: IconButton(icon: widget.leftIcon, onPressed: widget.leftOnPress),
      title: Container(
        key: _searchBarKey,
        height: 40,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: CompositedTransformTarget(
          link: _layerLink,
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              fillColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
              hintText:
                  currentRoute == "/home"
                      ? "Search posts"
                      : currentRoute == "/network"
                      ? "Search users"
                      : currentRoute == "/jobs"
                      ? "Search jobs"
                      : "Search",
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          if (currentRoute == "/home") {
                            ref
                                .read(searchViewModelProvider.notifier)
                                .clearSearch();
                          } else if (currentRoute == "/network") {
                            ref
                                .read(userSearchViewModelProvider.notifier)
                                .clearSearch();
                          } else if (currentRoute == "/jobs") {
                            ref
                                .read(searchViewModelProvider.notifier)
                                .clearSearch();
                          }
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10.0),
            ),
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black87),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                if (currentRoute == "/network") {
                  ref
                      .read(userSearchViewModelProvider.notifier)
                      .searchUsers(value);
                } else {
                  ref.read(searchViewModelProvider.notifier).searchPosts(value);
                }
              }
            },
          ),
        ),
      ),
      actions: [
        // Theme Toggle Button
        IconButton(
          icon: Icon(
            isDarkMode ? Icons.light_mode : Icons.dark_mode,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
        ),
        IconButton(
          icon: Icon(
            Icons.settings,
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
          onPressed: () {
            context.push("/settings");
          },
        ),
        IconButton(
          icon: Icon(
            Icons.chat,
            color: isDarkMode ? Colors.white70 : Colors.grey[700],
          ),
          onPressed: () {
            ref.read(navigationProvider.notifier).state = '/chats';
            context.push("/chat-list");
          },
        ),
      ],
    );
  }
}
