import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'helpers/logger_helper.dart';
import 'helpers/app_info_controller.dart';
import 'helpers/app_info.dart';
import 'helpers/connection_status_controller.dart';
import 'helpers/avis_theme.dart';
import 'avis_donor_app.dart';

/// Entry point of the AVIS Donor Management App
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool haveError = false;

  final appInfo = AppInfo();

  try {
    await appInfo.load();
  } catch (e) {
    logError(
        'Error loading env variables', e, StackTrace.current, 'Initialization');
    runApp(ErrorApp(
      error: 'Errore di inizializzazione',
      appInfo: appInfo,
    ));
    haveError = true;
  }

  if (!haveError) {
    try {
      // Create connection controller before Supabase
      final connectionStatusController = ConnectionStatusController();

      // await Supabase.initialize(
      //   url: appInfo.supabaseUrl,
      //   anonKey: appInfo.supabaseKey,
      // );

      // final operatorSession = OperatorSession();
      // await operatorSession.init();

      runApp(AvisDonorApp(
        appInfo: appInfo,
        connectionStatus: connectionStatusController,
      ));
    } catch (e) {
      // logError('Error initializing Supabase', e, StackTrace.current,
      //     'Initialization');
      logError(
          'Error running main app', e, StackTrace.current, 'Initialization');
      runApp(ErrorApp(
        error: 'Errore di avvio',
        appInfo: appInfo,
      ));
    }
  }
}

/// Widget displayed if initialization fails
class ErrorApp extends StatelessWidget {
  final String error;
  final AppInfoController appInfo;
  const ErrorApp({
    super.key,
    required this.error,
    required this.appInfo,
  });

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
