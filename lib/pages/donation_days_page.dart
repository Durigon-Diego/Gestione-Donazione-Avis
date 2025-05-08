import 'package:flutter/material.dart';
import 'package:avis_donation_management/components/protected_pages.dart';

class DonationDaysPage extends ProtectedAvisScaffoldedPage
    with LoggedCheck, ActiveCheck, AdminCheck {
  const DonationDaysPage({
    super.key,
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  }) : super(
          title: 'Gestione Donazioni',
          body: const Center(
              child: Text('Pagina gestione giornate di donazione')),
        );
}
