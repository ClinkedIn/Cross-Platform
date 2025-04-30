import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:lockedin/features/home_page/viewModel/saved_posts_viewmodel.dart';
import 'package:lockedin/features/home_page/state/saved_posts_state.dart';
import 'package:lockedin/features/post/widgets/post_card.dart';
import 'package:lockedin/shared/theme/colors.dart';

class SavedPostsPage extends ConsumerStatefulWidget {
  const SavedPostsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SavedPostsPage> createState() => _SavedPostsPageState();
}

class _SavedPostsPageState extends ConsumerState<SavedPostsPage> {
  @override
  void initState() {
    super.initState();
    // Refresh posts when page is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savedPostsViewModelProvider).refreshSavedPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedPostsState = ref.watch(savedPostsStateProvider);
    final viewModel = ref.watch(savedPostsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Posts'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'), // Navigate back to home page
        ),
      ),
      body: savedPostsState.isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : savedPostsState.error != null
              ? _buildErrorView(context, savedPostsState.error!, viewModel)
              : savedPostsState.posts.isEmpty
                  ? _buildEmptyView(context)
                  : RefreshIndicator(
                      onRefresh: () async {
                        await viewModel.refreshSavedPosts();
                      },
                      child: _buildPostList(context, savedPostsState, ref),
                    ),
    );
  }

  Widget _buildPostList(
    BuildContext context,
    SavedPostsState state,
    WidgetRef ref,
  ) {
    final viewModel = ref.read(savedPostsViewModelProvider);
    
    return ListView.builder(
      itemCount: state.posts.length,
      itemBuilder: (context, index) {
        final post = state.posts[index];
        return PostCard(
          post: post,
          onLike: () async {
            try {
              await viewModel.toggleLike(post.id);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update like status'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          onComment: () {
            context.push('/detailed-post/${post.id}');
          },
          onShare: () {
            // Implement share functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Share functionality coming soon')),
            );
          },
          onRepost: () {
            // Implement repost functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Repost functionality coming soon')),
            );
          },
          onFollow: () {
            // Implement follow functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Follow functionality coming soon')),
            );
          },
          onSaveForLater: () async {
            // Remove from saved posts
            try {
              await viewModel.removeFromSaved(post.id);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Post removed from saved'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to remove post from saved'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  Widget _buildErrorView(
    BuildContext context, 
    String error, 
    SavedPostsViewModel viewModel
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 15.h, color: Colors.red),
          SizedBox(height: 2.h),
          Text(
            'Error loading saved posts',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  color: Colors.red,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  color: Colors.red,
                ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              viewModel.refreshSavedPosts();
            },
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 15.h, color: AppColors.gray),
          SizedBox(height: 2.h),
          Text(
            'No saved posts',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                  color: AppColors.gray,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Posts you save will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.gray,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}