import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../widgets/language_icon_button.dart';
import '../l10n/app_localizations.dart';
// ─────────────────────────────────────────────
// 데이터 모델
// ─────────────────────────────────────────────

class TimetableEntry {
  final int? id;
  final String day;
  final int startMinute;
  final int endMinute;
  final String buildingName;
  final String roomNumber;
  final Color color;

  TimetableEntry({
    this.id,
    required this.day,
    required this.startMinute,
    required this.endMinute,
    required this.buildingName,
    required this.roomNumber,
    required this.color,
  });

  String get room => '$buildingName $roomNumber'.trim();
}

final List<TimetableEntry> initialTimetable = [
  TimetableEntry(
    day: '월',
    startMinute: 9 * 60,
    endMinute: 11 * 60,
    buildingName: '공학관',
    roomNumber: '301',
    color: Colors.blue,
  ),
  TimetableEntry(
    day: '월',
    startMinute: 13 * 60,
    endMinute: 16 * 60,
    buildingName: '외국어대학관',
    roomNumber: '201',
    color: Colors.green,
  ),
  TimetableEntry(
    day: '화',
    startMinute: 10 * 60 + 15,
    endMinute: 12 * 60,
    buildingName: '멀티미디어교육관',
    roomNumber: '701',
    color: Colors.purple,
  ),
  TimetableEntry(
    day: '수',
    startMinute: 9 * 60,
    endMinute: 11 * 60,
    buildingName: '전자정보대학관',
    roomNumber: 'B04',
    color: Colors.blue,
  ),
  TimetableEntry(
    day: '수',
    startMinute: 14 * 60 + 30,
    endMinute: 16 * 60,
    buildingName: '체육대학관',
    roomNumber: '261',
    color: Colors.orange,
  ),
  TimetableEntry(
    day: '목',
    startMinute: 10 * 60,
    endMinute: 12 * 60,
    buildingName: '전자정보대학관',
    roomNumber: '111',
    color: Colors.purple,
  ),
  TimetableEntry(
    day: '금',
    startMinute: 13 * 60,
    endMinute: 16 * 60,
    buildingName: '전자정보대학관',
    roomNumber: '304',
    color: Colors.green,
  ),
];

