import 'dart:async';
import 'package:flutter/material.dart';

class BoardingPredictionScreen extends StatefulWidget {
  final String stationName;
  final int waitingCountAtStart;
  final Map<String, dynamic>? recommendedBus;
  final List<Map<String, dynamic>> arrivals;
  final bool usesRealtimeWaitingCount;
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic> previousBus)
  onStillWaiting;

  const BoardingPredictionScreen({
    super.key,
    required this.stationName,
    required this.waitingCountAtStart,
    required this.recommendedBus,
    required this.arrivals,
    required this.usesRealtimeWaitingCount,
    required this.onStillWaiting,
  });

  @override
  State<BoardingPredictionScreen> createState() =>
      _BoardingPredictionScreenState();
}

class _BoardingPredictionScreenState extends State<BoardingPredictionScreen> {
  late int _waitingCountAtStart;
  Map<String, dynamic>? _recommendedBus;
  late List<Map<String, dynamic>> _arrivals;
  late bool _usesRealtimeWaitingCount;

  Timer? _arrivalTimer;
  DateTime? _recommendationCreatedAt;
  bool _hasRecommendedBusArrived = false;
  bool _isRefreshing = false;
  bool _boardingCompleted = false;

  @override
  void initState() {
    super.initState();
    _waitingCountAtStart = widget.waitingCountAtStart;
    _recommendedBus = widget.recommendedBus;
    _arrivals = widget.arrivals;
    _usesRealtimeWaitingCount = widget.usesRealtimeWaitingCount;
    _startArrivalTimer();
  }

  @override
  void dispose() {
    _arrivalTimer?.cancel();
    super.dispose();
  }

  String _busTime(Map<String, dynamic> bus) {
    return bus['expectedArrivalTime']?.toString() ??
        bus['departureTime']?.toString() ??
        '-';
  }

  String _busLabel(Map<String, dynamic> bus) {
    final busNumber = bus['busNumber']?.toString() ?? '-';
    return busNumber == '9' ? '9번 저상버스' : '$busNumber번';
  }

  void _startArrivalTimer() {
    _arrivalTimer?.cancel();
    _hasRecommendedBusArrived = false;
    _boardingCompleted = false;
    _recommendationCreatedAt = DateTime.now();

    if (_recommendedBus == null) {
      return;
    }

    final int arrivalMinute =
        (_recommendedBus!['arrivalMinute'] as num?)?.toInt() ?? 0;

    if (arrivalMinute <= 0) {
      _hasRecommendedBusArrived = true;
      return;
    }

    _arrivalTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final createdAt = _recommendationCreatedAt;
      if (!mounted || createdAt == null) return;

      final arrivalAt = createdAt.add(Duration(minutes: arrivalMinute));
      if (!DateTime.now().isBefore(arrivalAt)) {
        _arrivalTimer?.cancel();
        setState(() {
          _hasRecommendedBusArrived = true;
        });
      }
    });
  }

  Future<void> _refreshBecauseStillWaiting() async {
    final currentBus = _recommendedBus;
    if (currentBus == null || _isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final result = await widget.onStillWaiting(currentBus);
      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('다음 탑승 예상 정보를 불러올 수 없습니다.')),
        );
        return;
      }

      setState(() {
        _waitingCountAtStart = result['waitingCountAtStart'] as int;
        _recommendedBus = result['recommendedBus'] as Map<String, dynamic>?;
        _arrivals = List<Map<String, dynamic>>.from(result['arrivals']);
        _usesRealtimeWaitingCount =
            result['usesRealtimeWaitingCount'] == true;
      });

      _startArrivalTimer();
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _completeBoarding() {
    _arrivalTimer?.cancel();
    setState(() {
      _boardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasRecommendation = _recommendedBus != null;
    final int? arrivalOrder = _recommendedBus?['arrivalOrder'] as int?;
    final String ruleText =
        _recommendedBus?['ruleText']?.toString() ?? '탑승 가능 예상';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leadingWidth: 58,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
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
        ),
        titleSpacing: 12,
        title: const Text(
          '내 탑승 예상',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF111827),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '예상 탑승 버스',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (hasRecommendation) ...[
                      Text(
                        _busLabel(_recommendedBus!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_recommendedBus!['arrival']} 도착 예정 · ${_busTime(_recommendedBus!)}',
                        style: const TextStyle(
                          color: Color(0xFFFFF176),
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ruleText,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        '현재 확인 가능한 버스 중\n탑승 가능한 버스를 찾지 못했어요',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _InfoRow(label: '정류장', value: widget.stationName),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: '줄서기 시작 당시 대기인원',
                      value: '$_waitingCountAtStart명',
                    ),
                    if (hasRecommendation && arrivalOrder != null) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: '예상 탑승 순서',
                        value: '$arrivalOrder번째 도착 버스',
                      ),
                    ],
                  ],
                ),
              ),
              if (hasRecommendation &&
                  _hasRecommendedBusArrived &&
                  !_boardingCompleted) ...[
                const SizedBox(height: 16),
                _ArrivalConfirmationCard(
                  isRefreshing: _isRefreshing,
                  onBoarded: _completeBoarding,
                  onStillWaiting: _refreshBecauseStillWaiting,
                ),
              ],
              if (_boardingCompleted) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFDF4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Text(
                    '탑승 완료로 처리되었습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF166534),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                '도착 예정 버스 확인',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ..._arrivals.map((bus) {
                final bool isRecommended = bus['isRecommended'] == true;
                final String capacityText =
                    bus['capacityText']?.toString() ?? '탑승 판단 정보 없음';
                final String statusText = isRecommended
                    ? '탑승 가능 예상'
                    : bus['statusText']?.toString() ?? '판단 불가';

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isRecommended
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isRecommended
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.directions_bus_filled_rounded,
                          color: isRecommended
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _busLabel(bus),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${bus['arrival']} · ${_busTime(bus)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            capacityText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isRecommended
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrivalConfirmationCard extends StatelessWidget {
  final bool isRefreshing;
  final VoidCallback onBoarded;
  final VoidCallback onStillWaiting;

  const _ArrivalConfirmationCard({
    required this.isRefreshing,
    required this.onBoarded,
    required this.onStillWaiting,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '예상 버스가 도착했어요',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '탑승 여부를 선택하면 안내를 이어갈 수 있어요.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isRefreshing ? null : onBoarded,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: const Text(
                    '탑승 완료',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: isRefreshing ? null : onStillWaiting,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF93C5FD)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                  child: Text(
                    isRefreshing ? '확인 중...' : '아직 대기 중',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF111827),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
