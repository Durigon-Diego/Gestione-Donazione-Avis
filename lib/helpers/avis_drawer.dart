import 'package:flutter/material.dart';
import 'package:avis_donor_app/helpers/avis_theme.dart';
import 'package:avis_donor_app/helpers/app_info_controller.dart';
import 'package:avis_donor_app/helpers/connection_status_controller.dart';
import 'package:avis_donor_app/helpers/operator_session_controller.dart';

class AvisDrawer extends StatefulWidget {
  final AppInfoController appInfo;
  final ConnectionStatusController connectionStatus;
  final OperatorSessionController operatorSession;

  const AvisDrawer({
    super.key,
    required this.appInfo,
    required this.connectionStatus,
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
  @override
  void initState() {
    super.initState();
    widget.connectionStatus.addListener(_onChange);
    widget.operatorSession.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.connectionStatus.removeListener(_onChange);
    widget.operatorSession.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    setState(() {});
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
      const DrawerItemData(
          'Gestione Account', Icons.account_circle, '/account'),
      if (widget.operatorSession.isActive) ...[
        const DrawerItemData('Donazione', Icons.water_drop, '/donation'),
      ] else ...[
        const DrawerItemData(
          'Donazione',
          Icons.lock,
          '/not_active',
          overrideColorSelected: AvisColors.red,
          overrideColorUnselected: AvisColors.warmGrey,
        ),
      ],
      if (widget.operatorSession.isAdmin) ...[
        const DrawerItemData(
            'Gestione Operatori', Icons.manage_accounts, '/operators'),
        const DrawerItemData('Gestione Giornate Donazioni',
            Icons.calendar_today, '/donations_days'),
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
              delegate: SliverChildListDelegate.fixed(
                [
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
                          Navigator.of(context)
                              .pushReplacementNamed(item.route);
                        }
                      },
                    );
                  }),
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
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: AvisColors.red),
                    title: const Text('Logout'),
                    onTap: _logout,
                    enabled:
                        ServerStatus.connected == widget.connectionStatus.state,
                  ),
                  AnimatedBuilder(
                    animation: widget.connectionStatus,
                    builder: (context, _) {
                      final (color, label) =
                          switch (widget.connectionStatus.state) {
                        ServerStatus.disconnected => (
                            AvisColors.red,
                            'Nessuna connessione',
                          ),
                        ServerStatus.supabaseOffline => (
                            AvisColors.amber,
                            'Server non raggiungibile',
                          ),
                        ServerStatus.connected => (
                            widget.operatorSession.isActive
                                ? AvisColors.green
                                : AvisColors.blue,
                            widget.operatorSession.isActive
                                ? 'Online'
                                : 'Utente inattivo',
                          )
                      };
                      return ListTile(
                        leading: Icon(Icons.circle, color: color),
                        title: Text(label),
                      );
                    },
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
