import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/helpers/operator_data.dart';

/// Fake implementation of OperatorSessionController for tests
class FakeOperatorSession extends OperatorSessionController {
  @override
  bool initialized;

  @override
  OperatorData? data;

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
    this.data,
    this.onInit = _defaultOnInit,
    this.onLogout = _defaultOnLogout,
    this.onAddListener = _defaultOnAddListener,
    this.onRemoveListener = _defaultOnRemoveListener,
  });

  void setState({
    bool? initialized,
    OperatorData? data,
  }) {
    this.initialized = initialized ?? this.initialized;
    this.data = data;
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
