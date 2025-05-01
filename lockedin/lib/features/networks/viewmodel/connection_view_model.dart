import 'package:flutter/foundation.dart';
import 'package:lockedin/features/networks/model/connection_model.dart'; // Adjust import path as needed
import 'package:lockedin/features/networks/repository/network_repository.dart'; // Adjust import path as needed

enum ConnectionViewState { initial, loading, loaded, error }

class ConnectionViewModel extends ChangeNotifier {
  final ConnectionListService connectionService;

  ConnectionViewState _state = ConnectionViewState.initial;
  ConnectionList? _connectionList;
  String? _errorMessage;

  ConnectionViewModel({ConnectionListService? connectionService})
    : connectionService = connectionService ?? ConnectionListService();

  // Getters
  ConnectionViewState get state => _state;
  ConnectionList? get connectionList => _connectionList;
  int get connectionCount => _connectionList?.connections.length ?? 0;
  List<Connection> get connections => _connectionList?.connections ?? [];
  String? get errorMessage => _errorMessage;
  Pagination? get pagination => _connectionList?.pagination;

  Future<void> fetchConnections({int page = 1}) async {
    _state = ConnectionViewState.loading;
    notifyListeners();

    try {
      _connectionList = await connectionService.getConnections(page: page);
      _state = ConnectionViewState.loaded;
    } catch (e) {
      _state = ConnectionViewState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  Future<void> removeConnection(String connectionId) async {
    try {
      await connectionService.removeConnection(connectionId);
      // Remove the connection from local list after removal
      if (_connectionList != null) {
        _connectionList!.connections.removeWhere(
          (connection) => connection.id == connectionId,
        );
        // Update total count in pagination
        if (_connectionList!.pagination != null) {
          _connectionList!.pagination.total -= 1;
        }
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      // Re-throw to allow the UI to handle it
      throw e;
    }
  }

  Future<void> loadNextPage() async {
    if (_connectionList == null || 
        _connectionList!.pagination.page >= _connectionList!.pagination.pages) {
      return; // No more pages to load
    }

    try {
      final nextPage = _connectionList!.pagination.page + 1;
      final nextPageData = await connectionService.getConnections(page: nextPage);
      
      // Append new connections to existing list
      _connectionList!.connections.addAll(nextPageData.connections);
      // Update pagination info
      _connectionList!.pagination = nextPageData.pagination;
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      throw e;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

