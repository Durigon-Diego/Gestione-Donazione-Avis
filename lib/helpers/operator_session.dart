import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'logger_helper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Centralized operator session store
class OperatorSession {
  static String? name;
  static bool isAdmin = false;
  static bool isActive = false;
  static String? currentUserId;

  static final List<VoidCallback> _listeners = [];
  static RealtimeChannel? _channel;

  /// Handle Supabase auth state changes
  static Future<void> handleAuthChange(AuthState data) async {
    final event = data.event;
    final session = data.session;

    if (session == null || event == AuthChangeEvent.signedOut) {
      logInfo('User not logged');
      clear();
      return;
    } else if (currentUserId != session.user.id) {
      logInfo('User changed: "$currentUserId" <> "${session.user.id}"');
      clear();
    }
    if (event == AuthChangeEvent.signedIn ||
        event == AuthChangeEvent.tokenRefreshed) {
      await loadFromSupabase();
    }
  }

  /// Load operator profile from Supabase RPC function
  static Future<void> loadFromSupabase() async {
    try {
      final result = await Supabase.instance.client
          .rpc('get_my_operator_profile')
          .single();

      currentUserId = Supabase.instance.client.auth.currentUser?.id;
      name = result['name'] as String?;
      isAdmin = result['is_admin'] == true;
      isActive = result['active'] == true;

      _notifyListeners();

      logInfo('User "$name" logged: data retrieved');
      _subscribeToOperatorChanges(currentUserId!);
    } catch (e) {
      logError('Error updating user data', e, StackTrace.current, 'Login');
      clear();
    }
  }

  /// Subscribe to real-time changes on the current operator
  static void _subscribeToOperatorChanges(String userId) {
    _channel?.unsubscribe();

    _channel = Supabase.instance.client
        .channel('public:operators:user_$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'operators',
          filter: PostgresChangeFilter(
            column: 'id',
            type: PostgresChangeFilterType.eq,
            value: userId,
          ),
          callback: (payload) {
            name = payload.newRecord['name'] as String?;
            isAdmin = payload.newRecord['is_admin'] == true;
            isActive = payload.newRecord['active'] == true;

            logInfo(
                'Data changed for user "$name" (was ${payload.oldRecord['name']})');
            _notifyListeners();
          },
        )
        .subscribe();
  }

  /// Initialize session once if already signed in
  static Future<void> init() async {
    Supabase.instance.client.auth.onAuthStateChange
        .listen(OperatorSession.handleAuthChange);

    if (Supabase.instance.client.auth.currentSession != null) {
      await loadFromSupabase();
    }
  }

  /// Clear session data
  static void clear() {
    name = null;
    isAdmin = false;
    isActive = false;
    currentUserId = null;
    _channel?.unsubscribe();
    _channel = null;
    logInfo('Cleaned current user informations');
    _notifyListeners();
  }

  /// Sign out and redirect to login
  static Future<void> logout([BuildContext? context]) async {
    await Supabase.instance.client.auth.signOut();
    final nav = context != null && context.mounted
        ? Navigator.of(context)
        : navigatorKey.currentState;
    nav?.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  /// Add a listener for session changes
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a registered listener
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}
