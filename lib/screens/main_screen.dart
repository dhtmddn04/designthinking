import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'reservation_screen.dart';
import 'opinion_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  int? currentUserId;
  String? currentUsername;
  bool currentNeedsWheelchair = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(userId: currentUserId),
      ReservationScreen(
        key: ValueKey(currentUserId),
        userId: currentUserId,
        needsWheelchair: currentNeedsWheelchair,
      ),
      OpinionScreen(key: ValueKey(currentUserId), userId: currentUserId),
      ProfileScreen(
        userId: currentUserId,
        onLoginSuccess: (user) {
          setState(() {
            currentUserId = user['id'];
            currentUsername = user['username'];
            currentNeedsWheelchair = user['needsWheelchair'] == true;
          });
        },
        onLogoutSuccess: () {
          setState(() {
            currentUserId = null;
            currentUsername = null;
            currentNeedsWheelchair = false;
          });
        },
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(index: selectedIndex, children: screens),
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x12000000),
              offset: Offset(0, -3),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        child: Row(
          children: [
            _buildNavItem(index: 0, icon: Icons.home_outlined, label: '홈'),
            _buildNavItem(
              index: 1,
              icon: Icons.event_available_outlined,
              label: '예약',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.chat_bubble_outline,
              label: '의견',
            ),
            _buildNavItem(index: 3, icon: Icons.person_outline, label: '프로필'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected = selectedIndex == index;

    final Color color = isSelected
        ? const Color(0xFF2B7FFF)
        : const Color(0xFF99A1AF);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
