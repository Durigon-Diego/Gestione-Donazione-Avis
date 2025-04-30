import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:avis_donor_app/helpers/logger_helper.dart';
import 'package:avis_donor_app/helpers/app_info_controller.dart';
import 'package:avis_donor_app/helpers/connection_status_controller.dart';
import 'package:avis_donor_app/helpers/connection_status.dart';
import 'package:avis_donor_app/helpers/operator_session_controller.dart';
import 'package:avis_donor_app/helpers/operator_session.dart';
import 'package:avis_donor_app/helpers/avis_theme.dart';
import 'package:avis_donor_app/pages/not_active_page.dart';
import 'package:avis_donor_app/pages/login_page.dart';
import 'package:avis_donor_app/pages/donation_page.dart';
import 'package:avis_donor_app/pages/account_page.dart';
import 'package:avis_donor_app/pages/operators_page.dart';
import 'package:avis_donor_app/pages/donation_days_page.dart';

/// Main application widget
class AvisDonorApp extends StatefulWidget {
  final AppInfoController appInfo;
  final ConnectionStatusController? connectionStatus;
  final OperatorSessionController? operatorSession;
  final FlutterAuthClientOptions? authOptions;

  const AvisDonorApp(
      {super.key,
      required this.appInfo,
      this.connectionStatus,
      this.operatorSession,
      this.authOptions});

  @override
  State<AvisDonorApp> createState() => _AvisDonorAppState();
}

class _AvisDonorAppState extends State<AvisDonorApp> {
  late final ConnectionStatusController connectionStatus;
  late final OperatorSessionController operatorSession;
  late final FlutterAuthClientOptions authOptions;
  bool _connectedOnce = false;

  @override
  void initState() {
    super.initState();
    connectionStatus =
        widget.connectionStatus ?? ConnectionStatus(appInfo: widget.appInfo);
    operatorSession = widget.operatorSession ?? OperatorSession();
    authOptions = widget.authOptions ?? const FlutterAuthClientOptions();
    connectionStatus.addListener(_handleFirstConnection);
    unawaited(connectionStatus.init());
    _handleFirstConnection();
  }

  Future<void> _handleFirstConnection() async {
    if (ServerStatus.connected == connectionStatus.state) {
      try {
        await Supabase.initialize(
          url: widget.appInfo.supabaseURL,
          anonKey: widget.appInfo.supabaseKey,
          authOptions: authOptions,
        );

        await operatorSession.init();

        logInfo('Operator Session initialized');

        connectionStatus.removeListener(_handleFirstConnection);
        _connectedOnce = true;

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
    if (!_connectedOnce) {
      connectionStatus.removeListener(_handleFirstConnection);
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
          ? DonationPage(
              appInfo: widget.appInfo,
              connectionStatus: connectionStatus,
              operatorSession: operatorSession)
          : LoginPage(
              connectionStatus: connectionStatus,
              operatorSession: operatorSession),
      routes: {
        '/login': (context) => LoginPage(
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/not_active': (context) => NotActivePage(
            appInfo: widget.appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/donation': (context) => DonationPage(
            appInfo: widget.appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/account': (context) => AccountPage(
            appInfo: widget.appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/operators': (context) => OperatorsPage(
            appInfo: widget.appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/donations_days': (context) => DonationDaysPage(
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
