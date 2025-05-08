import 'package:flutter/material.dart';
import 'package:avis_donation_management/components/protected_pages.dart';

class OperatorsPage extends ProtectedAvisScaffoldedPage
    with LoggedCheck, ActiveCheck, AdminCheck {
  const OperatorsPage({
    super.key,
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  }) : super(
          title: 'Gestione Operatori',
          body: const Center(child: Text('Pagina gestione operatori')),
        );
}
