import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'operator_session_controller.dart';
import 'logger_helper.dart';

/// Centralized operator session store
class OperatorSession with ChangeNotifier implements OperatorSessionController {
  static final OperatorSession _instance = OperatorSession._internal();
  factory OperatorSession() => _instance;
  OperatorSession._internal();

  @override
  String? name;
  @override
  bool isAdmin = false;
  @override
  bool isActive = false;
  @override
  String? currentUserId;

  RealtimeChannel? _channel;

  /// Handle Supabase auth state changes
  @override
  Future<void> handleAuthChange(AuthState data) async {
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
  @override
  Future<void> loadFromSupabase() async {
    try {
      final result = await Supabase.instance.client
          .rpc('get_my_operator_profile')
          .single();

      currentUserId = Supabase.instance.client.auth.currentUser?.id;
      name = result['name'] as String?;
      isAdmin = result['is_admin'] == true;
      isActive = result['active'] == true;

      notifyListeners();

      logInfo('User "$name" logged: data retrieved');
      _subscribeToOperatorChanges(currentUserId!);
    } catch (e) {
      logError('Error updating user data', e, StackTrace.current, 'Login');
      clear();
    }
  }

  /// Subscribe to real-time changes on the current operator
  void _subscribeToOperatorChanges(String userId) {
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
            notifyListeners();
          },
        )
        .subscribe();
  }

  /// Initialize session once if already signed in
  @override
  Future<void> init() async {
    Supabase.instance.client.auth.onAuthStateChange.listen(handleAuthChange);

    if (Supabase.instance.client.auth.currentSession != null) {
      await loadFromSupabase();
    }
  }

  /// Clear session data
  @override
  void clear() {
    name = null;
    isAdmin = false;
    isActive = false;
    currentUserId = null;
    _channel?.unsubscribe();
    _channel = null;
    logInfo('Cleaned current user informations');
    notifyListeners();
  }

  /// Sign out and redirect to login
  @override
  Future<void> logout([BuildContext? context]) async {
    await Supabase.instance.client.auth.signOut();
    final nav = context != null && context.mounted
        ? Navigator.of(context)
        : navigatorKey.currentState;
    nav?.pushNamedAndRemoveUntil('/login', (_) => false);
  }
}
