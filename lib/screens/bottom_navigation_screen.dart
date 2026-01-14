import 'package:amenities_kenya/l10n/app_localizations.dart';
import 'package:amenities_kenya/screens/home_screen.dart';
import 'package:amenities_kenya/screens/past_orders_screen.dart';
import 'package:amenities_kenya/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavigationScreen extends ConsumerStatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends ConsumerState<BottomNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PastOrdersScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;

    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: translations.home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: translations.pastOrders,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: translations.profile,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}