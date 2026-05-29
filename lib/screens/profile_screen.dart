import 'package:flutter/material.dart';
import '../services/api_service.dart';

// ─────────────────────────────────────────────
// 데이터 모델
// ─────────────────────────────────────────────

class TimetableEntry {
  final int? id;
  final String day;
  final int startMinute;
  final int endMinute;
  final String room;
  final Color color;

  TimetableEntry({
    this.id,
    required this.day,
    required this.startMinute,
    required this.endMinute,
    required this.room,
    required this.color,
  });
}

final List<TimetableEntry> initialTimetable = [
  TimetableEntry(
    day: '월',
    startMinute: 9 * 60,
    endMinute: 11 * 60,
    room: '공학관 301',
    color: Colors.blue,
  ),
  TimetableEntry(
    day: '월',
    startMinute: 13 * 60,
    endMinute: 16 * 60,
    room: '본관 201',
    color: Colors.green,
  ),
  TimetableEntry(
    day: '화',
    startMinute: 10 * 60 + 15,
    endMinute: 12 * 60,
    room: '공학관 205',
    color: Colors.purple,
  ),
  TimetableEntry(
    day: '수',
    startMinute: 9 * 60,
    endMinute: 11 * 60,
    room: '공학관 301',
    color: Colors.blue,
  ),
  TimetableEntry(
    day: '수',
    startMinute: 14 * 60 + 30,
    endMinute: 16 * 60,
    room: '중앙도서관 501',
    color: Colors.orange,
  ),
  TimetableEntry(
    day: '목',
    startMinute: 10 * 60,
    endMinute: 12 * 60,
    room: '공학관 205',
    color: Colors.purple,
  ),
  TimetableEntry(
    day: '금',
    startMinute: 13 * 60,
    endMinute: 16 * 60,
    room: '본관 201',
    color: Colors.green,
  ),
];

// ─────────────────────────────────────────────
// 프로필 탭 메인 화면
// ─────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  final int? userId;
  final void Function(Map<String, dynamic> user) onLoginSuccess;
  final VoidCallback onLogoutSuccess;

  const ProfileScreen({
    super.key,
    required this.userId,
    required this.onLoginSuccess,
    required this.onLogoutSuccess,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _showSignup = false;
  String _loggedInUser = '';
  //List<TimetableEntry> _timetable = List.from(initialTimetable);
  List<TimetableEntry> _timetable = [];

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
      _timetable = [];
    });

    widget.onLogoutSuccess();
  }

  void _updateTimetable(List<TimetableEntry> updatedTimetable) {
    setState(() {
      _timetable = updatedTimetable;
    });
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
              room: '$buildingName $roomNumber',
              color: colors[index % colors.length],
            );
          }).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('시간표를 불러올 수 없습니다.')));
    }
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId && widget.userId != null) {
      _loadTimetable(widget.userId!);
    }
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
      timetable: _timetable,
      onLogout: _logout,
      onTimetableUpdated: _updateTimetable,
    );
  }
}

// ─────────────────────────────────────────────
// 로그인 화면
// ─────────────────────────────────────────────

class LoginView extends StatefulWidget {
  final void Function(String username) onLogin;
  final void Function(Map<String, dynamic> user) onLoginSuccess;
  final VoidCallback onSignup;

