import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// 데이터 모델
// ─────────────────────────────────────────────

class TimetableEntry {
  final String day;
  final int startTime;
  final int duration;
  final String room;
  final Color color;

  TimetableEntry({
    required this.day,
    required this.startTime,
    required this.duration,
    required this.room,
    required this.color,
  });
}

final List<TimetableEntry> initialTimetable = [
  TimetableEntry(
    day: '월',
    startTime: 9,
    duration: 2,
    room: '공학관 301',
    color: Colors.blue,
  ),
  TimetableEntry(
    day: '월',
    startTime: 13,
    duration: 3,
    room: '본관 201',
    color: Colors.green,
  ),
  TimetableEntry(
    day: '화',
    startTime: 10,
    duration: 2,
    room: '공학관 205',
    color: Colors.purple,
  ),
  TimetableEntry(
    day: '수',
    startTime: 9,
    duration: 2,
    room: '공학관 301',
    color: Colors.blue,
  ),
  TimetableEntry(
    day: '수',
    startTime: 14,
    duration: 2,
    room: '중앙도서관 501',
    color: Colors.orange,
  ),
  TimetableEntry(
    day: '목',
    startTime: 10,
    duration: 2,
    room: '공학관 205',
    color: Colors.purple,
  ),
  TimetableEntry(
    day: '금',
    startTime: 13,
    duration: 3,
    room: '본관 201',
    color: Colors.green,
  ),
];

// ─────────────────────────────────────────────
// 프로필 탭 메인 화면
// main_screen.dart에서 ProfileScreen()으로 연결되는 화면
// ─────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _showSignup = false;
  String _loggedInUser = '';
  List<TimetableEntry> _timetable = List.from(initialTimetable);

  void _login(String username) {
    setState(() {
      _isLoggedIn = true;
      _loggedInUser = username.isEmpty ? 'XXXXXXXX' : username;
    });
  }

  void _logout() {
    setState(() {
      _isLoggedIn = false;
      _loggedInUser = '';
      _showSignup = false;
    });
  }

  void _updateTimetable(List<TimetableEntry> updatedTimetable) {
    setState(() {
      _timetable = updatedTimetable;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn && _showSignup) {
      return SignupView(
        onBackToLogin: () {
          setState(() {
            _showSignup = false;
          });
        },
      );
    }

    if (!_isLoggedIn) {
      return LoginView(
        onLogin: _login,
        onSignup: () {
          setState(() {
            _showSignup = true;
          });
        },
      );
    }

    return ProfileContentView(
      username: _loggedInUser,
      timetable: _timetable,
      onLogout: _logout,
      onTimetableUpdated: _updateTimetable,
    );
  }
}

// ─────────────────────────────────────────────
// 1. 로그인 화면
// ─────────────────────────────────────────────

class LoginView extends StatefulWidget {
  final void Function(String username) onLogin;
  final VoidCallback onSignup;

  const LoginView({
    super.key,
    required this.onLogin,
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
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
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
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF2563EB),
                      ],
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

