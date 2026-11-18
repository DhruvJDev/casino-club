import 'package:casino/Screens/adminscreen.dart';
import 'package:casino/Home/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:casino/Screens/chat_screen.dart';
import 'package:casino/services/app_storage.dart';
import 'package:casino/Auth/login.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({super.key, required this.user});

  final AppUser user;

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  final today = DateTime.now();
// final fiftyDaysFromNow = today.add(const Duration(days: 50));
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final isMedium = MediaQuery.sizeOf(context).width >= 600;
    final pages = <Widget>[
      const Dashboard(),
      const AdminScreen(username: '', name: '', password: ''),
      ChatScreen(user: widget.user),
    ];
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: isMedium ? 72 : 64,
        backgroundColor: const Color(0xFF171B25),
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Image.asset('assets/images/casino1_bg.png',
                height: isMedium ? 44 : 38),
            const SizedBox(width: 14),
            const Text('Casino Club',
                style: TextStyle(
                    fontSize: 18,
                    letterSpacing: -0.2,
                    fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF232733),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text('@${widget.user.username}',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _logout,
            iconSize: 22,
            padding: const EdgeInsets.all(12),
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (isWide)
            NavigationRail(
              backgroundColor: const Color(0xFF171B25),
              minWidth: 84,
              minExtendedWidth: 84,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              labelType: NavigationRailLabelType.all,
              indicatorColor: const Color(0xFF6966F6).withValues(alpha: 0.28),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              selectedLabelTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
              destinations: const [
                NavigationRailDestination(
                    icon: Icon(Icons.home_outlined, size: 23),
                    selectedIcon: Icon(Icons.home_rounded, size: 23),
                    label: Text('Home')),
                NavigationRailDestination(
                    icon: Icon(Icons.admin_panel_settings_outlined, size: 23),
                    selectedIcon:
                        Icon(Icons.admin_panel_settings_rounded, size: 23),
                    label: Text('Admin')),
                NavigationRailDestination(
                    icon: Icon(Icons.chat_bubble_outline_rounded, size: 23),
                    selectedIcon: Icon(Icons.chat_bubble_rounded, size: 23),
                    label: Text('Chat')),
              ],
            ),
          Expanded(
            child: Container(
              margin: isWide ? const EdgeInsets.only(left: 1) : EdgeInsets.zero,
              child: ClipRect(child: pages[_selectedIndex]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              height: 68,
              elevation: 0,
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorColor: const Color(0xFF6966F6).withValues(alpha: 0.24),
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              animationDuration: const Duration(milliseconds: 250),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined, size: 23),
                    selectedIcon: Icon(Icons.home_rounded, size: 24),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.admin_panel_settings_outlined, size: 23),
                    selectedIcon:
                        Icon(Icons.admin_panel_settings_rounded, size: 24),
                    label: 'Admin'),
                NavigationDestination(
                    icon: Icon(Icons.chat_bubble_outline_rounded, size: 23),
                    selectedIcon: Icon(Icons.chat_bubble_rounded, size: 24),
                    label: 'Chat'),
              ],
            ),
    );
  }

  Future<void> _logout() async {
    await AppStorage.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
