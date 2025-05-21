import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/helpers/logger_helper.dart';

/// Centralized operator session store
class OperatorSession extends OperatorSessionController {
  static final OperatorSession _instance = OperatorSession._internal();
  factory OperatorSession() => _instance;
  OperatorSession._internal();

  bool _initialized = false;

  String? _currentAuthID;

  String? _currentOperatorID;
  String? _firstName;
  String? _lastName;
  String? _nickname;
  bool _isAdmin = false;
  bool _isActive = false;

  RealtimeChannel? _channel;

  @override
  bool get initialized => _initialized;

  @override
  String? get currentOperatorID => _currentOperatorID;

  @override
  String? get firstName => _firstName;

  @override
  String? get lastName => _lastName;

  @override
  String? get nickname => _nickname;

  @override
  bool get isAdmin => _isAdmin;

  @override
  bool get isActive => _isActive;

  @override
  bool get isConnected =>
      _initialized &&
      _currentAuthID == Supabase.instance.client.auth.currentUser?.id &&
      _currentOperatorID?.isNotEmpty == true;

  /// Initialize session once if already signed in
  @override
  Future<void> init() async {
    _initialized = true;
    if (Supabase.instance.client.auth.currentSession != null) {
      await _loadFromSupabase();
    } else {
      _clear();
    }
    Supabase.instance.client.auth.onAuthStateChange.listen(_handleAuthChange);
  }

  /// Handle Supabase auth state changes
  Future<void> _handleAuthChange(AuthState data) async {
    final event = data.event;
    final session = data.session;

    if (session == null || event == AuthChangeEvent.signedOut) {
      logInfo('User not logged');
      _clear();
      return;
    } else if (_currentAuthID != session.user.id) {
      logInfo('User changed: "$_currentAuthID" <> "${session.user.id}"');
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

      _currentAuthID = Supabase.instance.client.auth.currentUser?.id;
      _currentOperatorID = result['id'] as String?;
      _firstName = result['first_name'] as String?;
      _lastName = result['last_name'] as String?;
      _nickname = result['nickname'] as String?;
      _isAdmin = result['is_admin'] == true;
      _isActive = result['active'] == true;

      notifyListeners();

      logInfo('User "$name" logged: data retrieved');
      _subscribeToOperatorChanges(_currentAuthID!);
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
  void _subscribeToOperatorChanges(String authID) {
    _channel?.unsubscribe();

    _channel = Supabase.instance.client
        .channel('public:operators:user_$authID')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'operators',
          filter: PostgresChangeFilter(
            column: 'auth_user_id',
            type: PostgresChangeFilterType.eq,
            value: authID,
          ),
          callback: (payload) {
            _firstName = payload.newRecord['first_name'] as String?;
            _lastName = payload.newRecord['last_name'] as String?;
            _nickname = payload.newRecord['nickname'] as String?;
            _isAdmin = payload.newRecord['is_admin'] == true;
            _isActive = payload.newRecord['active'] == true;

            logInfo('Data changed for user "$name" '
                '(was ${payload.oldRecord['first_name']} ${payload.oldRecord['last_name']}'
                '${payload.newRecord['nickname']?.isNotEmpty == true ? ' (${payload.newRecord['nickname']})' : ''})');
            notifyListeners();
          },
        )
        .subscribe();
  }

  /// Clear session data
  void _clear() {
    _currentOperatorID = null;
    _currentAuthID = null;
    _firstName = null;
    _lastName = null;
    _nickname = null;
    _isAdmin = false;
    _isActive = false;
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
