import 'package:flutter/foundation.dart';
import 'package:lockedin/features/networks/model/suggestion_model.dart';
import 'package:lockedin/features/networks/repository/network_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum SuggestionViewState { initial, loading, loaded, error }

class SuggestionViewModel extends ChangeNotifier {
  final SuggestionService suggestionService;

  SuggestionViewState _state = SuggestionViewState.initial;
  SuggestionList? _suggestionList;
  SuggestionList? _allSuggestionList;
  String? _errorMessage;
  bool _hasMoreSuggestions = false;
  bool _isLoadingMore = false;
  
  // Set of pending connection request IDs
  Set<String> _pendingConnectionIds = {};
  
  // Number of suggestions to show initially
  final int initialDisplayCount = 6;
  
  // Should we load more data when expanding
  bool get shouldLoadMoreOnExpand => _allSuggestionList == null && _hasMoreSuggestions;

  SuggestionViewModel({SuggestionService? suggestionService})
      : suggestionService = suggestionService ?? SuggestionService() {
    // Load pending connection IDs from storage
    _loadPendingConnections();
  }

  // Getters
  SuggestionViewState get state => _state;
  SuggestionList? get suggestionList => _suggestionList;
  int get suggestionCount => _suggestionList?.suggestions.length ?? 0;
  List<Suggestion> get suggestions => _allSuggestionList?.suggestions ?? _suggestionList?.suggestions ?? [];
  String? get errorMessage => _errorMessage;
  bool get hasMoreSuggestions => _hasMoreSuggestions;
  bool get isLoadingMore => _isLoadingMore;
  Set<String>? get pendingConnectionIds => _pendingConnectionIds.isNotEmpty ? _pendingConnectionIds : null;

  // Load pending connections from shared preferences
  Future<void> _loadPendingConnections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingConnections = prefs.getStringList('pending_connections');
      if (pendingConnections != null) {
        _pendingConnectionIds = Set<String>.from(pendingConnections);
      }
    } catch (e) {
      print('Error loading pending connections: $e');
    }
  }

  // Save pending connections to shared preferences
  Future<void> _savePendingConnections() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('pending_connections', _pendingConnectionIds.toList());
    } catch (e) {
      print('Error saving pending connections: $e');
    }
  }

  // Fetch initial suggestions
  Future<void> fetchSuggestions() async {
    _state = SuggestionViewState.loading;
    notifyListeners();

    try {
      _suggestionList = await suggestionService.getSuggestions(limit: initialDisplayCount);
      _hasMoreSuggestions = _suggestionList!.length > initialDisplayCount; // Assuming API returns total count
      _state = SuggestionViewState.loaded;
    } catch (e) {
      _state = SuggestionViewState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  // Load all suggestions when expanding the list
  Future<void> loadAllSuggestions() async {
    if (_isLoadingMore || _allSuggestionList != null) return;
    
    _isLoadingMore = true;
    notifyListeners();

    try {
      _allSuggestionList = await suggestionService.getSuggestions(limit: 50); // Use a larger limit
      _hasMoreSuggestions = false; // We've loaded all suggestions
    } catch (e) {
      _errorMessage = 'Failed to load more suggestions: ${e.toString()}';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> sendConnectionRequest(String suggestionId) async {
    try {
      await suggestionService.sendConnectionRequest(suggestionId);
      
      // Add to pending connections
      _pendingConnectionIds.add(suggestionId);
      await _savePendingConnections();
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      // Re-throw to allow the UI to handle it
      throw e;
    }
  }
  
  // Method to check if a connection request is pending
  bool isConnectionPending(String suggestionId) {
    return _pendingConnectionIds.contains(suggestionId);
  }
}