// ─────────────────────────────────────────────
// 프로필 탭 메인 화면
// ─────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  final int? userId;
  final String? username;
  final String? phone;
  final bool needsWheelchair;
  final String languageCode;
  final Future<void> Function(String code) onLanguageChanged;
  final Future<void> Function(Map<String, dynamic> user, bool autoLogin)
  onLoginSuccess;
  final Future<void> Function() onLogoutSuccess;
  final Future<void> Function(Map<String, dynamic> user) onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.phone,
    required this.needsWheelchair,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onLoginSuccess,
    required this.onLogoutSuccess,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool _isLoggedIn;
  bool _showSignup = false;
  String _loggedInUser = '';
  String _phone = '';
  bool _needsWheelchair = false;
  List<TimetableEntry> _timetable = [];

  @override
  void initState() {
    super.initState();

    _isLoggedIn = widget.userId != null;
    _loggedInUser = widget.username ?? '';
    _phone = widget.phone ?? '';
    _needsWheelchair = widget.needsWheelchair;

    if (widget.userId != null) {
      _loadTimetable(widget.userId!);
    }
  }

  void _login(String username) {
    setState(() {
      _isLoggedIn = true;
      _loggedInUser = username.isEmpty ? 'XXXXXXXX' : username;
    });
  }

  Future<void> _logout() async {
    await widget.onLogoutSuccess();

    if (!mounted) return;

    setState(() {
      _isLoggedIn = false;
      _loggedInUser = '';
      _phone = '';
      _needsWheelchair = false;
      _showSignup = false;
      _timetable = [];
    });
  }

  void _updateTimetable(List<TimetableEntry> updatedTimetable) {
    setState(() {
      _timetable = updatedTimetable;
    });
  }

  Future<void> _handleProfileUpdated(Map<String, dynamic> user) async {
    setState(() {
      _loggedInUser = user['username']?.toString() ?? _loggedInUser;
      _phone = user['phone']?.toString() ?? _phone;
      _needsWheelchair = user['needsWheelchair'] == true;
    });

    await widget.onProfileUpdated(user);
  }

  int? _parseTimeToMinute(String? text) {
    if (text == null) return null;

    final parts = text.trim().split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return hour * 60 + minute;
  }

  Future<void> _loadTimetable(int userId) async {
    try {
      final result = await ApiService.getSchedules(userId: userId);

      if (!mounted) return;

      if (result['success'] == true) {
        final schedules = result['schedules'] as List<dynamic>;

        final colors = [
          Colors.blue,
          Colors.green,
          Colors.purple,
          Colors.orange,
          Colors.pink,
          Colors.red,
        ];

        setState(() {
          _timetable = schedules.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;

            final startMinute = _parseTimeToMinute(schedule['startTime']) ?? 0;
            final endMinute = _parseTimeToMinute(schedule['endTime']) ?? 0;

            final buildingName = schedule['buildingName'] ?? '';
            final roomNumber = schedule['roomNumber'] ?? '';

            return TimetableEntry(
              id: schedule['id'],
              day: schedule['dayOfWeek'],
              startMinute: startMinute,
              endMinute: endMinute,
              buildingName: buildingName.toString(),
              roomNumber: roomNumber.toString(),
              color: colors[index % colors.length],
            );
          }).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timetableLoadFailed)));
    }
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId ||
        oldWidget.username != widget.username ||
        oldWidget.phone != widget.phone ||
        oldWidget.needsWheelchair != widget.needsWheelchair) {
      if (widget.userId != null) {
        setState(() {
          _isLoggedIn = true;
          _loggedInUser = widget.username ?? '';
          _phone = widget.phone ?? '';
          _needsWheelchair = widget.needsWheelchair;
        });

        if (oldWidget.userId != widget.userId) {
          _loadTimetable(widget.userId!);
        }
      } else {
        setState(() {
          _isLoggedIn = false;
          _loggedInUser = '';
          _phone = '';
          _needsWheelchair = false;
          _showSignup = false;
          _timetable = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn && _showSignup) {
      return SignupView(
        languageCode: widget.languageCode,
        onLanguageChanged: widget.onLanguageChanged,
        onBackToLogin: () {
          setState(() {
            _showSignup = false;
          });
        },
      );
    }

    if (!_isLoggedIn) {
      return LoginView(
        languageCode: widget.languageCode,
        onLanguageChanged: widget.onLanguageChanged,
        onLogin: _login,
        onLoginSuccess: widget.onLoginSuccess,
        onSignup: () {
          setState(() {
            _showSignup = true;
          });
        },
      );
    }

    return ProfileContentView(
      userId: widget.userId,
      username: _loggedInUser,
      phone: _phone,
      needsWheelchair: _needsWheelchair,
      languageCode: widget.languageCode,
      onLanguageChanged: widget.onLanguageChanged,
      timetable: _timetable,
      onLogout: _logout,
      onTimetableUpdated: _updateTimetable,
      onProfileUpdated: _handleProfileUpdated,
    );
  }
}

// ─────────────────────────────────────────────
// 로그인 화면
// ─────────────────────────────────────────────

class LoginView extends StatefulWidget {
  final String languageCode;
  final Future<void> Function(String code) onLanguageChanged;
  final void Function(String username) onLogin;
  final Future<void> Function(Map<String, dynamic> user, bool autoLogin)
  onLoginSuccess;
  final VoidCallback onSignup;

  const LoginView({
    super.key,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onLogin,
    required this.onLoginSuccess,
    required this.onSignup,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _autoLogin = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 90),
                child: Column(
                  children: [
                    const SizedBox(height: 36),
                    Container(
                      width: 74,
                      height: 74,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x332563EB),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.login,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.loginSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 34),

                    _buildLabel(l10n.username),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _usernameController,
                      hintText: l10n.enterUsername,
                    ),

                    const SizedBox(height: 16),

                    _buildLabel(l10n.password),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: l10n.enterPassword,
                      obscureText: true,
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _autoLogin = !_autoLogin;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _autoLogin
                                  ? const Color(0xFF2563EB)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _autoLogin
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFD1D5DB),
                                width: 1.5,
                              ),
                            ),
                            child: _autoLogin
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 13,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _autoLogin = !_autoLogin;
                            });
                          },
                          child: Text(
                            l10n.autoLogin,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    _buildPrimaryButton(
                      label: l10n.login,
                      onTap: () async {
                        final username = _usernameController.text.trim();
                        final password = _passwordController.text.trim();

                        if (username.isEmpty || password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.enterUsernameAndPassword),
                            ),
                          );
                          return;
                        }

                        try {
                          final result = await ApiService.login(
                            username: username,
                            password: password,
                          );

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                result['success'] == true
                                    ? l10n.loginSuccess
                                    : l10n.loginFailed,
                              ),
                            ),
                          );

                          if (result['success'] == true) {
                            final user = Map<String, dynamic>.from(
                              result['user'],
                            );

                            widget.onLogin(user['username']?.toString() ?? '');
                            await widget.onLoginSuccess(user, _autoLogin);
                          }
                        } catch (e) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.serverConnectionFailed),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 18),

                    TextButton(
                      onPressed: widget.onSignup,
                      child: Text(
                        l10n.signup,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 16,
              child: LanguageIconButton(
                languageCode: widget.languageCode,
                onSelected: widget.onLanguageChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 회원가입 화면
// ─────────────────────────────────────────────
class SignupView extends StatefulWidget {
  final String languageCode;
  final Future<void> Function(String code) onLanguageChanged;
  final VoidCallback onBackToLogin;

  const SignupView({
    super.key,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.onBackToLogin,
  });

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
      TextEditingController();

  final TextEditingController _phoneMiddleController = TextEditingController();
  final TextEditingController _phoneLastController = TextEditingController();
  final FocusNode _phoneLastFocusNode = FocusNode();

  bool _needsWheelchair = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _phoneMiddleController.dispose();
    _phoneLastController.dispose();
    _phoneLastFocusNode.dispose();
    super.dispose();
  }

  Widget _buildPhonePartField({
    required TextEditingController controller,
    required String hintText,
    FocusNode? focusNode,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 4,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.7),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 64, 22, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.signup,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l10n.signupSubtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 30),

                  _buildLabel(l10n.username),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _usernameController,
                    hintText: l10n.enterUsername,
                  ),

                  const SizedBox(height: 16),

                  _buildLabel(l10n.password),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: l10n.enterPassword,
                    obscureText: true,
                  ),

                  const SizedBox(height: 16),

                  _buildLabel(l10n.confirmPassword),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _passwordConfirmController,
                    hintText: l10n.reenterPassword,
                    obscureText: true,
                  ),

                  const SizedBox(height: 16),

                  _buildLabel(l10n.phoneNumber),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 49,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: const Text(
                          '010',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '-',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildPhonePartField(
                          controller: _phoneMiddleController,
                          hintText: '1234',
                          onChanged: (value) {
                            if (value.length == 4) {
                              _phoneLastFocusNode.requestFocus();
                            }
                          },
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '-',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildPhonePartField(
                          controller: _phoneLastController,
                          hintText: '5678',
                          focusNode: _phoneLastFocusNode,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  _buildLabel(l10n.wheelchairUser),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: _buildToggleButton(
                          label: l10n.yes,
                          selected: _needsWheelchair,
                          onTap: () {
                            setState(() {
                              _needsWheelchair = true;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildToggleButton(
                          label: l10n.no,
                          selected: !_needsWheelchair,
                          onTap: () {
                            setState(() {
                              _needsWheelchair = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  _buildPrimaryButton(
                    label: l10n.createAccount,
                    onTap: () async {
                      final username = _usernameController.text.trim();
                      final password = _passwordController.text.trim();
                      final passwordConfirm = _passwordConfirmController.text
                          .trim();
                      final phoneMiddle = _phoneMiddleController.text.trim();
                      final phoneLast = _phoneLastController.text.trim();
                      final phone = '010-$phoneMiddle-$phoneLast';

                      if (username.isEmpty ||
                          password.isEmpty ||
                          passwordConfirm.isEmpty ||
                          phoneMiddle.isEmpty ||
                          phoneLast.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.fillAllFields)),
                        );
                        return;
                      }

                      if (phoneMiddle.length != 4 || phoneLast.length != 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.phoneNumberFourDigits)),
                        );
                        return;
                      }

                      if (password != passwordConfirm) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.passwordsDoNotMatch)),
                        );
                        return;
                      }

                      try {
                        final l10n = AppLocalizations.of(context)!;

                        final result = await ApiService.signup(
                          username: username,
                          password: password,
                          phone: phone,
                          needsWheelchair: _needsWheelchair,
                        );

                        if (result['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.signupCompletedMessage),
                            ),
                          );

                          Navigator.pop(context);
                          return;
                        }

                        if (result['statusCode'] == 409) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(l10n.signupFailedTitle),
                                content: Text(l10n.duplicateUsernameMessage),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(l10n.ok),
                                  ),
                                ],
                              );
                            },
                          );
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(result['message'] ?? '회원가입에 실패했습니다.'),
                          ),
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['success'] == true
                                  ? l10n.signupSuccess
                                  : l10n.signupFailed,
                            ),
                          ),
                        );

                        if (result['success'] == true) {
                          widget.onBackToLogin();
                        }
                      } catch (e) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.serverConnectionFailed)),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 18),

                  Center(
                    child: TextButton(
                      onPressed: widget.onBackToLogin,
                      child: Text(
                        l10n.backToLogin,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 16,
              child: LanguageIconButton(
                languageCode: widget.languageCode,
                onSelected: widget.onLanguageChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 로그인 후 프로필 화면
// ─────────────────────────────────────────────

class ProfileContentView extends StatelessWidget {
  final int? userId;
  final String username;
  final String phone;
  final bool needsWheelchair;
  final String languageCode;
  final Future<void> Function(String code) onLanguageChanged;
  final List<TimetableEntry> timetable;
  final VoidCallback onLogout;
  final void Function(List<TimetableEntry>) onTimetableUpdated;
  final Future<void> Function(Map<String, dynamic> user) onProfileUpdated;

  const ProfileContentView({
    super.key,
    required this.userId,
    required this.username,
    required this.phone,
    required this.needsWheelchair,
    required this.languageCode,
    required this.onLanguageChanged,
    required this.timetable,
    required this.onLogout,
    required this.onTimetableUpdated,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: const Color(0xFFF9FAFB),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x332563EB),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.username,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          username,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  LanguageIconButton(
                    languageCode: languageCode,
                    onSelected: onLanguageChanged,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.profileInfo,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  if (userId == null) return;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileEditScreen(
                                        userId: userId!,
                                        username: username,
                                        phone: phone,
                                        needsWheelchair: needsWheelchair,
                                        onProfileUpdated: onProfileUpdated,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Color(0xFF2563EB),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _ProfileInfoRow(
                            label: l10n.username,
                            value: username,
                          ),
                          const SizedBox(height: 10),
                          _ProfileInfoRow(
                            label: l10n.phoneNumber,
                            value: phone.isEmpty
                                ? l10n.noRegisteredPhone
                                : phone,
                          ),
                          const SizedBox(height: 10),
                          _ProfileInfoRow(
                            label: l10n.wheelchairUser,
                            value: needsWheelchair ? l10n.yes : l10n.no,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                l10n.timetable,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TimetableEditScreen(
                                        userId: userId,
                                        timetable: timetable,
                                        onSave: onTimetableUpdated,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: Color(0xFF2563EB),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          TimetableGrid(timetable: timetable),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: onLogout,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFE5E7EB),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Text(
                          l10n.logout,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileEditScreen extends StatefulWidget {
  final int userId;
  final String username;
  final String phone;
  final bool needsWheelchair;
  final Future<void> Function(Map<String, dynamic> user) onProfileUpdated;

  const ProfileEditScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.phone,
    required this.needsWheelchair,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _phoneMiddleController;
  late TextEditingController _phoneLastController;
  final FocusNode _phoneLastFocusNode = FocusNode();

  late bool _needsWheelchair;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final parts = widget.phone.split('-');

    _phoneMiddleController = TextEditingController(
      text: parts.length == 3 ? parts[1] : '',
    );

    _phoneLastController = TextEditingController(
      text: parts.length == 3 ? parts[2] : '',
    );

    _needsWheelchair = widget.needsWheelchair;
  }

  @override
  void dispose() {
    _phoneMiddleController.dispose();
    _phoneLastController.dispose();
    _phoneLastFocusNode.dispose();
    super.dispose();
  }

  Widget _buildPhonePartField({
    required TextEditingController controller,
    required String hintText,
    FocusNode? focusNode,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      maxLength: 4,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        counterText: '',
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.7),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;

    final phoneMiddle = _phoneMiddleController.text.trim();
    final phoneLast = _phoneLastController.text.trim();
    final phone = '010-$phoneMiddle-$phoneLast';

    if (phoneMiddle.isEmpty || phoneLast.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.enterFullPhoneNumber)));
      return;
    }

    if (phoneMiddle.length != 4 || phoneLast.length != 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.phoneNumberFourDigits)));
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final result = await ApiService.updateProfile(
        userId: widget.userId,
        phone: phone,
        needsWheelchair: _needsWheelchair,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? l10n.profileUpdateSuccess
                : l10n.profileUpdateFailed,
          ),
        ),
      );
      if (result['success'] == true) {
        final user = Map<String, dynamic>.from(result['user']);

        await widget.onProfileUpdated(user);

        if (!mounted) return;
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.serverConnectionFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.editProfile,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel(l10n.username),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                ),
                child: Text(
                  widget.username,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _buildLabel(l10n.phoneNumber),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 49,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD1D5DB)),
                    ),
                    child: const Text(
                      '010',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildPhonePartField(
                      controller: _phoneMiddleController,
                      hintText: '1234',
                      onChanged: (value) {
                        if (value.length == 4) {
                          _phoneLastFocusNode.requestFocus();
                        }
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildPhonePartField(
                      controller: _phoneLastController,
                      hintText: '5678',
                      focusNode: _phoneLastFocusNode,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              _buildLabel(l10n.wheelchairUser),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      label: l10n.yes,
                      selected: _needsWheelchair,
                      onTap: () {
                        setState(() {
                          _needsWheelchair = true;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildToggleButton(
                      label: l10n.no,
                      selected: !_needsWheelchair,
                      onTap: () {
                        setState(() {
                          _needsWheelchair = false;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFF93C5FD),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isSaving ? l10n.saveInProgress : l10n.saveChanges,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 시간표 편집 화면
// ─────────────────────────────────────────────

class TimetableEditScreen extends StatefulWidget {
  final int? userId;
  final List<TimetableEntry> timetable;
  final void Function(List<TimetableEntry>) onSave;

  const TimetableEditScreen({
    super.key,
    required this.userId,
    required this.timetable,
    required this.onSave,
  });

  @override
  State<TimetableEditScreen> createState() => _TimetableEditScreenState();
}

class _TimetableEditScreenState extends State<TimetableEditScreen> {
  late List<TimetableEntry> _timetable;

  final List<String> _days = ['월', '화', '수', '목', '금'];
  final List<String> _selectedDays = [];

  final TextEditingController _startTimeController = TextEditingController(
    text: '09:00',
  );
  final TextEditingController _endTimeController = TextEditingController(
    text: '10:00',
  );
  final List<String> _buildings = [
    '공학관',
    '외국어대학관',
    '체육대학관',
    '멀티미디어교육관',
    '생명과학대학관',
    '전자정보대학관',
    '예술디자인대학관',
    '국제학관',
  ];

  String _selectedBuilding = '공학관';

  final TextEditingController _roomNumberController = TextEditingController();

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.red,
  ];

  bool _isAddingClass = false;

  int? _editingScheduleId;
  bool _isUpdatingClass = false;

  bool get _isEditing => _editingScheduleId != null;

  @override
  void initState() {
    super.initState();
    _timetable = List.from(widget.timetable);

    _startTimeController.addListener(() => setState(() {}));
    _endTimeController.addListener(() => setState(() {}));
    _roomNumberController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _startTimeController.dispose();
    _endTimeController.dispose();
    _roomNumberController.dispose();
    super.dispose();
  }

  int? _parseTimeToMinute(String text) {
    final parts = text.trim().split(':');
    if (parts.length != 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23) return null;
    if (minute < 0 || minute > 59) return null;

    return hour * 60 + minute;
  }

  Future<void> _pickTime(
    TextEditingController controller, {
    bool isStartTime = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final currentMinute = _parseTimeToMinute(controller.text) ?? 9 * 60;

    final now = DateTime.now();

    DateTime selectedTime = DateTime(
      now.year,
      now.month,
      now.day,
      currentMinute ~/ 60,
      currentMinute % 60,
    );

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SizedBox(
          height: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        final pickedMinute =
                            selectedTime.hour * 60 + selectedTime.minute;

                        final hourText = selectedTime.hour.toString().padLeft(
                          2,
                          '0',
                        );
                        final minuteText = selectedTime.minute
                            .toString()
                            .padLeft(2, '0');

                        setState(() {
                          controller.text = '$hourText:$minuteText';

                          // 시작 시간을 고른 경우,
                          // 종료 시간이 시작 시간보다 빠르거나 같으면 자동으로 시작 + 1시간으로 보정
                          if (isStartTime) {
                            final currentEndMinute = _parseTimeToMinute(
                              _endTimeController.text,
                            );

                            if (currentEndMinute == null ||
                                currentEndMinute <= pickedMinute) {
                              int adjustedEndMinute = pickedMinute + 60;

                              // 23:55를 넘어가지 않도록 제한
                              if (adjustedEndMinute > 23 * 60 + 55) {
                                adjustedEndMinute = 23 * 60 + 55;
                              }

                              _endTimeController.text = _formatMinute(
                                adjustedEndMinute,
                              );
                            }
                          }
                        });

                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.done,
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                  minuteInterval: 5,
                  initialDateTime: selectedTime,
                  onDateTimeChanged: (DateTime value) {
                    selectedTime = value;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool get _canAddClass {
    final startMinute = _parseTimeToMinute(_startTimeController.text);
    final endMinute = _parseTimeToMinute(_endTimeController.text);

    return !_isAddingClass &&
        !_isUpdatingClass &&
        _selectedDays.isNotEmpty &&
        _roomNumberController.text.trim().isNotEmpty &&
        startMinute != null &&
        endMinute != null &&
        startMinute < endMinute;
  }

  bool _hasOverlappingClass(
    String day,
    int startMinute,
    int endMinute, {
    int? exceptScheduleId,
  }) {
    return _timetable.any((entry) {
      if (exceptScheduleId != null && entry.id == exceptScheduleId) {
        return false;
      }

      return entry.day == day &&
          startMinute < entry.endMinute &&
          endMinute > entry.startMinute;
    });
  }

  Future<void> _loadSchedulesFromServer() async {
    final userId = widget.userId;

    if (userId == null) return;

    final result = await ApiService.getSchedules(userId: userId);

    if (result['success'] != true) return;

    final schedules = result['schedules'] as List<dynamic>;

    setState(() {
      _timetable = schedules.asMap().entries.map((entry) {
        final index = entry.key;
        final schedule = entry.value;

        final startMinute = _parseTimeToMinute(schedule['startTime']) ?? 0;
        final endMinute = _parseTimeToMinute(schedule['endTime']) ?? 0;

        final buildingName = schedule['buildingName'] ?? '';
        final roomNumber = schedule['roomNumber'] ?? '';

        return TimetableEntry(
          id: schedule['id'],
          day: schedule['dayOfWeek'],
          startMinute: startMinute,
          endMinute: endMinute,
          buildingName: buildingName.toString(),
          roomNumber: roomNumber.toString(),
          color: _colors[index % _colors.length],
        );
      }).toList();
    });

    widget.onSave(_timetable);
  }

  void _resetClassForm() {
    setState(() {
      _editingScheduleId = null;
      _selectedDays.clear();
      _startTimeController.text = '09:00';
      _endTimeController.text = '10:00';
      _roomNumberController.clear();
      _selectedBuilding = '공학관';
    });
  }

  void _startEditClass(int index) {
    final l10n = AppLocalizations.of(context)!;
    final entry = _timetable[index];

    if (entry.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timetableEditInfoMissing)));
      return;
    }

    setState(() {
      _editingScheduleId = entry.id;

      _selectedDays
        ..clear()
        ..add(entry.day);

      _startTimeController.text = _formatMinute(entry.startMinute);
      _endTimeController.text = _formatMinute(entry.endMinute);
      _selectedBuilding = entry.buildingName;
      _roomNumberController.text = entry.roomNumber;
    });
  }

  Future<void> _updateClass() async {
    final l10n = AppLocalizations.of(context)!;
    final userId = widget.userId;
    final scheduleId = _editingScheduleId;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loginRequired)));
      return;
    }

    if (scheduleId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectTimetableToEdit)));
      return;
    }

    final startMinute = _parseTimeToMinute(_startTimeController.text);
    final endMinute = _parseTimeToMinute(_endTimeController.text);

    if (!_canAddClass || startMinute == null || endMinute == null) return;

    if (_selectedDays.length != 1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectOneDayToEdit)));
      return;
    }

    final selectedDay = _selectedDays.first;

    final hasOverlap = _hasOverlappingClass(
      selectedDay,
      startMinute,
      endMinute,
      exceptScheduleId: scheduleId,
    );

    if (hasOverlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.classTimeOverlap(_dayDisplayText(selectedDay))),
        ),
      );
      return;
    }

    setState(() {
      _isUpdatingClass = true;
    });

    try {
      final result = await ApiService.updateSchedule(
        userId: userId,
        scheduleId: scheduleId,
        dayOfWeek: selectedDay,
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        buildingName: _selectedBuilding,
        roomNumber: _roomNumberController.text.trim(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await _loadSchedulesFromServer();

        _resetClassForm();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.timetableUpdated)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.timetableUpdateFailed)));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.serverConnectionFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingClass = false;
        });
      }
    }
  }

  Future<void> _addClass() async {
    final l10n = AppLocalizations.of(context)!;
    final userId = widget.userId;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loginRequired)));
      return;
    }

    final startMinute = _parseTimeToMinute(_startTimeController.text);
    final endMinute = _parseTimeToMinute(_endTimeController.text);

    if (!_canAddClass || startMinute == null || endMinute == null) return;

    final overlappingDay = _selectedDays.where((day) {
      return _hasOverlappingClass(day, startMinute, endMinute);
    }).toList();

    if (overlappingDay.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.classTimeOverlap(_dayDisplayText(overlappingDay.first)),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isAddingClass = true;
    });

    try {
      for (final day in _selectedDays) {
        final result = await ApiService.addSchedule(
          userId: userId,
          dayOfWeek: day,
          startTime: _startTimeController.text.trim(),
          endTime: _endTimeController.text.trim(),
          buildingName: _selectedBuilding,
          roomNumber: _roomNumberController.text.trim(),
        );

        if (result['success'] != true) {
          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.timetableAddFailed)));
          return;
        }
      }

      if (!mounted) return;

      await _loadSchedulesFromServer();

      _resetClassForm();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timetableAdded)));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.serverConnectionFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _isAddingClass = false;
        });
      }
    }
  }

  String _formatMinute(int minute) {
    final hour = minute ~/ 60;
    final min = minute % 60;

    final hourText = hour.toString().padLeft(2, '0');
    final minuteText = min.toString().padLeft(2, '0');

    return '$hourText:$minuteText';
  }

  String _dayDisplayText(String day) {
    final l10n = AppLocalizations.of(context)!;

    switch (day) {
      case '월':
        return l10n.mondayShort;
      case '화':
        return l10n.tuesdayShort;
      case '수':
        return l10n.wednesdayShort;
      case '목':
        return l10n.thursdayShort;
      case '금':
        return l10n.fridayShort;
      default:
        return day;
    }
  }

  Future<void> _deleteClass(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final userId = widget.userId;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loginRequired)));
      return;
    }

    final entry = _timetable[index];

    if (entry.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.timetableDeleteInfoMissing)));
      return;
    }

    try {
      final result = await ApiService.deleteSchedule(
        userId: userId,
        scheduleId: entry.id!,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        await _loadSchedulesFromServer();

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.timetableDeleted)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.timetableDeleteFailed)));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.serverConnectionFailed)));
    }
  }

  void _confirmDeleteClass(int index) {
    final entry = _timetable[index];

    final l10n = AppLocalizations.of(context)!;
    final dayText = _dayDisplayText(entry.day);
    final timeText =
        '${_formatMinute(entry.startMinute)}~${_formatMinute(entry.endMinute)}';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.deleteClassTitle,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            l10n.deleteClassMessage(dayText, timeText, entry.room),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteClass(index);
              },
              child: Text(
                l10n.deleteButton,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.onSave(_timetable);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left_rounded,
                        color: Color(0xFF374151),
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.editTimetable,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.enterClassInfo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
                child: Column(
                  children: [
                    _sectionCard(
                      title: l10n.currentTimetable,
                      child: TimetableGrid(timetable: _timetable),
                    ),

                    const SizedBox(height: 16),

                    _sectionCard(
                      title: _isEditing ? l10n.editClass : l10n.addClass,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(l10n.dayLabel),
                          const SizedBox(height: 8),

                          Row(
                            children: _days.map((day) {
                              final bool selected = _selectedDays.contains(day);

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (_isEditing) {
                                        _selectedDays
                                          ..clear()
                                          ..add(day);
                                        return;
                                      }

                                      if (selected) {
                                        _selectedDays.remove(day);
                                      } else {
                                        _selectedDays.add(day);
                                      }
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? const Color(0xFF2563EB)
                                          : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Text(
                                      _dayDisplayText(day),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: selected
                                            ? Colors.white
                                            : const Color(0xFF374151),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(l10n.startTimeLabel),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _startTimeController,
                                      hintText: l10n.exampleTime,
                                      readOnly: true,
                                      onTap: () => _pickTime(
                                        _startTimeController,
                                        isStartTime: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel(l10n.endTimeLabel),
                                    const SizedBox(height: 8),
                                    _buildTextField(
                                      controller: _endTimeController,
                                      hintText: l10n.exampleEndTime,
                                      readOnly: true,
                                      onTap: () =>
                                          _pickTime(_endTimeController),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          _buildLabel(l10n.classroomLabel),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: DropdownButtonFormField<String>(
                                  value: _selectedBuilding,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD1D5DB),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFD1D5DB),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF2563EB),
                                        width: 1.7,
                                      ),
                                    ),
                                  ),
                                  items: _buildings.map((building) {
                                    return DropdownMenuItem<String>(
                                      value: building,
                                      child: Text(
                                        building,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    if (value == null) return;

                                    setState(() {
                                      _selectedBuilding = value;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  controller: _roomNumberController,
                                  hintText: l10n.exampleRoom,
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _canAddClass
                                  ? (_isEditing ? _updateClass : _addClass)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                disabledBackgroundColor: const Color(
                                  0xFFE5E7EB,
                                ),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: const Color(
                                  0xFF9CA3AF,
                                ),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              child: Text(
                                _isUpdatingClass
                                    ? l10n.updatingClass
                                    : _isAddingClass
                                    ? l10n.addingClass
                                    : _isEditing
                                    ? l10n.updateClassDone
                                    : l10n.addClass,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          if (_isEditing) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: _resetClassForm,
                                child: Text(
                                  l10n.cancelEdit,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (_timetable.isNotEmpty) ...[
                      const SizedBox(height: 16),

                      _sectionCard(
                        title: l10n.classList,
                        child: Column(
                          children: List.generate(_timetable.length, (index) {
                            final entry = _timetable[index];

                            return Container(
                              margin: EdgeInsets.only(
                                bottom: index == _timetable.length - 1 ? 0 : 8,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 11,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      color: entry.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${_dayDisplayText(entry.day)} ${_formatMinute(entry.startMinute)}~${_formatMinute(entry.endMinute)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          entry.room,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _startEditClass(index);
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF2563EB),
                                        size: 17,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  GestureDetector(
                                    onTap: () {
                                      _confirmDeleteClass(index);
                                    },
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        color: Color(0xFFDC2626),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          widget.onSave(_timetable);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: Text(
                          l10n.done,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 시간표 그리드
// ─────────────────────────────────────────────

class TimetableGrid extends StatelessWidget {
  final List<TimetableEntry> timetable;

  const TimetableGrid({super.key, required this.timetable});

  static const List<String> _days = ['월', '화', '수', '목', '금'];

  // 기본 표시 범위: 09:00 ~ 18:00
  static const int _defaultStartHour = 9;
  static const int _defaultEndHour = 18;

  // 표 크기 조정
  // 기존 dayColumnWidth가 48이라 너무 좁았으므로 70으로 넓힘
  static const double _timeColumnWidth = 38;
  static const double _dayColumnWidth = 70;
  static const double _rowHeight = 42;
  static const double _gap = 2;

  int get _visibleStartHour {
    if (timetable.isEmpty) return _defaultStartHour;

    int minStartMinute = timetable.first.startMinute;

    for (final entry in timetable) {
      if (entry.startMinute < minStartMinute) {
        minStartMinute = entry.startMinute;
      }
    }

    final classStartHour = minStartMinute ~/ 60;

    // 기본은 9시부터 보여주되, 9시 이전 수업이 있으면 그 시간까지 확장
    final result = classStartHour < _defaultStartHour
        ? classStartHour
        : _defaultStartHour;

    // 0시보다 작아지는 예외 방지
    return result < 0 ? 0 : result;
  }

  int get _visibleEndHour {
    if (timetable.isEmpty) return _defaultEndHour;

    int maxEndMinute = timetable.first.endMinute;

    for (final entry in timetable) {
      if (entry.endMinute > maxEndMinute) {
        maxEndMinute = entry.endMinute;
      }
    }

    // 예: 18:00이면 18, 18:10이면 19까지 표시
    int classEndHour = maxEndMinute ~/ 60;
    if (maxEndMinute % 60 != 0) {
      classEndHour += 1;
    }

    final result = classEndHour > _defaultEndHour
        ? classEndHour
        : _defaultEndHour;

    // 하루 최대 24시까지만 표시
    return result > 24 ? 24 : result;
  }

  List<int> get _visibleHours {
    final startHour = _visibleStartHour;
    final endHour = _visibleEndHour;

    if (endHour <= startHour) {
      return [_defaultStartHour];
    }

    return List.generate(endHour - startHour, (index) => startHour + index);
  }

  String _formatHourLabel(int hour) {
    return hour.toString().padLeft(2, '0');
  }

  String _dayDisplayText(BuildContext context, String day) {
    final l10n = AppLocalizations.of(context)!;

    switch (day) {
      case '월':
        return l10n.mondayShort;
      case '화':
        return l10n.tuesdayShort;
      case '수':
        return l10n.wednesdayShort;
      case '목':
        return l10n.thursdayShort;
      case '금':
        return l10n.fridayShort;
      default:
        return day;
    }
  }

  String _shortRoomName(String room) {
    // 시간표 칸이 좁으므로 긴 건물명은 약칭으로 줄여 표시
    return room
        .replaceAll('외국어대학관', '외대')
        .replaceAll('멀티미디어교육관', '멀관')
        .replaceAll('생명과학대학관', '생대')
        .replaceAll('전자정보대학관', '전정대')
        .replaceAll('예술디자인대학관', '예대')
        .replaceAll('체육대학관', '체대')
        .replaceAll('국제학관', '국제대');
  }

  @override
  Widget build(BuildContext context) {
    final visibleHours = _visibleHours;
    final int timetableStartMinute = _visibleStartHour * 60;
    final int timetableEndMinute = _visibleEndHour * 60;

    final double gridWidth =
        _timeColumnWidth + (_dayColumnWidth + _gap) * _days.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double viewportWidth = constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: gridWidth < viewportWidth ? viewportWidth : gridWidth,
            child: Center(
              child: SizedBox(
                width: gridWidth,
                child: Column(
                  children: [
                    // 요일 헤더
                    Row(
                      children: [
                        const SizedBox(width: _timeColumnWidth),
                        ..._days.map((day) {
                          return SizedBox(
                            width: _dayColumnWidth + _gap,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: _gap / 2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                _dayDisplayText(context, day),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Stack(
                      children: [
                        // 배경 격자
                        Column(
                          children: visibleHours.map((hour) {
                            return Row(
                              children: [
                                SizedBox(
                                  width: _timeColumnWidth,
                                  height: _rowHeight + _gap,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        _formatHourLabel(hour),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                ..._days.map((day) {
                                  final int cellStart = hour * 60;
                                  final int cellEnd = (hour + 1) * 60;

                                  final bool isOccupied = timetable.any((
                                    entry,
                                  ) {
                                    return entry.day == day &&
                                        entry.startMinute < cellEnd &&
                                        entry.endMinute > cellStart;
                                  });

                                  return Container(
                                    width: _dayColumnWidth,
                                    height: _rowHeight,
                                    margin: const EdgeInsets.all(_gap / 2),
                                    decoration: BoxDecoration(
                                      color: isOccupied
                                          ? Colors.transparent
                                          : const Color(0xFFF9FAFB),
                                      border: Border.all(
                                        color: isOccupied
                                            ? Colors.transparent
                                            : const Color(0xFFE5E7EB),
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }).toList(),
                        ),

                        // 수업 블록
                        ..._days.asMap().entries.expand((dayEntry) {
                          final int dayIndex = dayEntry.key;
                          final String day = dayEntry.value;

                          return timetable
                              .where((entry) => entry.day == day)
                              .map((entry) {
                                // 표시 범위 밖의 수업은 그리지 않음
                                if (entry.endMinute <= timetableStartMinute ||
                                    entry.startMinute >= timetableEndMinute) {
                                  return const SizedBox.shrink();
                                }

                                // 표시 범위를 벗어나는 수업은 보이는 구간만 잘라서 표시
                                final int visibleStart =
                                    entry.startMinute < timetableStartMinute
                                    ? timetableStartMinute
                                    : entry.startMinute;

                                final int visibleEnd =
                                    entry.endMinute > timetableEndMinute
                                    ? timetableEndMinute
                                    : entry.endMinute;

                                final double top =
                                    ((visibleStart - timetableStartMinute) /
                                        60) *
                                    (_rowHeight + _gap);

                                final double left =
                                    _timeColumnWidth +
                                    dayIndex * (_dayColumnWidth + _gap);

                                final double calculatedHeight =
                                    ((visibleEnd - visibleStart) / 60) *
                                        (_rowHeight + _gap) -
                                    _gap;

                                final double blockHeight = calculatedHeight < 24
                                    ? 24
                                    : calculatedHeight;

                                return Positioned(
                                  top: top,
                                  left: left,
                                  width: _dayColumnWidth,
                                  height: blockHeight,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: _gap / 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: entry.color,
                                      borderRadius: BorderRadius.circular(7),
                                      boxShadow: [
                                        BoxShadow(
                                          color: entry.color.withOpacity(0.25),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _shortRoomName(entry.room),
                                        textAlign: TextAlign.center,
                                        maxLines: blockHeight < 36 ? 1 : 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          height: 1.15,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// 공통 위젯
// ─────────────────────────────────────────────

Widget _buildLabel(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF374151),
      ),
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  bool readOnly = false,
  VoidCallback? onTap,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    readOnly: readOnly,
    onTap: onTap,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.7),
      ),
    ),
  );
}

Widget _buildPrimaryButton({
  required String label,
  required VoidCallback onTap,
}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        elevation: 5,
        shadowColor: const Color(0x332563EB),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      ),
    ),
  );
}

Widget _buildToggleButton({
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF2563EB) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
          width: 1.5,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: selected ? Colors.white : const Color(0xFF374151),
        ),
      ),
    ),
  );
}
