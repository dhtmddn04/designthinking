import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/locale_controller.dart';
import 'home_screen.dart';
import 'reservation_screen.dart';
import 'opinion_screen.dart';
import 'profile_screen.dart';
import '../l10n/app_localizations.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const String _autoLoginKey = 'autoLogin';
  static const String _userIdKey = 'userId';
  static const String _usernameKey = 'username';
  static const String _phoneKey = 'phone';
  static const String _needsWheelchairKey = 'needsWheelchair';
  static const String _languageCodeKey = 'languageCode';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // 자동 로그인이 아니면 처음에는 프로필 탭에서 시작
  int selectedIndex = 3;
  int homeRefreshVersion = 0;

  int? currentUserId;
  String? currentUsername;
  String? currentPhone;
  bool currentNeedsWheelchair = false;
  String languageCode = 'ko';

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
      final String? savedPhone = await _prefs.getString(_phoneKey);
      final bool savedNeedsWheelchair =
          await _prefs.getBool(_needsWheelchairKey) ?? false;
      final String savedLanguageCode =
          await _prefs.getString(_languageCodeKey) ?? 'ko';

      if (!mounted) return;

      setState(() {
        languageCode = savedLanguageCode;

        if (autoLogin && savedUserId != null && savedUsername != null) {
          currentUserId = savedUserId;
          currentUsername = savedUsername;
          currentPhone = savedPhone;
          currentNeedsWheelchair = savedNeedsWheelchair;

          // 자동 로그인 상태면 홈 탭으로 시작
          selectedIndex = 0;
        } else {
          currentUserId = null;
          currentUsername = null;
          currentPhone = null;
          currentNeedsWheelchair = false;

          // 자동 로그인 상태가 아니면 프로필 탭으로 시작
          selectedIndex = 3;
        }

        _isRestoringLogin = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        currentUserId = null;
        currentUsername = null;
        currentPhone = null;
        currentNeedsWheelchair = false;
        selectedIndex = 3;
        _isRestoringLogin = false;
      });
    }
  }

  Future<void> _clearStoredLogin() async {
    await _prefs.remove(_autoLoginKey);
    await _prefs.remove(_userIdKey);
    await _prefs.remove(_usernameKey);
    await _prefs.remove(_phoneKey);
    await _prefs.remove(_needsWheelchairKey);
  }

  Future<void> _handleLoginSuccess(
    Map<String, dynamic> user,
    bool autoLogin,
  ) async {
    final int userId = user['id'] as int;
    final String username = user['username']?.toString() ?? '';
    final String phone = user['phone']?.toString() ?? '';
    final bool needsWheelchair = user['needsWheelchair'] == true;

    if (autoLogin) {
      await _prefs.setBool(_autoLoginKey, true);
      await _prefs.setInt(_userIdKey, userId);
      await _prefs.setString(_usernameKey, username);
      await _prefs.setString(_phoneKey, phone);
      await _prefs.setBool(_needsWheelchairKey, needsWheelchair);
    } else {
      await _clearStoredLogin();
    }

    if (!mounted) return;

    setState(() {
      currentUserId = userId;
      currentUsername = username;
      currentPhone = phone;
      currentNeedsWheelchair = needsWheelchair;
    });
  }

  Future<void> _handleProfileUpdated(Map<String, dynamic> user) async {
    final String username =
        user['username']?.toString() ?? currentUsername ?? '';
    final String phone = user['phone']?.toString() ?? '';
    final bool needsWheelchair = user['needsWheelchair'] == true;

    final bool autoLogin = await _prefs.getBool(_autoLoginKey) ?? false;

    if (autoLogin) {
      await _prefs.setString(_usernameKey, username);
      await _prefs.setString(_phoneKey, phone);
      await _prefs.setBool(_needsWheelchairKey, needsWheelchair);
    }

    if (!mounted) return;

    setState(() {
      currentUsername = username;
      currentPhone = phone;
      currentNeedsWheelchair = needsWheelchair;
    });
  }

  Future<void> _handleLogoutSuccess() async {
    await _clearStoredLogin();

    if (!mounted) return;

    setState(() {
      currentUserId = null;
      currentUsername = null;
      currentPhone = null;
      currentNeedsWheelchair = false;
      selectedIndex = 3;
    });
  }

  Future<void> _handleLanguageChanged(String code) async {
    if (code != 'ko' && code != 'en') return;

    await LocaleController.setLocale(code);

    if (!mounted) return;

    setState(() {
      languageCode = code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isRestoringLogin) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final List<Widget> screens = [
      HomeScreen(
        userId: currentUserId,
        refreshVersion: homeRefreshVersion,
        isActive: selectedIndex == 0,
      ),
      ReservationScreen(
        key: ValueKey(currentUserId),
        userId: currentUserId,
        needsWheelchair: currentNeedsWheelchair,
      ),
      OpinionScreen(key: ValueKey(currentUserId), userId: currentUserId),
      ProfileScreen(
        userId: currentUserId,
        username: currentUsername,
        phone: currentPhone,
        needsWheelchair: currentNeedsWheelchair,
        languageCode: languageCode,
        onLanguageChanged: _handleLanguageChanged,
        onLoginSuccess: _handleLoginSuccess,
        onLogoutSuccess: _handleLogoutSuccess,
        onProfileUpdated: _handleProfileUpdated,
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
            _buildNavItem(
              index: 0,
              icon: Icons.home_outlined,
              label: l10n.homeTab,
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.event_available_outlined,
              label: l10n.reservationTab,
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.chat_bubble_outline,
              label: l10n.reportTab,
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.person_outline,
              label: l10n.profileTab,
            ),
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

            if (index == 0) {
              homeRefreshVersion++;
            }
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
