import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';

// ──────────────────────────────────────────────
//  상수 데이터
// ──────────────────────────────────────────────
const List<String> _locations = ['정문', '외대', '전정대'];
const List<String> _congestionLevels = ['여유', '보통', '약간 혼잡', '혼잡'];
const List<String> _tabLabels = ['정문', '외대', '전정대'];
const Duration _cooldown = Duration(hours: 1);

// ──────────────────────────────────────────────
//  StatefulWidget
// ──────────────────────────────────────────────
class OpinionScreen extends StatefulWidget {
  const OpinionScreen({super.key});

  @override
  State<OpinionScreen> createState() => _OpinionScreenState();
}

// ──────────────────────────────────────────────
//  State  (AutomaticKeepAliveClientMixin → 탭 이동 시 State 유지)
// ──────────────────────────────────────────────
class _OpinionScreenState extends State<OpinionScreen>
    with AutomaticKeepAliveClientMixin {
  // ── 드롭다운 선택 상태 (null = 미선택) ──────
  String? _selectedLocation;
  String? _selectedCongestion;

  // ── 탭 선택 상태 ─────────────────────────────
  int _selectedTab = 0;

  // ── 혼잡도 카운트 데이터 ─────────────────────
  final Map<String, Map<String, int>> _counts = {
    for (final loc in _tabLabels)
      loc: {for (final level in _congestionLevels) level: 0},
  };

  // ── 마지막 제보 시각 ─────────────────────────
  DateTime? _lastReportedAt;

  // ── 1초 타이머 (쿨다운 카운트다운) ───────────
  Timer? _ticker;
  Timer? _summaryTimer;

  // ── 테마 색상 ────────────────────────────────
  static const Color _primary = Color(0xFF3B82F6);
  static const Color _barColor = Color(0xFF3B82F6);
  static const Color _barBg = Color(0xFFE5E7EB);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textGray = Color(0xFF6B7280);

  // ── AutomaticKeepAliveClientMixin 필수 ───────
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _loadOpinionSummaries();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_canReport) setState(() {});
    });

    _summaryTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadOpinionSummaries();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _summaryTimer?.cancel();
    super.dispose();
  }

  // ── 쿨다운 계산 ──────────────────────────────
  Duration get _remainingCooldown {
    if (_lastReportedAt == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastReportedAt!);
    if (elapsed >= _cooldown) return Duration.zero;
    return _cooldown - elapsed;
  }

  bool get _canReport => _remainingCooldown == Duration.zero;

  String get _cooldownText {
    final r = _remainingCooldown;
    final m = r.inMinutes;
    final s = r.inSeconds % 60;
    if (m > 0) return '$m분 $s초';
    return '$s초';
  }

  // ── 제보 처리 ────────────────────────────────
  Future<void> _submitReport() async {
    if (_selectedLocation == null || _selectedCongestion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedLocation == null ? '제보 위치를 선택해 주세요.' : '체감 혼잡도를 선택해 주세요.',
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (!_canReport) {
      _showCooldownDialog();
      return;
    }

    try {
      final result = await ApiService.submitOpinion(
        stopName: _selectedLocation!,
        congestionLevel: _selectedCongestion!,
        comment: null,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        setState(() {
          _lastReportedAt = DateTime.now();
        });

        final tabIndex = _tabLabels.indexOf(_selectedLocation!);
        if (tabIndex != -1) {
          setState(() {
            _selectedTab = tabIndex;
          });
        }

        await _loadOpinionSummaries();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '[$_selectedLocation] $_selectedCongestion 제보 완료!\n'
              '1시간 후 다시 제보할 수 있어요.',
            ),
            backgroundColor: _primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? '제보 저장에 실패했습니다.'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('서버에 연결할 수 없습니다.'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _loadOpinionSummaries() async {
    try {
      final result = await ApiService.getOpinionSummaries();

      if (!mounted) return;

      if (result['success'] == true) {
        final summaries = result['summaries'] as Map<String, dynamic>;

        setState(() {
          for (final location in _locations) {
            final summary = summaries[location];
            if (summary == null) continue;

            final levelCounts = summary['levelCounts'] as Map<String, dynamic>;

            for (final level in _congestionLevels) {
              _counts[location]![level] = levelCounts[level] ?? 0;
            }
          }
        });
      }
    } catch (e) {
      // 홈/의견 화면 진입 때마다 에러 팝업 뜨면 거슬리니까 일단 조용히 무시
    }
  }

  // ── 쿨다운 다이얼로그 ────────────────────────
  void _showCooldownDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.timer_outlined, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('잠깐!', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          '제보는 1시간에 한 번만 가능해요.\n\n⏱ $_cooldownText 후 제보 가능합니다',
          style: const TextStyle(fontSize: 14, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              '확인',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 현재 탭 전체 건수 ────────────────────────
  int get _currentTotal {
    final loc = _tabLabels[_selectedTab];
    return _counts[loc]!.values.fold(0, (a, b) => a + b);
  }

  // ── 현재 탭 최다 혼잡도 (highlight) ──────────
  String? get _highlightLevel {
    final loc = _tabLabels[_selectedTab];
    final map = _counts[loc]!;
    final total = map.values.fold(0, (a, b) => a + b);
    if (total == 0) return null;
    return map.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  // ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 필수
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 제목 ──────────────────────
              const Padding(
                padding: const EdgeInsets.fromLTRB(20, 44, 20, 0),
                child: Text(
                  '실시간 혼잡도 제보',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '실제 정류장의 혼잡도를 제보해 주세요.',
                  style: TextStyle(fontSize: 14, color: _textGray),
                ),
              ),
              const SizedBox(height: 24),

              // ── 드롭다운 ──────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '제보 위치',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _selectedLocation,
                            hint: '위치 선택',
                            items: _locations,
                            onChanged: (v) =>
                                setState(() => _selectedLocation = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '체감 혼잡도',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDropdown(
                            value: _selectedCongestion,
                            hint: '혼잡도 선택',
                            items: _congestionLevels,
                            onChanged: (v) =>
                                setState(() => _selectedCongestion = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── 제보하기 버튼 ──────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _submitReport,
                    icon: Icon(
                      _canReport ? Icons.play_arrow : Icons.lock_clock,
                      size: 20,
                    ),
                    label: Text(
                      _canReport ? '제보하기' : '$_cooldownText 후 제보 가능합니다',
                      style: TextStyle(
                        fontSize: _canReport ? 16 : 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canReport
                          ? _primary
                          : const Color(0xFF9CA3AF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── 실시간 제보 현황 헤더 ──────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text(
                      '실시간 제보 현황',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '학생들이 제보한 실시간 혼잡 데이터를 확인하세요.',
                  style: TextStyle(fontSize: 13, color: _textGray),
                ),
              ),
              const SizedBox(height: 16),

              // ── 탭 바 ─────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: List.generate(_tabLabels.length, (i) {
                      final isSelected = _selectedTab == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? _primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _tabLabels[i],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : _textGray,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── 혼잡도 카드 ───────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _tabLabels[_selectedTab],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            '전체 $_currentTotal건',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ...() {
                        final loc = _tabLabels[_selectedTab];
                        final total = _currentTotal;
                        final highlight = _highlightLevel;
                        return _congestionLevels.map((level) {
                          final count = _counts[loc]![level] ?? 0;
                          return _CongestionBar(
                            label: level,
                            count: count,
                            total: total,
                            highlight: highlight != null && level == highlight,
                            barColor: _barColor,
                            barBg: _barBg,
                          );
                        });
                      }(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── 하단 안내 문구 (가운데 정렬) ─
              const SizedBox(
                width: double.infinity,
                child: Text(
                  '* 데이터는 최근 5분 이내 학생들 제보를 기반으로 합니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── 드롭다운 빌더 ────────────────────────────
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value == null
              ? const Color(0xFF3B82F6)
              : const Color(0xFFD1D5DB),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6B7280),
          ),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
//  혼잡도 바 위젯
// ──────────────────────────────────────────────
class _CongestionBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final bool highlight;
  final Color barColor;
  final Color barBg;

  const _CongestionBar({
    required this.label,
    required this.count,
    required this.total,
    required this.highlight,
    required this.barColor,
    required this.barBg,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
                color: highlight
                    ? const Color(0xFF111827)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Container(height: 10, color: barBg),
                  FractionallySizedBox(
                    widthFactor: ratio.clamp(0.0, 1.0),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: highlight ? barColor : const Color(0xFFBFDBFE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(
              '$count건',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
                color: highlight
                    ? const Color(0xFF111827)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
