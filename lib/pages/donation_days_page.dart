import 'package:flutter/material.dart';
import 'package:avis_donation_management/helpers/logger_helper.dart';
import 'package:avis_donation_management/helpers/app_info_controller.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/components/avis_scaffold.dart';

class DonationDaysPage extends StatefulWidget {
  final AppInfoController appInfo;
  final ConnectionStatusController connectionStatus;
  final OperatorSessionController operatorSession;
  const DonationDaysPage({
    super.key,
    required this.appInfo,
    required this.connectionStatus,
    required this.operatorSession,
  });

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
    if (widget.operatorSession.isConnected && !widget.operatorSession.isAdmin) {
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
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: widget.operatorSession,
            title: '',
            body: const SizedBox.shrink(),
          )
        : AvisScaffold(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: widget.operatorSession,
            title: 'Gestione Donazioni',
            body: const Center(
                child: Text('Pagina gestione giornate di donazione')),
          );
  }
}
