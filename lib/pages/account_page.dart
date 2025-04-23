import 'package:flutter/material.dart';
import '../helpers/avis_scaffold.dart';
import '../helpers/app_info_controller.dart';
import '../helpers/connection_status_controller.dart';
import '../helpers/operator_session_controller.dart';

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
      body: Center(child: Text('Pagina gestione account')),
    );
  }
}
