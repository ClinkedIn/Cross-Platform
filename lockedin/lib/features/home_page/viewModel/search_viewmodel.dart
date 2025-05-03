import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lockedin/features/company/model/company_model.dart';
import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/home_page/repository/search_repository.dart';
import 'package:lockedin/features/home_page/state/search_state.dart';

// Search view model
class SearchViewModel extends StateNotifier<SearchState> {
  final SearchRepository repository;

  SearchViewModel(this.repository) : super(SearchState.initial());

  Future<void> searchPosts(String keyword) async {
    if (keyword.trim().isEmpty) {
      state = state.copyWith(
        showResults: false,
        searchResults: [],
        keyword: '',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      keyword: keyword,
      showResults: true,
    );

    try {
      final result = await repository.searchPosts(keyword);
      final posts = result['posts'] as List<PostModel>;

      state = state.copyWith(
        searchResults: posts,
        isLoading: false,
        pagination: result['pagination'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load posts',
      );
    }
  }

  Future<void> searchCompanies(String keyword) async {
    if (keyword.trim().isEmpty) {
      state = state.copyWith(
        showResults: false,
        companyResults: [],
        keyword: '',
      );
      return;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      keyword: keyword,
      showResults: true,
    );

    try {
      final result = await repository.searchCompanies(keyword);
      final companies = result['companies'] as List<Company>;

      state = state.copyWith(
        companyResults: companies,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load companies',
      );
    }
  }

  Future<void> loadMoreResults() async {
    if (state.isLoading) return;

    final currentPage = state.pagination['page'] as int;
    final totalPages = state.pagination['pages'] as int;

    if (currentPage >= totalPages) return;

    state = state.copyWith(isLoading: true);

    try {
      final result = await repository.searchPosts(
        state.keyword,
        page: currentPage + 1,
      );

      final newPosts = result['posts'] as List<PostModel>;

      state = state.copyWith(
        searchResults: [...state.searchResults, ...newPosts],
        isLoading: false,
        pagination: result['pagination'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more results',
      );
    }
  }

  void hideResults() {
    state = state.copyWith(showResults: false);
  }

  void showResults() {
    if (state.keyword.isNotEmpty) {
      state = state.copyWith(showResults: true);
    }
  }

  void clearSearch() {
    state = SearchState.initial();
  }
}

// Providers
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository();
});

final searchViewModelProvider = StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return SearchViewModel(repository);
});