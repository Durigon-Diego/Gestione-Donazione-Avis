import 'package:flutter/material.dart';
import 'avis_theme.dart';

/// Data model for each bottom navigation item
class BottomNavigationBarItemData {
  final IconData icon;
  final String label;

  const BottomNavigationBarItemData({
    required this.icon,
    required this.label,
  });
}

/// Data passed to AvisBottomNavigationBar from parent widgets
class AvisBottomNavigationBarData {
  final List<BottomNavigationBarItemData> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showUnselectedLabels;
  final BottomNavigationBarType type;

  const AvisBottomNavigationBarData({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.showUnselectedLabels = true,
    this.type = BottomNavigationBarType.fixed,
  });
}

/// Custom AVIS BottomNavigationBar with consistent style
class AvisBottomNavigationBar extends StatelessWidget {
  final AvisBottomNavigationBarData data;

  const AvisBottomNavigationBar({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: data.currentIndex,
      onTap: data.onTap,
      type: data.type,
      showUnselectedLabels: data.showUnselectedLabels,
      selectedItemColor: AvisColors.green,
      unselectedItemColor: AvisColors.blue,
      items: data.items
          .map(
            (item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}
