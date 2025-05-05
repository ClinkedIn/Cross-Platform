import 'package:lockedin/features/home_page/model/post_model.dart';
import 'package:lockedin/features/company/model/company_model.dart';

class SearchState {
  final List<PostModel> searchResults;
  final List<Company> companyResults;
  final bool isLoading;
  final String? error;
  final String keyword;
  final bool showResults;
  final Map<String, dynamic> pagination;

  SearchState({
    required this.searchResults,
    required this.companyResults,
    required this.isLoading,
    this.error,
    required this.keyword,
    required this.showResults,
    required this.pagination,
  });

  // Initial state factory
  factory SearchState.initial() => SearchState(
        searchResults: [],
        companyResults: [],
        isLoading: false,
        keyword: '',
        showResults: false,
        pagination: {'total': 0, 'page': 1, 'pages': 0},
      );

  // Copy with method for immutability
  SearchState copyWith({
    List<PostModel>? searchResults,
    List<Company>? companyResults,
    bool? isLoading,
    String? error,
    String? keyword,
    bool? showResults,
    Map<String, dynamic>? pagination,
  }) {
    return SearchState(
      searchResults: searchResults ?? this.searchResults,
      companyResults: companyResults ?? this.companyResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      keyword: keyword ?? this.keyword,
      showResults: showResults ?? this.showResults,
      pagination: pagination ?? this.pagination,
    );
  }
}
