import 'package:flutter/material.dart';
import '../helpers/avis_scaffold.dart';
import '../helpers/app_info_controller.dart';
import '../helpers/operator_session_controller.dart';

class AccountPage extends StatelessWidget {
  final AppInfoController appInfo;
  final OperatorSessionController operatorSession;
  const AccountPage({
    super.key,
    required this.appInfo,
    required this.operatorSession,
  });

  @override
  Widget build(BuildContext context) {
    return AvisScaffold(
      appInfo: appInfo,
      operatorSession: operatorSession,
      title: 'Gestione Account',
      body: Center(child: Text('Pagina gestione account')),
    );
  }
}