                const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  '계정에 로그인하세요',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 34),

                _buildLabel('아이디'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _usernameController,
                  hintText: '아이디를 입력하세요',
                ),

                const SizedBox(height: 16),

                _buildLabel('비밀번호'),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _passwordController,
                  hintText: '비밀번호를 입력하세요',
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
                      child: const Text(
                        '자동 로그인',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _buildPrimaryButton(
                  label: '로그인',
                  onTap: () {
                    widget.onLogin(_usernameController.text.trim());
                  },
                ),

                const SizedBox(height: 18),

                TextButton(
                  onPressed: widget.onSignup,
                  child: const Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 2. 회원가입 화면
// ─────────────────────────────────────────────

class SignupView extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const SignupView({
    super.key,
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
  final TextEditingController _phoneController = TextEditingController();

  bool _needsWheelchair = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 32, 22, 90),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                '새 계정을 만들어보세요',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 30),

              _buildLabel('아이디'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _usernameController,
                hintText: '아이디를 입력하세요',
              ),

              const SizedBox(height: 16),

              _buildLabel('비밀번호'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordController,
                hintText: '비밀번호를 입력하세요',
                obscureText: true,
              ),

              const SizedBox(height: 16),

              _buildLabel('비밀번호 재확인'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _passwordConfirmController,
                hintText: '비밀번호를 다시 입력하세요',
                obscureText: true,
              ),

              const SizedBox(height: 16),

              _buildLabel('휴대전화'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                hintText: '010-1234-5678',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 18),

              _buildLabel('휠체어 탑승 여부'),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildToggleButton(
                      label: '예',
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
                      label: '아니오',
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
                label: '가입하기',
                onTap: () {
                  widget.onBackToLogin();
                },
              ),

              const SizedBox(height: 18),

              Center(
                child: TextButton(
                  onPressed: widget.onBackToLogin,
                  child: const Text(
                    '이미 계정이 있으신가요? 로그인',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
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
// 3. 로그인 후 프로필 화면
// ─────────────────────────────────────────────

class ProfileContentView extends StatelessWidget {
  final String username;
  final List<TimetableEntry> timetable;
  final VoidCallback onLogout;
  final void Function(List<TimetableEntry>) onTimetableUpdated;

  const ProfileContentView({
    super.key,
    required this.username,
    required this.timetable,
    required this.onLogout,
    required this.onTimetableUpdated,
  });

  @override
  Widget build(BuildContext context) {
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
                        colors: [
                          Color(0xFF3B82F6),
                          Color(0xFF2563EB),
                        ],
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '아이디',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
              color: Color(0xFFE5E7EB),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                child: Column(
                  children: [
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
                              const Text(
                                '시간표',
                                style: TextStyle(
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
                        child: const Text(
                          '로그아웃',
                          style: TextStyle(
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

// ─────────────────────────────────────────────
// 4. 시간표 편집 화면
// ─────────────────────────────────────────────

class TimetableEditScreen extends StatefulWidget {
  final List<TimetableEntry> timetable;
  final void Function(List<TimetableEntry>) onSave;

  const TimetableEditScreen({
    super.key,
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

  int _startTime = 9;
  int _endTime = 10;

  final TextEditingController _roomController = TextEditingController();

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.red,
  ];

  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _timetable = List.from(widget.timetable);

    _roomController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  bool get _canAddClass {
    return _selectedDays.isNotEmpty &&
        _roomController.text.trim().isNotEmpty &&
        _startTime < _endTime;
  }

  void _addClass() {
    if (!_canAddClass) return;

    final Color color = _colors[_colorIndex % _colors.length];
    _colorIndex++;

    final List<TimetableEntry> newEntries = _selectedDays.map((day) {
      return TimetableEntry(
        day: day,
        startTime: _startTime,
        duration: _endTime - _startTime,
        room: _roomController.text.trim(),
        color: color,
      );
    }).toList();

    setState(() {
      _timetable = [
        ..._timetable,
        ...newEntries,
      ];
      _selectedDays.clear();
      _startTime = 9;
      _endTime = 10;
      _roomController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<int> hours = List.generate(10, (index) => index + 9);

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
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '시간표 편집',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '수업 정보를 입력하세요',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(
              height: 1,
              color: Color(0xFFE5E7EB),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  children: [
                    _sectionCard(
                      title: '현재 시간표',
                      child: TimetableGrid(timetable: _timetable),
                    ),

                    const SizedBox(height: 16),

                    _sectionCard(
                      title: '수업 추가',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('요일'),
                          const SizedBox(height: 8),

                          Row(
                            children: _days.map((day) {
                              final bool selected =
                              _selectedDays.contains(day);

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
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
                                      day,
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
                                    _buildLabel('시작 시간'),
                                    const SizedBox(height: 8),
                                    _buildDropdown(
                                      value: _startTime,
                                      items: hours,
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() {
                                          _startTime = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('종료 시간'),
                                    const SizedBox(height: 8),
                                    _buildDropdown(
                                      value: _endTime,
                                      items: hours,
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() {
                                          _endTime = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          _buildLabel('강의실'),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _roomController,
                            hintText: '예: 공학관 301',
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _canAddClass ? _addClass : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                disabledBackgroundColor:
                                const Color(0xFFE5E7EB),
                                foregroundColor: Colors.white,
                                disabledForegroundColor:
                                const Color(0xFF9CA3AF),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                              child: const Text(
                                '수업 추가',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

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
                        child: const Text(
                          '완료',
                          style: TextStyle(
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

  Widget _sectionCard({
    required String title,
    required Widget child,
  }) {
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

  Widget _buildDropdown({
    required int value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: DropdownButton<int>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: items.map((hour) {
          return DropdownMenuItem<int>(
            value: hour,
            child: Text(
              '$hour:00',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// 시간표 그리드
// ─────────────────────────────────────────────

class TimetableGrid extends StatelessWidget {
  final List<TimetableEntry> timetable;

  const TimetableGrid({
    super.key,
    required this.timetable,
  });

  static const List<String> _days = ['월', '화', '수', '목', '금'];
  static const List<int> _hours = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18];

  static const double _timeColumnWidth = 24;
  static const double _dayColumnWidth = 48;
  static const double _rowHeight = 32;
  static const double _gap = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: _timeColumnWidth),
            ..._days.map((day) {
              return SizedBox(
                width: _dayColumnWidth,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: _gap / 2),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF374151),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),

        const SizedBox(height: 5),

        Stack(
          children: [
            Column(
              children: _hours.map((hour) {
                return Row(
                  children: [
                    SizedBox(
                      width: _timeColumnWidth,
                      height: _rowHeight,
                      child: Center(
                        child: Text(
                          '$hour',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                    ..._days.map((day) {
                      final bool isOccupied = timetable.any((entry) {
                        return entry.day == day &&
                            hour >= entry.startTime &&
                            hour < entry.startTime + entry.duration;
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
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),

            ..._days.asMap().entries.expand((dayEntry) {
              final int dayIndex = dayEntry.key;
              final String day = dayEntry.value;

              return timetable.where((entry) => entry.day == day).map((entry) {
                final int hourIndex = _hours.indexOf(entry.startTime);
                if (hourIndex == -1) {
                  return const SizedBox.shrink();
                }

                final double top = hourIndex * (_rowHeight + _gap);
                final double left =
                    _timeColumnWidth + dayIndex * (_dayColumnWidth + _gap);
                final double height = entry.duration * (_rowHeight + _gap) - _gap;

                return Positioned(
                  top: top,
                  left: left,
                  width: _dayColumnWidth,
                  height: height,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: _gap / 2),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: entry.color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Text(
                        entry.room,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
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
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
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
        borderSide: const BorderSide(
          color: Color(0xFF2563EB),
          width: 1.7,
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
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