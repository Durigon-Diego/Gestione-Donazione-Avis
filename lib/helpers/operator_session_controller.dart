import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Abstract interface for operator session
abstract class OperatorSessionController extends ChangeNotifier {
  String? get name;
  bool get isAdmin;
  bool get isActive;
  String? get currentUserId;

  bool get isConnected => currentUserId != null;

  Future<void> init();
  Future<void> logout([BuildContext? context]);
}
