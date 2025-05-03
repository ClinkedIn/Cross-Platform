import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:lockedin/features/company/view/company_profile.dart';
import 'package:lockedin/features/home_page/viewmodel/search_viewmodel.dart';
import 'package:lockedin/shared/theme/colors.dart';
import 'package:sizer/sizer.dart';

class SearchResultsOverlay extends ConsumerWidget {
  final LayerLink link;
  final GlobalKey searchBarKey;
  final Function(PostModel) onPostSelected;
  final Function(Company) onCompanySelected;

  const SearchResultsOverlay({
    required this.link,
    required this.searchBarKey,
    required this.onPostSelected,
    required this.onCompanySelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchViewModelProvider);
    final RenderBox renderBox =
        searchBarKey.currentContext!.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final posts = searchState.searchResults;
    final companies = searchState.companyResults;

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
            constraints: BoxConstraints(maxHeight: 50.h, minHeight: 0),
            child:
                !searchState.showResults
                    ? SizedBox.shrink()
                    : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (searchState.isLoading &&
                              posts.isEmpty &&
                              companies.isEmpty)
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
                          else if (posts.isEmpty &&
                              companies.isEmpty &&
                              searchState.keyword.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'No results found for "${searchState.keyword}"',
                                  style: TextStyle(
                                    color:
                                        isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            if (posts.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Posts",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ...posts.map(
                              (post) => InkWell(
                                onTap: () => onPostSelected(post),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            post.profileImageUrl.isNotEmpty
                                                ? NetworkImage(
                                                  post.profileImageUrl,
                                                )
                                                : null,
                                        backgroundColor: Colors.grey[300],
                                        child:
                                            post.profileImageUrl.isEmpty
                                                ? Icon(
                                                  Icons.person,
                                                  color: Colors.white,
                                                )
                                                : null,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              post.username,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color:
                                                    isDarkMode
                                                        ? Colors.white
                                                        : Colors.black87,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              post.content,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color:
                                                    isDarkMode
                                                        ? Colors.white60
                                                        : Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (companies.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Companies",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ...companies.map(
                              (company) => InkWell(
                                onTap: () {
                                  if (company.id != null) {
                                    context.push('/company-visitor/${company.id}');
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 12.0,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            company.logo != null
                                                ? NetworkImage(company.logo!)
                                                : null,
                                        backgroundColor: Colors.grey[300],
                                        child:
                                            company.logo == null
                                                ? Icon(
                                                  Icons.business,
                                                  color: Colors.white,
                                                )
                                                : null,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          company.name.isNotEmpty ? company.name : 'Unnamed Company',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16.sp,
                                            color:
                                                isDarkMode
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],

                          if (searchState.isLoading &&
                              (posts.isNotEmpty || companies.isNotEmpty))
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
      ),
    );
  }
}
