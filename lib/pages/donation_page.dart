import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/logger_helper.dart';
import '../helpers/avis_scaffold.dart';
import '../helpers/app_info_controller.dart';
import '../helpers/connection_status_controller.dart';
import '../helpers/operator_session_controller.dart';
import '../helpers/avis_bottom_navigation_bar.dart';

/// Donation page with bottom navigation and drawer menu
class DonationPage extends StatefulWidget {
  final AppInfoController appInfo;
  final ConnectionStatusController connectionStatus;
  final OperatorSessionController operatorSession;
  const DonationPage({
    super.key,
    required this.appInfo,
    required this.connectionStatus,
    required this.operatorSession,
  });

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  bool _showContent = false;
  int _selectedIndex = 0;

  /// List of tab pages
  final List<Widget> _pages = const [
    CheckInPage(),
    ScreeningPage(),
    ExamPage(),
    DonationDonePage(),
  ];

  /// List of tab labels in Italian (visible to user)
  final List<String> _titles = [
    'Ingresso',
    'Accettazione',
    'Visita Medica',
    'Donazione',
  ];

  /// Navigation items
  final List<BottomNavigationBarItemData> _navItems = const [
    BottomNavigationBarItemData(icon: Icons.input, label: 'Ingresso'),
    BottomNavigationBarItemData(icon: Icons.how_to_reg, label: 'Accettazione'),
    BottomNavigationBarItemData(icon: Icons.medical_services, label: 'Visita'),
    BottomNavigationBarItemData(
        icon: Icons.volunteer_activism, label: 'Donazione'),
  ];

  @override
  void initState() {
    super.initState();
    widget.operatorSession.addListener(_checkRedirect);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRedirect());
  }

  @override
  void dispose() {
    widget.operatorSession.removeListener(_checkRedirect);
    super.dispose();
  }

  void _checkRedirect() {
    _showContent = false;
    if (widget.operatorSession.currentUserId != null &&
        widget.operatorSession.currentUserId ==
            Supabase.instance.client.auth.currentUser?.id &&
        !widget.operatorSession.isActive) {
      logWarning(
          "User '${widget.operatorSession.name}' is not active, redirecting");
      final nav =
          context.mounted ? Navigator.of(context) : navigatorKey.currentState;
      nav?.pushNamedAndRemoveUntil('/not_active', (_) => false);
    } else {
      _showContent = true;
      setState(() {});
    }
  }

  /// Handle tab switching
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_showContent
        ? AvisScaffold(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: widget.operatorSession,
            title: '',
            body: SizedBox.shrink(),
          )
        : AvisScaffold(
            appInfo: widget.appInfo,
            connectionStatus: widget.connectionStatus,
            operatorSession: widget.operatorSession,
            title: _titles[_selectedIndex],
            body: _pages[_selectedIndex],
            bottomNavData: AvisBottomNavigationBarData(
              items: _navItems,
              currentIndex: _selectedIndex,
              onTap: _onTabTapped,
            ),
          );
  }
}

/// Placeholder widget for the check-in (ingresso) phase
class CheckInPage extends StatelessWidget {
  const CheckInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Gestione ingresso donatori'));
  }
}

/// Placeholder widget for the screening (accettazione) phase
class ScreeningPage extends StatelessWidget {
  const ScreeningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Gestione accettazione'));
  }
}

/// Placeholder widget for the medical exam phase
class ExamPage extends StatelessWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Gestione visita medica'));
  }
}

/// Placeholder widget for the donation phase
class DonationDonePage extends StatelessWidget {
  const DonationDonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Gestione donazione'));
  }
}
