import 'package:flutter/material.dart';
import '../helpers/avis_scaffold.dart';
import '../helpers/operator_session_controller.dart';

class AccountPage extends StatelessWidget {
  final OperatorSessionController operatorSession;
  const AccountPage({super.key, required this.operatorSession});

  @override
  Widget build(BuildContext context) {
    return AvisScaffold(
      title: 'Gestione Account',
      body: Center(child: Text('Pagina gestione account')),
      operatorSession: operatorSession,
    );
  }
}
