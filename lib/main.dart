import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'helpers/app_info.dart';
import 'helpers/logger_helper.dart';
import 'helpers/avis_theme.dart';
import 'helpers/operator_session_controller.dart';
import 'helpers/operator_session.dart';
import 'pages/not_active_page.dart';
import 'pages/login_page.dart';
import 'pages/donation_page.dart';
import 'pages/account_page.dart';
import 'pages/operators_page.dart';
import 'pages/donation_days_page.dart';

/// Entry point of the AVIS Donor Management App
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool initialized = false;

  try {
    await appInfo.load();
  } catch (e) {
    logError(
        'Error loading env variables', e, StackTrace.current, 'Initialization');
    runApp(const ErrorApp(error: 'Errore di inizializzazione'));
    initialized = true;
  }

  if (!initialized) {
    try {
      await Supabase.initialize(
        url: appInfo.supabaseUrl,
        anonKey: appInfo.supabaseKey,
      );

      final operatorSession = OperatorSession();
      await operatorSession.init();

      runApp(AvisDonorApp(operatorSession: operatorSession));
    } catch (e) {
      logError('Error initializing Supabase', e, StackTrace.current,
          'Initialization');
      runApp(const ErrorApp(error: 'Errore di connessione'));
    }
  }
}

/// Main application widget
class AvisDonorApp extends StatelessWidget {
  final OperatorSessionController operatorSession;
  const AvisDonorApp({super.key, required this.operatorSession});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated =
        Supabase.instance.client.auth.currentSession != null;

    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: AvisTheme.light,
      debugShowCheckedModeBanner: false,
      title: appInfo.appName,
      home: isAuthenticated
          ? DonationPage(operatorSession: operatorSession)
          : LoginPage(operatorSession: operatorSession),
      routes: {
        '/login': (context) => LoginPage(operatorSession: operatorSession),
        '/not_active': (context) =>
            NotActivePage(operatorSession: operatorSession),
        '/donation': (context) =>
            DonationPage(operatorSession: operatorSession),
        '/account': (context) => AccountPage(operatorSession: operatorSession),
        '/operators': (context) =>
            OperatorsPage(operatorSession: operatorSession),
        '/donations_days': (context) =>
            DonationDaysPage(operatorSession: operatorSession),
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

/// Widget displayed if initialization fails
class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AvisTheme.light,
      title: '${appInfo.appName} - Errore',
      home: Scaffold(
        body: Center(
          child: Text(
            'Errore durante l\'inizializzazione:\n$error',
            style: AvisTheme.errorTextStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
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
