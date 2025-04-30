import 'package:flutter/material.dart';
import 'package:avis_donor_app/helpers/avis_scaffold.dart';
import 'package:avis_donor_app/helpers/app_info_controller.dart';
import 'package:avis_donor_app/helpers/connection_status_controller.dart';
import 'package:avis_donor_app/helpers/operator_session_controller.dart';

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