  const LoginView({
    super.key,
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
                const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  '계정에 로그인하세요',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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
                  onTap: () async {
                    final username = _usernameController.text.trim();
                    final password = _passwordController.text.trim();

                    if (username.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요.')),
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
                            result['message'] ?? '로그인 결과를 확인할 수 없습니다.',
                          ),
                        ),
                      );

                      if (result['success'] == true) {
                        final user = result['user'];

                        widget.onLogin(user['username']);
                        widget.onLoginSuccess(user);
                      }
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('서버에 연결할 수 없습니다.')),
                      );
                    }
                  },
                ),

                const SizedBox(height: 18),

                TextButton(
                  onPressed: widget.onSignup,
                  child: const Text(
                    '회원가입',
                    style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
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
// 회원가입 화면
// ─────────────────────────────────────────────

class SignupView extends StatefulWidget {
  final VoidCallback onBackToLogin;

  const SignupView({super.key, required this.onBackToLogin});

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
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                '새 계정을 만들어보세요',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
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
                onTap: () async {
                  final username = _usernameController.text.trim();
                  final password = _passwordController.text.trim();
                  final passwordConfirm = _passwordConfirmController.text
                      .trim();
                  final phone = _phoneController.text.trim();

                  if (username.isEmpty ||
                      password.isEmpty ||
                      passwordConfirm.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요.')),
                    );
                    return;
                  }

                  if (password != passwordConfirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                    );
                    return;
                  }

                  try {
                    final result = await ApiService.signup(
                      username: username,
                      password: password,
                      phone: phone,
                      needsWheelchair: _needsWheelchair,
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result['message'] ?? '회원가입 결과를 확인할 수 없습니다.',
                        ),
                      ),
                    );

                    if (result['success'] == true) {
                      widget.onBackToLogin();
                    }
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('서버에 연결할 수 없습니다.')),
                    );
                  }
                },
              ),

              const SizedBox(height: 18),

              Center(
                child: TextButton(
                  onPressed: widget.onBackToLogin,
                  child: const Text(
                    '이미 계정이 있으신가요? 로그인',
                    style: TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
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
// 로그인 후 프로필 화면
// ─────────────────────────────────────────────

class ProfileContentView extends StatelessWidget {
  final int? userId;
  final String username;
  final List<TimetableEntry> timetable;
  final VoidCallback onLogout;
  final void Function(List<TimetableEntry>) onTimetableUpdated;

  const ProfileContentView({
    super.key,
    required this.userId,
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
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

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

  int _colorIndex = 0;

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

  bool get _canAddClass {
    final startMinute = _parseTimeToMinute(_startTimeController.text);
    final endMinute = _parseTimeToMinute(_endTimeController.text);

    return _selectedDays.isNotEmpty &&
        _roomNumberController.text.trim().isNotEmpty &&
        startMinute != null &&
        endMinute != null &&
        startMinute < endMinute;
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
          room: '$buildingName $roomNumber',
          color: _colors[index % _colors.length],
        );
      }).toList();
    });

    widget.onSave(_timetable);
  }

  Future<void> _addClass() async {
    final userId = widget.userId;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    final startMinute = _parseTimeToMinute(_startTimeController.text);
    final endMinute = _parseTimeToMinute(_endTimeController.text);

    if (!_canAddClass || startMinute == null || endMinute == null) return;

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

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? '시간표 추가에 실패했습니다.')),
          );
          return;
        }
      }

      if (!mounted) return;

      await _loadSchedulesFromServer();

      setState(() {
        _selectedDays.clear();
        _startTimeController.text = '09:00';
        _endTimeController.text = '10:00';
        _roomNumberController.clear();
        _selectedBuilding = '공학관';
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('시간표가 추가되었습니다.')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서버에 연결할 수 없습니다.')));
    }
  }

  String _formatMinute(int minute) {
    final hour = minute ~/ 60;
    final min = minute % 60;

    final hourText = hour.toString().padLeft(2, '0');
    final minuteText = min.toString().padLeft(2, '0');

    return '$hourText:$minuteText';
  }

  Future<void> _deleteClass(int index) async {
    final userId = widget.userId;

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    final entry = _timetable[index];

    if (entry.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('삭제할 시간표 정보를 찾을 수 없습니다.')));
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
        ).showSnackBar(const SnackBar(content: Text('시간표가 삭제되었습니다.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? '시간표 삭제에 실패했습니다.')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('서버에 연결할 수 없습니다.')));
    }
  }

  void _confirmDeleteClass(int index) {
    final entry = _timetable[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '수업 삭제',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            '${entry.day}요일 ${_formatMinute(entry.startMinute)}~${_formatMinute(entry.endMinute)}\n'
            '${entry.room} 수업을 삭제할까요?',
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                '취소',
                style: TextStyle(
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
              child: const Text(
                '삭제',
                style: TextStyle(
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

            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
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
                              final bool selected = _selectedDays.contains(day);

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
                                    _buildTextField(
                                      controller: _startTimeController,
                                      hintText: '예: 09:15',
                                      keyboardType: TextInputType.datetime,
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
                                    _buildTextField(
                                      controller: _endTimeController,
                                      hintText: '예: 10:45',
                                      keyboardType: TextInputType.datetime,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          _buildLabel('강의실'),
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
                                  hintText: '예: 101',
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _canAddClass ? _addClass : null,
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

                    if (_timetable.isNotEmpty) ...[
                      const SizedBox(height: 16),

                      _sectionCard(
                        title: '수업 목록',
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
                                          '${entry.day}요일 ${_formatMinute(entry.startMinute)}~${_formatMinute(entry.endMinute)}',
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
  static const List<int> _hours = [9, 10, 11, 12, 13, 14, 15, 16, 17, 18];

  static const double _timeColumnWidth = 24;
  static const double _dayColumnWidth = 48;
  static const double _rowHeight = 32;
  static const double _gap = 2;

  @override
  Widget build(BuildContext context) {
    final double gridWidth =
        _timeColumnWidth + (_dayColumnWidth + _gap) * _days.length;

    return Center(
      child: SizedBox(
        width: gridWidth,
        child: Column(
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
                          final int cellStart = hour * 60;
                          final int cellEnd = (hour + 1) * 60;

                          final bool isOccupied = timetable.any((entry) {
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

                  return timetable.where((entry) => entry.day == day).map((
                    entry,
                  ) {
                    final int timetableStartMinute = _hours.first * 60;
                    final int timetableEndMinute = (_hours.last + 1) * 60;

                    if (entry.endMinute <= timetableStartMinute ||
                        entry.startMinute >= timetableEndMinute) {
                      return const SizedBox.shrink();
                    }

                    final int visibleStart =
                        entry.startMinute < timetableStartMinute
                        ? timetableStartMinute
                        : entry.startMinute;

                    final int visibleEnd = entry.endMinute > timetableEndMinute
                        ? timetableEndMinute
                        : entry.endMinute;

                    final double top =
                        ((visibleStart - timetableStartMinute) / 60) *
                        (_rowHeight + _gap);

                    final double left =
                        _timeColumnWidth + dayIndex * (_dayColumnWidth + _gap);

                    final double height =
                        ((visibleEnd - visibleStart) / 60) *
                            (_rowHeight + _gap) -
                        _gap;

                    return Positioned(
                      top: top,
                      left: left,
                      width: _dayColumnWidth,
                      height: height < 20 ? 20 : height,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: _gap / 2,
                        ),
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
        ),
      ),
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
