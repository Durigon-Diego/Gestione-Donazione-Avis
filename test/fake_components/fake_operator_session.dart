import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';

/// Fake implementation of OperatorSessionController for tests
class FakeOperatorSession extends OperatorSessionController {
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

  FakeOperatorSession({
    this.currentOperatorID,
    this.firstName,
    this.lastName,
    this.nickname,
    this.isActive = true,
    this.isAdmin = false,
  });

  void setState({
    String? currentOperatorID,
    String? firstName,
    String? lastName,
    String? nickname,
    bool isActive = true,
    bool isAdmin = false,
  }) {
    this.currentOperatorID = currentOperatorID;
    this.firstName = firstName;
    this.lastName = lastName;
    this.nickname = nickname;
    this.isActive = isActive;
    this.isAdmin = isAdmin;
    notifyListeners();
  }

  /// Optional test callbacks for behavioral verification
  void Function() onInit = () {};
  void Function([BuildContext? context]) onLogout = ([BuildContext? _]) {};

  @override
  Future<void> init() async => onInit();

  @override
  Future<void> logout([BuildContext? context]) async => onLogout(context);
}
