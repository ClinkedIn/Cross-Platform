// lib/features/search/view/widgets/search_results_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/shared/theme/theme_provider.dart';
import 'package:lockedin/shared/theme/app_theme.dart';
import '../repository/network_repository.dart';


class SearchResultsWidget extends ConsumerWidget {
  const SearchResultsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(searchQueryProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final theme = ref.watch(themeProvider);
    final isDarkMode = theme == AppTheme.darkTheme;
    
    if (searchQuery.isEmpty || searchQuery.length < 2) {
      return Center(
        child: Text(
          'Start typing to search users',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
        ),
      );
    }
    
    return searchResults.when(
      data: (users) {
        if (users.isEmpty) {
          return Center(
            child: Text(
              'No users found',
              style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
            ),
          );
        }
        
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePicture),
                onBackgroundImageError: (_, __) {
                  // Handle image loading error
                },
                child: user.profilePicture.isEmpty
                    ? Text(
                        '${user.firstName[0]}${user.lastName[0]}',
                        style: TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              title: Text(
                '${user.firstName} ${user.lastName}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${user.company} • ${user.industry}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              onTap: () {
                // Navigate to user profile
                context.push('/profile/${user.id}');
              },
            );
          },
        );
      },
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Text(
          'Error: ${error.toString()}',
          style: TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}