import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/logger_helper.dart';
import '../helpers/avis_scaffold.dart';
import '../helpers/operator_session.dart';

class DonationDaysPage extends StatefulWidget {
  const DonationDaysPage({super.key});

  @override
  State<DonationDaysPage> createState() => _DonationDaysPageState();
}

class _DonationDaysPageState extends State<DonationDaysPage> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    OperatorSession.addListener(_checkRedirect);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRedirect());
  }

  @override
  void dispose() {
    OperatorSession.removeListener(_checkRedirect);
    super.dispose();
  }

  void _checkRedirect() {
    _showContent = false;
    if (OperatorSession.currentUserId != null &&
        OperatorSession.currentUserId ==
            Supabase.instance.client.auth.currentUser?.id &&
        !OperatorSession.isAdmin) {
      logWarning("User '${OperatorSession.name}' is not an admin, redirecting");
      final nav =
          context.mounted ? Navigator.of(context) : navigatorKey.currentState;
      nav?.pushNamedAndRemoveUntil('/donation', (_) => false);
    } else {
      _showContent = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_showContent
        ? const AvisScaffold(title: '', body: SizedBox.shrink())
        : const AvisScaffold(
            title: 'Gestione Donazioni',
            body: Center(child: Text('Pagina gestione giornate di donazione')),
          );
  }
}
