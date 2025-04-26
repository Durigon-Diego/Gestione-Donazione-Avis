import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Monitors realtime connection status to Supabase backend.
/// It uses only the realtime socket lifecycle to infer connection status.
class SupabaseConnectionStatus extends ChangeNotifier {
  /// True if the realtime websocket connection is established
  bool _canReach = false;
  bool get canReachSupabase => _canReach;

  void init(String supabaseURL, String supabaseKey) async {
    await Supabase.initialize(
      url: supabaseURL,
      anonKey: supabaseKey,
    );

    final socket = Supabase.instance.client.realtime;

    // Check immediate state in case the socket is already connected
    if (socket.isConnected) {
      _updateStatus(true);
    }

    socket.onOpen(() => _updateStatus(true));
    socket.onError((_) => _updateStatus(false));
    socket.onClose((_) => _updateStatus(false));
  }

  void _updateStatus(bool newValue) {
    if (_canReach != newValue) {
      _canReach = newValue;
      notifyListeners();
    }
  }
}
