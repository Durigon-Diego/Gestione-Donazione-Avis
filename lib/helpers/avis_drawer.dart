import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'avis_theme.dart';
import 'app_info_controller.dart';
import 'operator_session_controller.dart';

/// Drawer riutilizzabile con le sezioni AVIS
class AvisDrawer extends StatefulWidget {
  final AppInfoController appInfo;
  final OperatorSessionController operatorSession;
  const AvisDrawer({
    super.key,
    required this.appInfo,
    required this.operatorSession,
  });

  @override
  State<AvisDrawer> createState() => _AvisDrawerState();
}

class DrawerItemData {
  final String title;
  final IconData icon;
  final String route;
  final Color? overrideColorSelected;
  final Color? overrideColorUnselected;

  const DrawerItemData(
    this.title,
    this.icon,
    this.route, {
    this.overrideColorSelected,
    this.overrideColorUnselected,
  });
}

class _AvisDrawerState extends State<AvisDrawer> {
  bool isConnected = Supabase.instance.client.auth.currentSession != null;

  @override
  void initState() {
    super.initState();
    _monitorConnectivity();
    widget.operatorSession.addListener(_onSessionChange);
  }

  @override
  void dispose() {
    widget.operatorSession.removeListener(_onSessionChange);
    super.dispose();
  }

  void _onSessionChange() {
    setState(() {});
  }

  void _monitorConnectivity() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      final hasNetwork = result != ConnectivityResult.none;
      final session = Supabase.instance.client.auth.currentSession;
      setState(() {
        isConnected = hasNetwork && session != null;
      });
    });
  }

  Future<void> _logout() async {
    await widget.operatorSession.logout(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    final userName = widget.operatorSession.name ?? '';
    final userRole =
        widget.operatorSession.isAdmin ? 'Amministratore' : 'Operatore';

    final drawerItems = [
      DrawerItemData('Gestione Account', Icons.account_circle, '/account'),
      if (widget.operatorSession.isActive) ...[
        DrawerItemData('Donazione', Icons.water_drop, '/donation'),
      ] else ...[
        DrawerItemData(
          'Donazione',
          Icons.lock,
          '/not_active',
          overrideColorSelected: AvisColors.red,
          overrideColorUnselected: AvisColors.warmGrey,
        ),
      ],
      if (widget.operatorSession.isAdmin) ...[
        DrawerItemData(
            'Gestione Operatori', Icons.manage_accounts, '/operators'),
        DrawerItemData('Gestione Giornate Donazioni', Icons.calendar_today,
            '/donations_days'),
      ]
    ];
    return Drawer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  color: AvisColors.blue,
                ),
                accountName: Text(userName.isNotEmpty ? userName : '...'),
                accountEmail: Text(userRole),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person, size: 40),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate.fixed([
                ...drawerItems.map((item) {
                  final selected = currentRoute == item.route;
                  final color = selected
                      ? (item.overrideColorSelected ?? AvisColors.green)
                      : (item.overrideColorUnselected ?? AvisColors.blue);
                  return ListTile(
                    leading: Icon(item.icon, color: color),
                    title: Text(item.title, style: TextStyle(color: color)),
                    onTap: () {
                      Navigator.pop(context);
                      if (!selected) {
                        Navigator.of(context).pushReplacementNamed(item.route);
                      }
                    },
                  );
                }),
              ]),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Divider(),
                  ListTile(
                    leading:
                        const Icon(Icons.support_agent, color: AvisColors.blue),
                    title: const Text('Contatti',
                        style: TextStyle(color: AvisColors.blue)),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Contatti'),
                          content: Text(
                              'Per supporto scrivi a: ${widget.appInfo.supportEmail}'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.info_outline, color: AvisColors.blue),
                    title: const Text('Info',
                        style: TextStyle(color: AvisColors.blue)),
                    onTap: () {
                      Navigator.pop(context);
                      showAboutDialog(
                        context: context,
                        applicationName: widget.appInfo.appName,
                        applicationVersion: widget.appInfo.appVersion,
                        applicationIcon: const Icon(Icons.water_drop_outlined),
                        children: [Text(widget.appInfo.appDescription)],
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle,
                          size: 12,
                          color: isConnected
                              ? (widget.operatorSession.isActive
                                  ? AvisColors.green
                                  : AvisColors.amber)
                              : AvisColors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text('Stato connessione',
                            style: AvisTheme.smallTextStyle),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AvisColors.red),
                    title: const Text('Logout'),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }
}
