import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/notifiers/error_notifier.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:frontend/locator.dart';
import 'package:frontend/services/auth_service.dart';

class ConnectivityService with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  bool _isConnected = true;
  bool _hasConnectionToBackend = true;

  Stream<bool> get connectionStream => _connectionStatusController.stream;
  bool get isConnected => _isConnected;
  bool get hasConnectionToBackend => _hasConnectionToBackend;

  ConnectivityService() {
    _checkInitialConnectivity();
    _connectivity.onConnectivityChanged.listen(_handleConnectivityChange);
  }

  Future<void> _checkInitialConnectivity() async {
    var connectivityResult = await (_connectivity.checkConnectivity());
    _handleConnectivityChange(connectivityResult);
  }

  void _handleConnectivityChange(List<ConnectivityResult> result) {
    final newIsConnected = result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi) ||
        result.contains(ConnectivityResult.ethernet);

    if (_isConnected != newIsConnected) {
      _isConnected = newIsConnected;
      _connectionStatusController.add(_isConnected);
    }
  }

  Future<bool> checkConnectivity() async {
    var connectivityResult = await (_connectivity.checkConnectivity());
    _handleConnectivityChange(connectivityResult);
    return _isConnected;
  }

  Future<bool> checkConnectivityToBackend({BuildContext? context}) async {
    bool previousConnectionToBackend = _hasConnectionToBackend;
    if (!await checkConnectivity()) {
      _hasConnectionToBackend = false;
      if (context != null && context.mounted) {
        ErrorNotifier.show(
          context: context,
          message: AppLocalizations.of(context)!.noInternetConnection,
          showOnTop: false,
        );
      }
    } else {
      final AuthService authService = locator<AuthService>();
      final response = await authService.authenticatedRequest(
        method: 'GET',
        endpoint: 'users/me/',
      );

      if (response == null) {
        _hasConnectionToBackend = false;
        if (context != null && context.mounted) {
          ErrorNotifier.show(
            context: context,
            message: AppLocalizations.of(context)!.cannotAccessBackend,
            showOnTop: false,
          );
        }
      } else if (response.statusCode >= 200 && response.statusCode < 500) {
        _hasConnectionToBackend = true;
      } else {
        _hasConnectionToBackend = false;
        if (context != null && context.mounted) {
          ErrorNotifier.show(
            context: context,
            message: '${AppLocalizations.of(context)!.badRequest}: ${response.statusCode}',
            showOnTop: false,
          );
        }
      }
    }
    if (previousConnectionToBackend != _hasConnectionToBackend) {
      notifyListeners();
    }
    return _hasConnectionToBackend;
  }

  void dispose() {
    _connectionStatusController.close();
  }
}
