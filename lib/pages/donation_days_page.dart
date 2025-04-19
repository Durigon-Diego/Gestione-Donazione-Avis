import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/logger_helper.dart';
import '../helpers/avis_scaffold.dart';
import '../helpers/operator_session_controller.dart';

class DonationDaysPage extends StatefulWidget {
  final OperatorSessionController operatorSession;
  const DonationDaysPage({super.key, required this.operatorSession});

  @override
  State<DonationDaysPage> createState() => _DonationDaysPageState();
}

class _DonationDaysPageState extends State<DonationDaysPage> {
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    widget.operatorSession.addListener(_checkRedirect);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRedirect());
  }

  @override
  void dispose() {
    widget.operatorSession.removeListener(_checkRedirect);
    super.dispose();
  }

  void _checkRedirect() {
    _showContent = false;
    if (widget.operatorSession.currentUserId != null &&
        widget.operatorSession.currentUserId ==
            Supabase.instance.client.auth.currentUser?.id &&
        !widget.operatorSession.isAdmin) {
      logWarning(
          "User '${widget.operatorSession.name}' is not an admin, redirecting");
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
        ? AvisScaffold(
            title: '',
            body: SizedBox.shrink(),
            operatorSession: widget.operatorSession,
          )
        : AvisScaffold(
            title: 'Gestione Donazioni',
            body: Center(child: Text('Pagina gestione giornate di donazione')),
            operatorSession: widget.operatorSession,
          );
  }
}
