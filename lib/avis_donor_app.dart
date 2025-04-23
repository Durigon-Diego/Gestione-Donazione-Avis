import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'helpers/logger_helper.dart';
import 'helpers/app_info_controller.dart';
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
  final AppInfoController appInfo;
  final ConnectionStatusController connectionStatus;
  final OperatorSessionController? operatorSession;

  const AvisDonorApp({
    super.key,
    required this.appInfo,
    required this.connectionStatus,
    this.operatorSession,
  });

  @override
  State<AvisDonorApp> createState() => _AvisDonorAppState();
}

class _AvisDonorAppState extends State<AvisDonorApp> {
  late final OperatorSessionController operatorSession;
  bool _connectedOnce = false;

  @override
  void initState() {
    super.initState();
    operatorSession = widget.operatorSession ?? OperatorSession();
    widget.connectionStatus.addListener(_handleFirstConnection);
    _handleFirstConnection();
  }

  Future<void> _handleFirstConnection() async {
    if (ConnectionStatus.supabaseOffline == widget.connectionStatus.state) {
      widget.connectionStatus.removeListener(_handleFirstConnection);
      try {
        await Supabase.initialize(
          url: widget.appInfo.supabaseUrl,
          anonKey: widget.appInfo.supabaseKey,
        );

        widget.connectionStatus.initSupabaseStatusCheck();

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
      widget.connectionStatus.removeListener(_handleFirstConnection);
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
              connectionStatus: widget.connectionStatus,
              operatorSession: operatorSession)
          : LoginPage(
              connectionStatus: widget.connectionStatus,
              operatorSession: operatorSession),
      routes: {
        '/login': (context) => LoginPage(
            connectionStatus: widget.connectionStatus,
            operatorSession: operatorSession),
        '/not_active': (context) => NotActivePage(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: operatorSession),
        '/donation': (context) => DonationPage(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: operatorSession),
        '/account': (context) => AccountPage(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: operatorSession),
        '/operators': (context) => OperatorsPage(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: operatorSession),
        '/donations_days': (context) => DonationDaysPage(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
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
