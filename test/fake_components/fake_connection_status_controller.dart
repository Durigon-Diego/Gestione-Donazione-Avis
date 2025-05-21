import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';

class FakeConnectionStatus extends ConnectionStatusController {
  @override
  bool initialized;

  @override
  ServerStatus state;

  int _numListener = 0;
  int get numListener => _numListener;

  /// Optional test callbacks for behavioral verification
  void Function() onInit;
  void Function(VoidCallback callback, int numListener) onAddListener;
  void Function(VoidCallback callback, int numListener) onRemoveListener;

  /// DEfault empty callbacks
  static void _defaultOnInit() {}
  static void _defaultOnAddListener(VoidCallback _, int __) {}
  static void _defaultOnRemoveListener(VoidCallback _, int __) {}

  FakeConnectionStatus({
    this.initialized = false,
    this.state = ServerStatus.connected,
    this.onInit = _defaultOnInit,
    this.onAddListener = _defaultOnAddListener,
    this.onRemoveListener = _defaultOnRemoveListener,
  });

  void setState(ServerStatus newState, {bool? initialized}) {
    this.initialized = initialized ?? this.initialized;
    state = newState;
    notifyListeners();
  }

  @override
  Future<void> init() async {
    initialized = true;
    onInit();
  }

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
