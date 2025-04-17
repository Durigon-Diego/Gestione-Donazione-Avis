import 'package:flutter/material.dart';
import '../helpers/avis_scaffold.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AvisScaffold(
      title: 'Gestione Account',
      body: Center(child: Text('Pagina gestione account')),
    );
  }
}
