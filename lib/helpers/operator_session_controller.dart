import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Abstract interface for operator session
abstract class OperatorSessionController extends ChangeNotifier {
  String? get name;
  bool get isAdmin;
  bool get isActive;
  String? get currentUserId;

  Future<void> handleAuthChange(AuthState data);
  Future<void> loadFromSupabase();
  Future<void> init();
  void clear();
  Future<void> logout([BuildContext? context]);
}
