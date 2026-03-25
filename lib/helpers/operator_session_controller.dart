import 'package:flutter/material.dart';
import 'package:avis_donation_management/helpers/operator_data.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Abstract interface for operator session
abstract class OperatorSessionController extends ChangeNotifier {
  bool get initialized;

  OperatorData? get data;

  bool get isConnected => data != null;
  bool get isAdmin => data?.isAdmin ?? false;
  bool get isActive => data?.isActive ?? false;

  String? get name => data?.name;

  Future<void> init();
  Future<void> logout([BuildContext? context]);
}
