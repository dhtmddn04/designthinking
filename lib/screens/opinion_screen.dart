import 'package:flutter/material.dart';
 
// ──────────────────────────────────────────────
//  하드코딩 더미 데이터
// ──────────────────────────────────────────────
const List<String> _locations = ['외대', '정문', '전정대'];
const List<String> _congestionLevels = ['여유', '보통', '약간 혼잡', '혼잡'];
 
const List<_TabData> _tabs = [
  _TabData(label: '정문'),
  _TabData(label: '외대'),
  _TabData(label: '전정대'),
];
 
const List<_CongestionRow> _congestionRows = [
  _CongestionRow(label: '여유',    count: 28, total: 72),
  _CongestionRow(label: '보통',    count: 35, total: 72, highlight: true),
  _CongestionRow(label: '약간 혼잡', count: 7,  total: 72),
  _CongestionRow(label: '혼잡',    count: 2,  total: 72),
];
 
// ──────────────────────────────────────────────
//  모델 클래스
// ──────────────────────────────────────────────
class _TabData {
  final String label;
  const _TabData({required this.label});
}
 
class _CongestionRow {
  final String label;
  final int count;
  final int total;
  final bool highlight;
  const _CongestionRow({
    required this.label,
    required this.count,
    required this.total,
    this.highlight = false,
  });
}
 
// ──────────────────────────────────────────────
//  메인 화면 위젯
// ──────────────────────────────────────────────
class OpinionScreen extends StatefulWidget {
  const OpinionScreen({super.key});
 
  @override
  State<OpinionScreen> createState() => _OpinionScreenState();
}
 
class _OpinionScreenState extends State<OpinionScreen> {
  // 드롭다운 선택 상태
  String _selectedLocation = '외대';
  String _selectedCongestion = '혼잡';
 
  // 탭 선택 상태
  int _selectedTab = 0;
 
  // 테마 색상
  static const Color _primary = Color(0xFF3B82F6); // 파란색
  static const Color _barColor = Color(0xFF3B82F6);
  static const Color _barBg   = Color(0xFFE5E7EB);
  static const Color _textDark = Color(0xFF111827);
  static const Color _textGray = Color(0xFF6B7280);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 상단 아이콘 ──────────────────
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 16, bottom: 4),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 28,
                  color: _primary,
                ),
              ),
 
              // ── 제목 ────────────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '실시간 혼잡도 제보',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '실제 정류장이나 버스의 혼잡도를 제보해 주세요.',
                  style: TextStyle(
                    fontSize: 13,
                    color: _textGray,
                  ),
                ),
              ),
              const SizedBox(height: 24),
 
              // ── 드롭다운 영역 ────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // 제보 위치
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
                            items: _locations,
                            onChanged: (v) =>
                                setState(() => _selectedLocation = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 체감 혼잡도
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
                            items: _congestionLevels,
                            onChanged: (v) =>
                                setState(() => _selectedCongestion = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
 
              // ── 제보하기 버튼 ─────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: API 연동 시 구현
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('제보가 접수되었습니다! (더미)')),
                      );
                    },
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text(
                      '제보하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
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
 
              // ── 실시간 제보 현황 헤더 ──────────
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
                          horizontal: 8, vertical: 3),
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
 
              // ── 탭 바 ────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
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
                              _tabs[i].label,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : _textGray,
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
 
              // ── 혼잡도 현황 카드 ──────────────
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
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카드 헤더
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _tabs[_selectedTab].label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                            ),
                          ),
                          Text(
                            '전체 72건',
                            style: const TextStyle(
                              fontSize: 13,
                              color: _textGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
 
                      // 혼잡도 바 리스트
                      ..._congestionRows.map(
                        (row) => _CongestionBar(row: row, barColor: _barColor, barBg: _barBg),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
 
              // ── 하단 안내 문구 ────────────────
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '* 데이터는 최근 15분 이내 학생들 제보를 기반으로 합니다.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
 
  // ── 드롭다운 공통 빌더 ──────────────────────
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF6B7280)),
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
//  혼잡도 바 행 위젯
// ──────────────────────────────────────────────
class _CongestionBar extends StatelessWidget {
  final _CongestionRow row;
  final Color barColor;
  final Color barBg;
 
  const _CongestionBar({
    required this.row,
    required this.barColor,
    required this.barBg,
  });
 
  @override
  Widget build(BuildContext context) {
    final ratio = row.total > 0 ? row.count / row.total : 0.0;
 
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          // 레이블
          SizedBox(
            width: 64,
            child: Text(
              row.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: row.highlight ? FontWeight.w700 : FontWeight.w400,
                color: row.highlight
                    ? const Color(0xFF111827)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 바
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  // 배경
                  Container(height: 10, color: barBg),
                  // 채워지는 부분
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: row.highlight
                            ? barColor
                            : const Color(0xFFBFDBFE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 건수
          SizedBox(
            width: 36,
            child: Text(
              '${row.count}건',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: row.highlight ? FontWeight.w700 : FontWeight.w400,
                color: row.highlight
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