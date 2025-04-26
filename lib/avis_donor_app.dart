import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'helpers/logger_helper.dart';
import 'helpers/app_info_controller.dart';
import 'helpers/app_info.dart';
import 'helpers/connection_status_controller.dart';
import 'helpers/operator_session_controller.dart';
import 'helpers/operator_session.dart';
import 'helpers/avis_theme.dart';
import 'pages/not_active_page.dart';
import 'pages/login_page.dart';
import 'pages/donation_page.dart';
import 'pages/account_page.dart';
import 'pages/operators_page.dart';
import 'pages/donation_days_page.dart';

/// Main application widget
class AvisDonorApp extends StatefulWidget {
  final AppInfoController? appInfo;
  final ConnectionStatusController? connectionStatus;
  final OperatorSessionController? operatorSession;

  const AvisDonorApp({
    super.key,
    this.appInfo,
    this.connectionStatus,
    this.operatorSession,
  });

  @override
  State<AvisDonorApp> createState() => _AvisDonorAppState();
}

class _AvisDonorAppState extends State<AvisDonorApp> {
  late final AppInfoController appInfo;
  late final ConnectionStatusController connectionStatus;
  late final OperatorSessionController operatorSession;
  bool _connectedOnce = false;

  @override
  void initState() {
    super.initState();
    appInfo = widget.appInfo ?? AppInfo();
    connectionStatus = widget.connectionStatus ?? ConnectionStatusController();
    operatorSession = widget.operatorSession ?? OperatorSession();
    connectionStatus.addListener(_handleFirstConnection);
    _handleFirstConnection();
  }

  Future<void> _handleFirstConnection() async {
    if (ConnectionStatus.supabaseOffline == connectionStatus.state) {
      connectionStatus.removeListener(_handleFirstConnection);
      try {
        connectionStatus.initSupabaseStatusCheck(
            appInfo.supabaseURL, appInfo.supabaseKey);

        await operatorSession.init();

        _connectedOnce = true;
      } catch (e) {
        logError('Error initializing Supabase', e, StackTrace.current,
            'Initialization');
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
      title: appInfo.appName,
      home: operatorSession.isConnected
          ? DonationPage(
              appInfo: appInfo,
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
            appInfo: appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/donation': (context) => DonationPage(
            appInfo: appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/account': (context) => AccountPage(
            appInfo: appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/operators': (context) => OperatorsPage(
            appInfo: appInfo,
            connectionStatus: connectionStatus,
            operatorSession: operatorSession),
        '/donations_days': (context) => DonationDaysPage(
            appInfo: appInfo,
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
