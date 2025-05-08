import 'package:flutter/material.dart';
import 'package:avis_donation_management/components/protected_pages.dart';

class AccountPage extends ProtectedAvisScaffoldedPage with LoggedCheck {
  const AccountPage({
    super.key,
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  }) : super(
          title: 'Gestione Account',
          body: const Center(child: Text('Pagina gestione account')),
        );
}
