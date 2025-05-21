import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';

/// Fake implementation of OperatorSessionController for tests
class FakeOperatorSession extends OperatorSessionController {
  @override
  bool initialized;

  @override
  String? currentOperatorID;

  @override
  String? firstName;

  @override
  String? lastName;

  @override
  String? nickname;

  @override
  bool isAdmin;

  @override
  bool isActive;

  int _numListener = 0;
  int get numListener => _numListener;

  /// Optional test callbacks for behavioral verification
  void Function() onInit;
  void Function([BuildContext? context]) onLogout;
  void Function(VoidCallback callback, int numListener) onAddListener;
  void Function(VoidCallback callback, int numListener) onRemoveListener;

  /// DEfault empty callbacks
  static void _defaultOnInit() {}
  static void _defaultOnLogout([BuildContext? _]) {}
  static void _defaultOnAddListener(VoidCallback _, int __) {}
  static void _defaultOnRemoveListener(VoidCallback _, int __) {}

  FakeOperatorSession({
    this.initialized = false,
    this.currentOperatorID,
    this.firstName,
    this.lastName,
    this.nickname,
    this.isAdmin = false,
    this.isActive = true,
    this.onInit = _defaultOnInit,
    this.onLogout = _defaultOnLogout,
    this.onAddListener = _defaultOnAddListener,
    this.onRemoveListener = _defaultOnRemoveListener,
  });

  void setState({
    bool? initialized,
    String? currentOperatorID,
    String? firstName,
    String? lastName,
    String? nickname,
    bool isAdmin = false,
    bool isActive = true,
  }) {
    this.initialized = initialized ?? this.initialized;
    this.currentOperatorID = currentOperatorID;
    this.firstName = firstName;
    this.lastName = lastName;
    this.nickname = nickname;
    this.isAdmin = isAdmin;
    this.isActive = isActive;
    notifyListeners();
  }

  @override
  Future<void> init() async {
    initialized = true;
    onInit();
  }

  @override
  Future<void> logout([BuildContext? context]) async => onLogout(context);

  @override
  void addListener(VoidCallback listener) {
    ++_numListener;
    onAddListener(listener, _numListener);
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    --_numListener;
    onRemoveListener(listener, _numListener);
    super.removeListener(listener);
  }
}
