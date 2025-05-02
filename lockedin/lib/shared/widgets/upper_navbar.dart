import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:lockedin/features/chat/view/chat_list_page.dart';
import 'package:lockedin/features/home_page/viewmodel/search_viewmodel.dart';
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
        ref.read(searchViewModelProvider.notifier).showResults();
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

  void _onSearchChanged() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new debounce timer
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().length >= 2) {
        ref
            .read(searchViewModelProvider.notifier)
            .searchPosts(_searchController.text);
        if (!_searchFocusNode.hasFocus) {
          _searchFocusNode.requestFocus();
        }
      } else if (_searchController.text.isEmpty) {
        ref.read(searchViewModelProvider.notifier).clearSearch();
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();

    // Update the onPostSelected callback
    _overlayEntry = OverlayEntry(
      builder:
          (context) => SearchResultsOverlay(
            link: _layerLink,
            searchBarKey: _searchBarKey,
            // In the onPostSelected callback:
            onPostSelected: (post) {
              _searchFocusNode.unfocus();

              // Try multiple field names that could contain the post ID
              final postId = post.id;

              print('Post selected: $postId');
              print('Entire post object: $post');
              if (postId != null) {
                context.push('/detailed-post/$postId');
              } else {
                // Show error if post ID is null
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: Could not find post ID')),
                );
              }
            },
          ),
    );

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
                  _getCurrentRoute(context) == "/home"
                      ? "Search posts"
                      : _getCurrentRoute(context) == "/users"
                      ? "Search users"
                      : _getCurrentRoute(context) == "/jobs"
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
                          ref
                              .read(searchViewModelProvider.notifier)
                              .clearSearch();
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
                ref.read(searchViewModelProvider.notifier).searchPosts(value);
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatListScreen()),
            );
          },
        ),
      ],
    );
  }
}
