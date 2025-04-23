import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Abstract interface for operator session
abstract class OperatorSessionController extends ChangeNotifier {
  String? get name;
  bool get isAdmin;
  bool get isActive;
  String? get currentUserId;

  bool get isConnected => currentUserId != null;

  Future<void> init();
  Future<void> handleAuthChange(AuthState data);
  Future<void> loadFromSupabase();
  void clear();
  Future<void> logout([BuildContext? context]);
}
