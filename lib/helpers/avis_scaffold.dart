import 'package:flutter/material.dart';
import 'operator_session_controller.dart';
import 'avis_drawer.dart';
import 'avis_bottom_navigation_bar.dart';

/// Reusable Scaffold with AVIS AppBar, Drawer, and optional BottomNavigationBar
class AvisScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final AvisBottomNavigationBarData? bottomNavData;
  final OperatorSessionController operatorSession;

  const AvisScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.operatorSession,
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
        operatorSession: operatorSession,
      ),
      body: body,
      bottomNavigationBar: bottomNavData != null
          ? AvisBottomNavigationBar(data: bottomNavData!)
          : null,
    );
  }
}
