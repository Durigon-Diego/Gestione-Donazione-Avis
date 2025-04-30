import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donor_app/helpers/connection_status_controller.dart';

class FakeConnectionStatus extends ConnectionStatusController {
  ServerStatus _state = ServerStatus.connected;
  int numListener = 0;

  @override
  ServerStatus get state => _state;

  void setState(ServerStatus newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  Future<void> init() async {
    return;
  }

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    ++numListener;
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    --numListener;
  }
}
