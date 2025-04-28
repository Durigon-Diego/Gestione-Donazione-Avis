import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donor_app/helpers/connection_status_controller.dart';

class FakeConnectionStatusController extends Fake
    with ChangeNotifier
    implements ConnectionStatusController {
  ConnectionStatus _state = ConnectionStatus.connected;

  @override
  ConnectionStatus get state => _state;

  void setState(ConnectionStatus newState) {
    _state = newState;
    notifyListeners();
  }
}
