import 'package:flutter/material.dart';
import 'package:avis_donation_management/components/avis_theme.dart';
import 'package:avis_donation_management/components/protected_pages.dart';

class NotActivePage extends ProtectedAvisScaffoldedPage with LoggedCheck {
  NotActivePage({
    super.key,
    required super.appInfo,
    required super.connectionStatus,
    required super.operatorSession,
  }) : super(
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
                  if (!operatorSession.isAdmin) ...{
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
