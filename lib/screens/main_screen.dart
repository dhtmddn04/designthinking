import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const String _autoLoginKey = 'autoLogin';
  static const String _userIdKey = 'userId';
  static const String _usernameKey = 'username';
  static const String _needsWheelchairKey = 'needsWheelchair';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // 자동 로그인이 아니면 처음에는 프로필 탭에서 시작
  int selectedIndex = 3;
  int homeRefreshVersion = 0;

  int? currentUserId;
  String? currentUsername;
  bool currentNeedsWheelchair = false;

  bool _isRestoringLogin = true;

  @override
  void initState() {
    super.initState();
    _restoreAutoLogin();
  }

  Future<void> _restoreAutoLogin() async {
    try {
      final bool autoLogin = await _prefs.getBool(_autoLoginKey) ?? false;
      final int? savedUserId = await _prefs.getInt(_userIdKey);
      final String? savedUsername = await _prefs.getString(_usernameKey);
      final bool savedNeedsWheelchair =
          await _prefs.getBool(_needsWheelchairKey) ?? false;

      if (!mounted) return;

      setState(() {
        if (autoLogin && savedUserId != null && savedUsername != null) {
          currentUserId = savedUserId;
          currentUsername = savedUsername;
          currentNeedsWheelchair = savedNeedsWheelchair;

          // 자동 로그인 상태면 홈 탭으로 시작
          selectedIndex = 0;
        } else {
          currentUserId = null;
          currentUsername = null;
          currentNeedsWheelchair = false;

          // 자동 로그인 상태가 아니면 프로필 탭으로 시작
          selectedIndex = 3;
        }

        _isRestoringLogin = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        selectedIndex = 3;
        _isRestoringLogin = false;
      });
    }
  }

  Future<void> _clearStoredLogin() async {
    await _prefs.remove(_autoLoginKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_usernameKey);
    await _prefs.remove(_needsWheelchairKey);
  }

  Future<void> _handleLoginSuccess(
      Map<String, dynamic> user,
      bool autoLogin,
      ) async {
    final int userId = user['id'] as int;
    final String username = user['username']?.toString() ?? '';
    final bool needsWheelchair = user['needsWheelchair'] == true;

    if (autoLogin) {
      await _prefs.setBool(_autoLoginKey, true);
      await _prefs.setInt(_userIdKey, userId);
      await _prefs.setString(_usernameKey, username);
      await _prefs.setBool(_needsWheelchairKey, needsWheelchair);
    } else {
      await _clearStoredLogin();
    }

    if (!mounted) return;

    setState(() {
      currentUserId = userId;
      currentUsername = username;
      currentNeedsWheelchair = needsWheelchair;
    });
  }

  Future<void> _handleLogoutSuccess() async {
    await _clearStoredLogin();

    if (!mounted) return;

    setState(() {
      currentUserId = null;
      currentUsername = null;
      currentNeedsWheelchair = false;
      selectedIndex = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isRestoringLogin) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final List<Widget> screens = [
      HomeScreen(userId: currentUserId, refreshVersion: homeRefreshVersion),
      ReservationScreen(
        key: ValueKey(currentUserId),
        userId: currentUserId,
        needsWheelchair: currentNeedsWheelchair,
      ),
      OpinionScreen(key: ValueKey(currentUserId), userId: currentUserId),
      ProfileScreen(
        userId: currentUserId,
        username: currentUsername,
        onLoginSuccess: _handleLoginSuccess,
        onLogoutSuccess: _handleLogoutSuccess,
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
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
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
              label: '제보',
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
        ? const Color(0xFF2563EB)
        : const Color(0xFF99A1AF);

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            if (index == 0) {
              homeRefreshVersion++;
            }

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