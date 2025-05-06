import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/home_page/viewModel/home_viewmodel.dart';
import 'package:sizer/sizer.dart';
import '../../post/widgets/post_list.dart';
import 'package:lockedin/shared/theme/colors.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(homeViewModelProvider.notifier).refreshFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
      body:
          homeState.isLoading && homeState.posts.isEmpty
              ? Center(child: CircularProgressIndicator())
              : homeState.posts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                onRefresh:
                    () =>
                        ref.read(homeViewModelProvider.notifier).refreshFeed(),
                child: PostList(
                  posts: homeState.posts,
                  isLoadingMore: homeState.isLoadingMore,
                  hasMorePages: homeState.hasNextPage,
                  onLoadMore: () {
                    ref.read(homeViewModelProvider.notifier).loadMorePosts();
                  },
                ),
              ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.post_add, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No posts to show',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Be the first to post something!',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to create post page
              context.push('/create-post');
            },
            child: Text('Create Post'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error, WidgetRef ref) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 15.h, color: Colors.red),
          SizedBox(height: 2.h),
          Text(
            'Error loading posts',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16.sp,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              ref.read(homeViewModelProvider.notifier).refreshFeed();
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
}
