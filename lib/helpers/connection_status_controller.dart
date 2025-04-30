import 'dart:async';

import 'package:flutter/foundation.dart';

/// Describes the current combined connection state
enum ServerStatus {
  disconnected, // no internet
  supabaseOffline, // internet ok, supabase unreachable
  connected, // all ok
}

/// Provides a high-level connection status by combining:
/// - internet availability
/// - supabase connection status
abstract class ConnectionStatusController extends ChangeNotifier {
  ServerStatus get state;

  Future<void> init();
}
