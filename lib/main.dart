import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:avis_donor_app/helpers/logger_helper.dart';
import 'package:avis_donor_app/helpers/app_info_controller.dart';
import 'package:avis_donor_app/helpers/app_info.dart';
import 'package:avis_donor_app/helpers/avis_theme.dart';
import 'package:avis_donor_app/avis_donor_app.dart';

/// Allows test override of runApp
void Function(Widget) runAppFunction = runApp;

/// Entry point of the AVIS Donor Management App
Future<void> main({AppInfoController? customAppInfo}) async {
  WidgetsFlutterBinding.ensureInitialized();

  bool haveError = false;

  final appInfo = customAppInfo ?? AppInfo();

  try {
    await appInfo.load();
  } catch (error, stackTrace) {
    logError(
      'Error loading env variables',
      error,
      stackTrace,
      'Initialization',
    );
    runAppFunction(ErrorApp(
      error: 'Errore di inizializzazione',
      appInfo: appInfo,
    ));
    haveError = true;
  }

  if (!haveError) {
    try {
      runAppFunction(AvisDonorApp(appInfo: appInfo));
    } catch (error, stackTrace) {
      logError(
        'Error running main app',
        error,
        stackTrace,
        'Initialization',
      );
      runAppFunction(ErrorApp(
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
