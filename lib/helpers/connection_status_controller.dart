import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'supabase_connection_status.dart';

/// Describes the current combined connection state
enum ConnectionStatus {
  disconnected, // no internet
  supabaseOffline, // internet ok, supabase unreachable
  connected, // all ok
}

/// Provides a high-level connection status by combining:
/// - internet availability
/// - supabase connection status
/// - operator session activity
class ConnectionStatusController extends ChangeNotifier {
  final InternetConnection internetChecker;
  final SupabaseConnectionStatus supabaseStatus;

  final bool _ownsSupabaseStatus;

  late final StreamSubscription _internetSub;

  bool _hasInternet = false;
  ConnectionStatus _state = ConnectionStatus.disconnected;
  ConnectionStatus get state => _state;

  ConnectionStatusController({
    InternetConnection? internetChecker,
    SupabaseConnectionStatus? supabaseStatus,
  })  : internetChecker =
            internetChecker ?? InternetConnection.createInstance(),
        supabaseStatus = supabaseStatus ?? SupabaseConnectionStatus(),
        _ownsSupabaseStatus = supabaseStatus == null {
    _internetSub = this.internetChecker.onStatusChange.listen((status) {
      _hasInternet = status == InternetStatus.connected;
      _evaluate();
    });

    this.supabaseStatus.addListener(_evaluate);
    _evaluate();
  }

  void initSupabaseStatusCheck(String supabaseURL, String supabaseKey) {
    supabaseStatus.init(supabaseURL, supabaseKey);
  }

  void _evaluate() {
    ConnectionStatus newState;
    if (!_hasInternet) {
      newState = ConnectionStatus.disconnected;
    } else if (!supabaseStatus.canReachSupabase) {
      newState = ConnectionStatus.supabaseOffline;
    } else {
      newState = ConnectionStatus.connected;
    }

    if (newState != _state) {
      _state = newState;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _internetSub.cancel();
    supabaseStatus.removeListener(_evaluate);
    if (_ownsSupabaseStatus) {
      supabaseStatus.dispose();
    }
    super.dispose();
  }
}
