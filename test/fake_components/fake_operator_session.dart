import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donor_app/helpers/operator_session_controller.dart';

/// Fake implementation of OperatorSessionController for tests
class FakeOperatorSession extends Fake
    with ChangeNotifier
    implements OperatorSessionController {
  @override
  bool isAdmin;

  @override
  bool isActive;

  @override
  String? name;

  @override
  String? currentUserId;

  FakeOperatorSession({this.name, this.isActive = true, this.isAdmin = false});

  void setState({String? name, bool? active, bool? admin, String? userId}) {
    this.name = name ?? this.name;
    isActive = active ?? isActive;
    isAdmin = admin ?? isAdmin;
    currentUserId = userId ?? currentUserId;
    notifyListeners();
  }

  /// Optional test callbacks for behavioral verification
  void Function() onClear = () {};
  void Function(AuthState data) onHandleAuthChange = (_) {};
  void Function() onInit = () {};
  void Function() onLoadFromSupabase = () {};
  void Function([BuildContext? context]) onLogout = ([BuildContext? _]) {};

  @override
  void clear() => onClear();

  @override
  Future<void> handleAuthChange(AuthState data) async =>
      onHandleAuthChange(data);

  @override
  Future<void> init() async => onInit();

  @override
  Future<void> loadFromSupabase() async => onLoadFromSupabase();

  @override
  Future<void> logout([BuildContext? context]) async => onLogout(context);
}
