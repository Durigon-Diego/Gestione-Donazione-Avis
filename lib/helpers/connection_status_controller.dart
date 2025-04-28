import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'logger_helper.dart';
import 'app_info_controller.dart';

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
  final AppInfoController _appInfo;
  final InternetConnection _internetChecker;

  /// True if there is an internet connection
  bool _hasInternet = false;

  /// True if there is a supabase connection
  bool _canReachSupabase = false;

  /// Final state
  ConnectionStatus _state = ConnectionStatus.disconnected;
  ConnectionStatus get state => _state;

  /// Subscription to internet check
  late final StreamSubscription _internetSub;

  /// WebSocket to supabase check
  WebSocketChannel? _socket;

  /// Timer for periodically checks on supabase
  Timer? _supabaseTimer;

  ConnectionStatusController(
      {required AppInfoController appInfo, InternetConnection? internetChecker})
      : _appInfo = appInfo,
        _internetChecker = internetChecker ??
            InternetConnection.createInstance(
              customCheckOptions: [
                InternetCheckOption(uri: Uri.parse('https://icanhazip.com/')),
                InternetCheckOption(
                  uri:
                      Uri.parse('https://jsonplaceholder.typicode.com/posts/1'),
                ),
                InternetCheckOption(
                  uri: Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1'),
                ),
                InternetCheckOption(uri: Uri.parse('https://ipapi.co/ip')),
                InternetCheckOption(
                    uri: Uri.parse(
                        'https://api.thecatapi.com/v1/images/search')),
              ],
              useDefaultOptions: false,
            );

  Future<void> init() async {
    _hasInternet = await (_internetChecker.internetStatus
        .then((s) => s == InternetStatus.connected));
    _internetSub = _internetChecker.onStatusChange.listen((status) {
      _hasInternet = InternetStatus.connected == status;
      _evaluate();
    });

    _evaluate();
  }

  void _evaluate() {
    final newState = !_hasInternet
        ? ConnectionStatus.disconnected
        : !_canReachSupabase
            ? ConnectionStatus.supabaseOffline
            : ConnectionStatus.connected;

    if (newState == _state) return;

    _state = newState;
    notifyListeners();

    logInfo('New connection status: ${_state.name}');

    _cancelSupabaseTimer();

    if (_state == ConnectionStatus.supabaseOffline) {
      _setRestartSupabaseSocketTimer();
      _restartSupabaseSocket();
    } else if (_state == ConnectionStatus.connected) {
      _setSupabaseCheckTimer();
    }
  }

  Future<void> _restartSupabaseSocket() async {
    try {
      _cleanupSupabaseSocket();
      final uri = Uri(
        scheme: _appInfo.supabaseURL.startsWith('https') ? 'wss' : 'ws',
        host: Uri.parse(_appInfo.supabaseURL).host,
        path: '/realtime/v1',
        queryParameters: {
          'apikey': _appInfo.supabaseKey,
          'vsn': '1.0.0',
        },
      );

      _socket = WebSocketChannel.connect(uri);

      logInfo('Supabase socket created');

      _socket!.stream.listen(
        (data) {
          logTrace("Data received on Supabase socket");
          _setSupabaseState(true);
        },
        onDone: () {
          logTrace("Supabase socket closed");
          _setSupabaseState(false);
        },
        onError: (_) {
          logTrace("Supabase socket error");
          _setSupabaseState(false);
        },
        cancelOnError: true,
      );

      _sendHeartbeatToSupabase();

      logInfo('Listening on Supabase socket');
    } catch (error, stackTrace) {
      logError(
        'Error on Supabase socket creation',
        error,
        stackTrace,
        'Supabase Connection check',
      );

      _setSupabaseState(false);
    }
  }

  Future<void> _checkSupabase() async {
    try {
      if (_socket == null || _socket?.closeCode != null) {
        logWarning('Supabase socket closed');

        _setSupabaseState(false);
        return;
      }

      _sendHeartbeatToSupabase();
    } catch (error, stackTrace) {
      logError(
        'Error on Supabase heartbeat',
        error,
        stackTrace,
        'Supabase Connection check',
      );

      _setSupabaseState(false);
    }
  }

  void _sendHeartbeatToSupabase() {
    logTrace('Sending heartbeat to Supabase socket');

    final ref = DateTime.now().millisecondsSinceEpoch.toString();
    final heartbeatMsg = {
      'event': 'heartbeat',
      'topic': 'phoenix',
      'payload': {},
      'ref': ref,
    };
    _socket!.sink.add(jsonEncode(heartbeatMsg));
  }

  void _cleanupSupabaseSocket() {
    _socket?.sink.close();
    _socket = null;
  }

  void _setSupabaseState(bool connected) {
    if (!connected) {
      _cleanupSupabaseSocket();
    }
    if (_canReachSupabase != connected) {
      _canReachSupabase = connected;
      _evaluate();
    }
  }

  void _setRestartSupabaseSocketTimer() {
    logInfo('Setting Restart Supabase Socket timer');
    _supabaseTimer = Timer.periodic(_internetChecker.checkInterval, (_) {
      _restartSupabaseSocket();
    });
  }

  void _setSupabaseCheckTimer() {
    logInfo('Setting Supabase Check timer');
    _supabaseTimer = Timer.periodic(_internetChecker.checkInterval, (_) {
      _checkSupabase();
    });
  }

  void _cancelSupabaseTimer() {
    _supabaseTimer?.cancel();
    _supabaseTimer = null;
  }

  @override
  void dispose() {
    _cancelSupabaseTimer();
    _cleanupSupabaseSocket();
    _internetSub.cancel();
    super.dispose();
  }
}
