import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donation_management/helpers/logger_helper.dart';
import 'package:avis_donation_management/helpers/app_info_controller.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/helpers/connection_status.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/helpers/operator_session.dart';
import 'package:avis_donation_management/components/avis_theme.dart';
import 'package:avis_donation_management/pages/not_active_page.dart';
import 'package:avis_donation_management/pages/login_page.dart';
import 'package:avis_donation_management/pages/donation_page.dart';
import 'package:avis_donation_management/pages/account_page.dart';
import 'package:avis_donation_management/pages/operators_page.dart';
import 'package:avis_donation_management/pages/donation_days_page.dart';

Widget Function({
  required AppInfoController appInfo,
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) notActivePageBuilder = ({
  required AppInfoController appInfo,
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) {
  return NotActivePage(
    appInfo: appInfo,
    connectionStatus: connectionStatus,
    operatorSession: operatorSession,
  );
};

Widget Function({
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) loginPageBuilder = ({
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) {
  return LoginPage(
    connectionStatus: connectionStatus,
    operatorSession: operatorSession,
  );
};

Widget Function({
  required AppInfoController appInfo,
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) donationPageBuilder = ({
  required AppInfoController appInfo,
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) {
  return DonationPage(
    appInfo: appInfo,
    connectionStatus: connectionStatus,
    operatorSession: operatorSession,
  );
};

Widget Function({
  required AppInfoController appInfo,
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) accountPageBuilder = ({
  required AppInfoController appInfo,
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) {
  return AccountPage(
    appInfo: appInfo,
    connectionStatus: connectionStatus,
    operatorSession: operatorSession,
  );
};

Widget Function({
  required AppInfoController appInfo,
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) operatorsPageBuilder = ({
  required AppInfoController appInfo,
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) {
  return OperatorsPage(
    appInfo: appInfo,
    connectionStatus: connectionStatus,
    operatorSession: operatorSession,
  );
};

Widget Function({
  required AppInfoController appInfo,
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) donationDaysPageBuilder = ({
  required AppInfoController appInfo,
  required ConnectionStatusController connectionStatus,
  required OperatorSessionController operatorSession,
}) {
  return DonationDaysPage(
    appInfo: appInfo,
    connectionStatus: connectionStatus,
    operatorSession: operatorSession,
  );
};

/// Main application widget
class AvisDonationManagementApp extends StatefulWidget {
  final AppInfoController appInfo;
  final ConnectionStatusController? connectionStatus;
  final OperatorSessionController? operatorSession;
  final FlutterAuthClientOptions? authOptions;

  const AvisDonationManagementApp(
      {super.key,
      required this.appInfo,
      this.connectionStatus,
      this.operatorSession,
      this.authOptions});

  @override
  State<AvisDonationManagementApp> createState() =>
      _AvisDonationManagementAppState();
}

class _AvisDonationManagementAppState extends State<AvisDonationManagementApp> {
  late final ConnectionStatusController connectionStatus;
  late final OperatorSessionController operatorSession;
  late final FlutterAuthClientOptions authOptions;
  bool _connectedOnce = false;
  bool _listenerCreated = false;

  @override
  void initState() {
    super.initState();
    connectionStatus =
        widget.connectionStatus ?? ConnectionStatus(appInfo: widget.appInfo);
    operatorSession = widget.operatorSession ?? OperatorSession();
    authOptions = widget.authOptions ?? const FlutterAuthClientOptions();
    unawaited(initStateAsync());
  }

  Future<void> initStateAsync() async {
    await connectionStatus.init();
    await _handleFirstConnection();
    if (!_connectedOnce) {
      connectionStatus.addListener(_handleFirstConnection);
      _listenerCreated = true;
    }
  }

  Future<void> _handleFirstConnection() async {
    if (ServerStatus.connected == connectionStatus.state && !_connectedOnce) {
      try {
        await Supabase.initialize(
          url: widget.appInfo.supabaseURL,
          anonKey: widget.appInfo.supabaseKey,
          authOptions: authOptions,
        );
        _connectedOnce = true;

        await operatorSession.init();

        logInfo('Operator Session initialized');

        if (_listenerCreated) {
          connectionStatus.removeListener(_handleFirstConnection);
          _listenerCreated = false;
        }

        setState(() {});

        logInfo('App is ready');
      } catch (error, stackTrace) {
        logError(
          'Error initializing Operator Session',
          error,
          stackTrace,
          'Initialization',
        );
      }
    }
  }

  @override
  void dispose() {
    if (_listenerCreated) {
      connectionStatus.removeListener(_handleFirstConnection);
      _listenerCreated = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: AvisTheme.light,
      debugShowCheckedModeBanner: false,
      title: widget.appInfo.appName,
      home: operatorSession.isConnected
          ? donationPageBuilder(
              appInfo: widget.appInfo,
              connectionStatus: connectionStatus,
              operatorSession: operatorSession)
          : loginPageBuilder(
              connectionStatus: connectionStatus,
              operatorSession: operatorSession),
      routes: {
        '/login': (context) => loginPageBuilder(
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/not_active': (context) => notActivePageBuilder(
            appInfo: widget.appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/donation': (context) => donationPageBuilder(
            appInfo: widget.appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/account': (context) => accountPageBuilder(
            appInfo: widget.appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/operators': (context) => operatorsPageBuilder(
            appInfo: widget.appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/donations_days': (context) => donationDaysPageBuilder(
            appInfo: widget.appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('it'), // italiano
      ],
    );
  }
}
