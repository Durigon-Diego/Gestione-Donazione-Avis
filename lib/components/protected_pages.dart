import 'package:flutter/material.dart';
import 'package:avis_donation_management/helpers/logger_helper.dart';
import 'package:avis_donation_management/helpers/app_info_controller.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/components/avis_bottom_navigation_bar.dart';
import 'package:avis_donation_management/components/avis_scaffold.dart';

/// Base class for all protected pages
abstract class ProtectedPage extends StatefulWidget {
  final AppInfoController appInfo;
  final ConnectionStatusController connectionStatus;
  final OperatorSessionController operatorSession;

  const ProtectedPage({
    super.key,
    required this.appInfo,
    required this.connectionStatus,
    required this.operatorSession,
  });

  /// Override this to return the actual page content as an AvisScaffold
  Widget buildContent(BuildContext context);

  /// Called during redirection check. Each mixin can override this to enforce access rules
  @protected
  bool checkAccess(BuildContext context, NavigatorState? nav) => true;

  @override
  State<ProtectedPage> createState() => _ProtectedPageState();
}

/// Shared state for all protected pages
class _ProtectedPageState extends State<ProtectedPage> {
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
    final nav =
        context.mounted ? Navigator.of(context) : navigatorKey.currentState;
    final newValue = widget.checkAccess(context, nav);
    if (_showContent != newValue) {
      setState(() {
        _showContent = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showContent
        ? widget.buildContent(context)
        : AvisScaffold(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: widget.operatorSession,
            title: '',
            body: const SizedBox.shrink(),
          );
  }
}

// Composable mixins for access control

/// Mixin to check if the user is logged in
mixin LoggedCheck on ProtectedPage {
  @override
  bool checkAccess(BuildContext context, NavigatorState? nav) {
    if (!operatorSession.isConnected) {
      logWarning("User '${operatorSession.name}' is not connected");
      nav?.pushNamedAndRemoveUntil('/login', (_) => false);
      return false;
    }
    return super.checkAccess(context, nav);
  }
}

/// Mixin to check if the user is an active operator
mixin ActiveCheck on ProtectedPage {
  @override
  bool checkAccess(BuildContext context, NavigatorState? nav) {
    if (!operatorSession.isActive) {
      logWarning("User '${operatorSession.name}' is not active");
      nav?.pushNamedAndRemoveUntil('/not_active', (_) => false);
      return false;
    }
    return super.checkAccess(context, nav);
  }
}

/// Mixin to check if the user is an admin
mixin AdminCheck on ProtectedPage {
  @override
  bool checkAccess(BuildContext context, NavigatorState? nav) {
    if (!operatorSession.isAdmin) {
      logWarning("User '${operatorSession.name}' is not an admin");
      nav?.pushNamedAndRemoveUntil('/donation', (_) => false);
      return false;
    }
    return super.checkAccess(context, nav);
  }
}

/// Base class for protected pages that always return an AvisScaffold
abstract class ProtectedAvisScaffoldedPage extends ProtectedPage {
  final String title;
  final Widget body;
  final AvisBottomNavigationBarData? bottomNavData;

  const ProtectedAvisScaffoldedPage({
    super.key,
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
    required this.title,
    required this.body,
    this.bottomNavData,
  });

  @override
  Widget buildContent(BuildContext context) {
    return AvisScaffold(
      appInfo: appInfo,
      connectionStatus: connectionStatus,
      operatorSession: operatorSession,
      title: title,
      body: body,
      bottomNavData: bottomNavData,
    );
  }
}
