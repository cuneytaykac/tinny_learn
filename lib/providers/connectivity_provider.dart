import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _hasInternet = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final Connectivity _connectivity = Connectivity();

  bool get hasInternet => _hasInternet;

  ConnectivityProvider() {
    _checkInitialConnection();
  }

  /// Check initial connection status
  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _hasInternet = results.any((result) => result != ConnectivityResult.none);
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking initial connectivity: $e');
      _hasInternet = true; // Assume connected on error
    }
  }

  /// Start monitoring connectivity changes
  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final hasConnection = results.any(
          (result) => result != ConnectivityResult.none,
        );

        if (_hasInternet != hasConnection) {
          _hasInternet = hasConnection;
          debugPrint(
            '🌐 Internet status changed: ${_hasInternet ? "Connected" : "Disconnected"}',
          );
          notifyListeners();
        }
      },
      onError: (error) {
        debugPrint('Error monitoring connectivity: $error');
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
