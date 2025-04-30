import 'package:flutter/material.dart';
import 'package:avis_donation_management/helpers/app_info_controller.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/components/avis_scaffold.dart';

class AccountPage extends StatelessWidget {
  final AppInfoController appInfo;
  final ConnectionStatusController connectionStatus;
  final OperatorSessionController operatorSession;
  const AccountPage({
    super.key,
    required this.appInfo,
    required this.connectionStatus,
    required this.operatorSession,
  });

  @override
  Widget build(BuildContext context) {
    return AvisScaffold(
      appInfo: appInfo,
      connectionStatus: connectionStatus,
      operatorSession: operatorSession,
      title: 'Gestione Account',
      body: const Center(child: Text('Pagina gestione account')),
    );
  }
}
