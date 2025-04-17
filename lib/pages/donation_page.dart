import 'package:avis_donor_app/helpers/logger_helper.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../helpers/avis_scaffold.dart';
import '../helpers/avis_bottom_navigation_bar.dart';
import '../helpers/operator_session.dart';

/// Donation page with bottom navigation and drawer menu
class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

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
    OperatorSession.addListener(_checkRedirect);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkRedirect());
  }

  @override
  void dispose() {
    OperatorSession.removeListener(_checkRedirect);
    super.dispose();
  }

  void _checkRedirect() {
    _showContent = false;
    if (OperatorSession.currentUserId != null &&
        OperatorSession.currentUserId ==
            Supabase.instance.client.auth.currentUser?.id &&
        !OperatorSession.isActive) {
      logWarning("User '${OperatorSession.name}' is not active, redirecting");
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
        ? const AvisScaffold(title: '', body: SizedBox.shrink())
        : AvisScaffold(
            title: _titles[_selectedIndex],
            body:
                _showContent ? _pages[_selectedIndex] : const SizedBox.shrink(),
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
