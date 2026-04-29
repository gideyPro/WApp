import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connectivity checker service
class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _initialize();
  }

  /// Stream of connection status
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// Initialize connectivity listener
  Future<void> _initialize() async {
    // Check initial status
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);

    // Listen for changes
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  /// Update connection status from connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final isConnected = results.isNotEmpty &&
        !results.every((result) => result == ConnectivityResult.none);
    _connectionStatusController.add(isConnected);
  }

  /// Check if currently connected
  Future<bool> isConnected() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty &&
        !results.every((result) => result == ConnectivityResult.none);
  }

  /// Dispose resources
  void dispose() {
    _connectionStatusController.close();
  }
}
