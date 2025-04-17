import 'package:flutter/material.dart';
import 'avis_drawer.dart';
import 'avis_bottom_navigation_bar.dart';

/// Reusable Scaffold with AVIS AppBar, Drawer, and optional BottomNavigationBar
class AvisScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final AvisBottomNavigationBarData? bottomNavData;

  const AvisScaffold({
    super.key,
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
      drawer: const AvisDrawer(),
      body: body,
      bottomNavigationBar: bottomNavData != null
          ? AvisBottomNavigationBar(data: bottomNavData!)
          : null,
    );
  }
}
