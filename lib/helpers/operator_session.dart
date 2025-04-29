import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'operator_session_controller.dart';
import 'logger_helper.dart';

/// Centralized operator session store
class OperatorSession extends OperatorSessionController {
  static final OperatorSession _instance = OperatorSession._internal();
  factory OperatorSession() => _instance;
  OperatorSession._internal();

  String? _name;
  bool _isAdmin = false;
  bool _isActive = false;
  String? _currentUserId;

  @override
  String? get name => _name;
  @override
  bool get isAdmin => _isAdmin;
  @override
  bool get isActive => _isActive;
  @override
  String? get currentUserId => _currentUserId;

  RealtimeChannel? _channel;

  /// Initialize session once if already signed in
  @override
  Future<void> init() async {
    Supabase.instance.client.auth.onAuthStateChange.listen(_handleAuthChange);

    if (Supabase.instance.client.auth.currentSession != null) {
      await _loadFromSupabase();
    } else {
      _clear();
    }
  }

  /// Handle Supabase auth state changes
  Future<void> _handleAuthChange(AuthState data) async {
    final event = data.event;
    final session = data.session;

    if (session == null || event == AuthChangeEvent.signedOut) {
      logInfo('User not logged');
      _clear();
      return;
    } else if (_currentUserId != session.user.id) {
      logInfo('User changed: "$_currentUserId" <> "${session.user.id}"');
      _clear();
    }
    if (event == AuthChangeEvent.signedIn ||
        event == AuthChangeEvent.tokenRefreshed) {
      await _loadFromSupabase();
    }
  }

  /// Load operator profile from Supabase RPC function
  Future<void> _loadFromSupabase() async {
    try {
      final result = await Supabase.instance.client
          .rpc('get_my_operator_profile')
          .single();

      _currentUserId = Supabase.instance.client.auth.currentUser?.id;
      _name = result['name'] as String?;
      _isAdmin = result['is_admin'] == true;
      _isActive = result['active'] == true;

      notifyListeners();

      logInfo('User "$_name" logged: data retrieved');
      _subscribeToOperatorChanges(_currentUserId!);
    } catch (error, stackTrace) {
      logError(
        'Error updating user data',
        error,
        stackTrace,
        'Login',
      );
      _clear();
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
            _name = payload.newRecord['name'] as String?;
            _isAdmin = payload.newRecord['is_admin'] == true;
            _isActive = payload.newRecord['active'] == true;

            logInfo(
                'Data changed for user "$_name" (was ${payload.oldRecord['name']})');
            notifyListeners();
          },
        )
        .subscribe();
  }

  /// Clear session data
  void _clear() {
    _name = null;
    _isAdmin = false;
    _isActive = false;
    _currentUserId = null;
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
