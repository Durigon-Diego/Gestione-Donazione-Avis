import 'package:flutter/material.dart';
import 'package:avis_donation_management/helpers/app_info_controller.dart';
import 'package:avis_donation_management/helpers/connection_status_controller.dart';
import 'package:avis_donation_management/helpers/operator_session_controller.dart';
import 'package:avis_donation_management/components/avis_drawer.dart';
import 'package:avis_donation_management/components/avis_bottom_navigation_bar.dart';

/// Reusable Scaffold with AVIS AppBar, Drawer, and optional BottomNavigationBar
class AvisScaffold extends StatelessWidget {
  final AppInfoController appInfo;
  final ConnectionStatusController connectionStatus;
  final OperatorSessionController operatorSession;
  final String title;
  final Widget body;
  final AvisBottomNavigationBarData? bottomNavData;

  const AvisScaffold({
    super.key,
    required this.appInfo,
    required this.connectionStatus,
    required this.operatorSession,
    required this.title,
    required this.body,
    this.bottomNavData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: AvisDrawer(
        appInfo: appInfo,
        connectionStatus: connectionStatus,
        operatorSession: operatorSession,
      ),
      body: body,
      bottomNavigationBar: bottomNavData != null
          ? AvisBottomNavigationBar(data: bottomNavData!)
          : null,
    );
  }
}
