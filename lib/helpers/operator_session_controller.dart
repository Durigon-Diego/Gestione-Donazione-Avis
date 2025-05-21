import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Abstract interface for operator session
abstract class OperatorSessionController extends ChangeNotifier {
  bool get initialized;
  String? get currentOperatorID;
  String? get firstName;
  String? get lastName;
  String? get nickname;
  bool get isAdmin;
  bool get isActive;

  bool get isConnected => currentOperatorID != null;

  String? get name {
    if (firstName == null || lastName == null) return null;
    return nickname?.isNotEmpty == true
        ? '$firstName $lastName ($nickname)'
        : '$firstName $lastName';
  }

  Future<void> init();
  Future<void> logout([BuildContext? context]);
}
