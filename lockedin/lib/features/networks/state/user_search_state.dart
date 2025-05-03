import 'package:lockedin/features/networks/model/user_model.dart';

class UserSearchState {
  final List<UserModel> searchResults;
  final bool isLoading;
  final String? error;
  final String keyword;
  final bool showResults;
  final Map<String, dynamic> pagination;
  
  const UserSearchState({
    required this.searchResults,
    required this.isLoading,
    this.error,
    required this.keyword,
    required this.showResults,
    required this.pagination,
  });
  
  factory UserSearchState.initial() {
    return UserSearchState(
      searchResults: [],
      isLoading: false,
      error: null,
      keyword: '',
      showResults: false,
      pagination: {
        'total': 0,
        'page': 1,
        'limit': 10,
        'pages': 0,
        'hasNextPage': false,
        'hasPrevPage': false,
      },
    );
  }
  
  UserSearchState copyWith({
    List<UserModel>? searchResults,
    bool? isLoading,
    String? error,
    String? keyword,
    bool? showResults,
    Map<String, dynamic>? pagination,
  }) {
    return UserSearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      keyword: keyword ?? this.keyword,
      showResults: showResults ?? this.showResults,
      pagination: pagination ?? this.pagination,
    );
  }
}