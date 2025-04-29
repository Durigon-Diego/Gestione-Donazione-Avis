import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/avis_theme.dart';
import '../helpers/avis_scaffold.dart';
import '../helpers/app_info_controller.dart';
import '../helpers/connection_status_controller.dart';
import '../helpers/operator_session_controller.dart';
import '../helpers/logger_helper.dart';

/// Page shown when an operator is not active
class NotActivePage extends StatefulWidget {
  final AppInfoController appInfo;
  final ConnectionStatusController connectionStatus;
  final OperatorSessionController operatorSession;
  const NotActivePage({
    super.key,
    required this.appInfo,
    required this.connectionStatus,
    required this.operatorSession,
  });

  @override
  State<NotActivePage> createState() => _NotActivePageState();
}

class _NotActivePageState extends State<NotActivePage> {
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
        widget.operatorSession.isActive) {
      logWarning(
          "User '${widget.operatorSession.name}' is not inactive, redirecting");
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
    final bool isAdmin = widget.operatorSession.isAdmin;

    return !_showContent
        ? AvisScaffold(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: widget.operatorSession,
            title: '',
            body: SizedBox.shrink(),
          )
        : AvisScaffold(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: widget.operatorSession,
            title: 'Utente non attivo',
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 60, color: AvisColors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Utente non attivo',
                      style: AvisTheme.errorTextStyle,
                    ),
                    if (!isAdmin) ...{
                      const SizedBox(height: 12),
                      const Text(
                        'Contattare un amministratore per abilitare l\'accesso.',
                        textAlign: TextAlign.center,
                      ),
                    }
                  ],
                ),
              ),
            ),
          );
  }
}
