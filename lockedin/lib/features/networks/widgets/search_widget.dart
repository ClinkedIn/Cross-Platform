import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/networks/model/user_model.dart';
import 'package:lockedin/features/networks/viewmodel/user_search_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';

class UserSearchResultsOverlay extends ConsumerWidget {
  final LayerLink link;
  final GlobalKey searchBarKey;
  final Function(UserModel) onUserSelected;

  const UserSearchResultsOverlay({
    required this.link,
    required this.searchBarKey,
    required this.onUserSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(userSearchViewModelProvider);
    final RenderBox renderBox = searchBarKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;
    
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Positioned(
      width: size.width,
      child: CompositedTransformFollower(
        link: link,
        showWhenUnlinked: false,
        offset: Offset(0.0, size.height + 5.0),
        child: Material(
          elevation: 4.0,
          borderRadius: BorderRadius.circular(8.0),
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 50.h, // Use 50% of screen height as max
              minHeight: 0,
            ),
            child: !searchState.showResults
                ? SizedBox.shrink()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (searchState.isLoading && searchState.searchResults.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else if (searchState.error != null)
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Error searching: ${searchState.error}',
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      else if (searchState.searchResults.isEmpty && searchState.keyword.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'No users found for "${searchState.keyword}"',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white70 : Colors.black54,
                              ),
                            ),
                          ),
                        )
                      else
                        Flexible(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: searchState.searchResults.length,
                            itemBuilder: (context, index) {
                              final user = searchState.searchResults[index];
                              
                              // If we're near the end and there are more results to load
                              if (index == searchState.searchResults.length - 3) {
                                final currentPage = searchState.pagination['page'] as int;
                                final totalPages = searchState.pagination['pages'] as int;
                                
                                if (currentPage < totalPages) {
                                  // Load more results
                                  Future.microtask(() => ref.read(userSearchViewModelProvider.notifier).loadMoreResults());
                                }
                              }
                              
                              return InkWell(
                                onTap: () => onUserSelected(user),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Profile picture
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: user.profilePicture.isNotEmpty
                                            ? NetworkImage(user.profilePicture)
                                            : null,
                                        backgroundColor: Colors.grey[300],
                                        child: user.profilePicture.isEmpty
                                            ? Icon(Icons.person, color: Colors.white)
                                            : null,
                                      ),
                                      SizedBox(width: 12),
                                      
                                      // User information
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // User name
                                            Text(
                                              '${user.firstName} ${user.lastName}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: isDarkMode ? Colors.white : Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            
                                            SizedBox(height: 4),
                                            
                                            // User headline
                                            if (user.headline.isNotEmpty)
                                              Text(
                                                user.headline,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: isDarkMode ? Colors.white60 : Colors.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              
                                            // Company and position
                                            if (user.currentCompany != null && user.currentPosition != null)
                                              Text(
                                                '${user.currentPosition} at ${user.currentCompany}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDarkMode ? Colors.white54 : Colors.black54,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                      ),

                                      // Connection status
                                      if (user.connectionStatus != 'none')
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: user.connectionStatus == 'connected' 
                                                ? AppColors.primary.withOpacity(0.2)
                                                : Colors.grey.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            user.connectionStatus == 'connected' 
                                                ? 'Connected' 
                                                : user.connectionStatus == 'pending' 
                                                    ? 'Pending' 
                                                    : 'Unknown',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: user.connectionStatus == 'connected' 
                                                  ? AppColors.primary
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                      // Loading more indicator at bottom
                      if (searchState.isLoading && searchState.searchResults.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}