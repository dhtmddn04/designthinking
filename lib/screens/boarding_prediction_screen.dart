import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

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

  String _stationDisplayName(BuildContext context, String station) {
    final l10n = AppLocalizations.of(context)!;

    switch (station) {
      case '정문':
        return l10n.mainGateStation;
      case '외대':
        return l10n.oedaeStation;
      case '전정대':
        return l10n.jeonjeongdaeStation;
      default:
        return station;
    }
  }

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

  String _busLabel(BuildContext context, Map<String, dynamic> bus) {
    final l10n = AppLocalizations.of(context)!;
    final busNumber = bus['busNumber']?.toString() ?? '-';

    if (busNumber == '9') {
      return l10n.lowFloorBus9;
    }

    return l10n.busNumberLabel(busNumber);
  }

  String _displayArrivalText(BuildContext context, String raw) {
    final l10n = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    if (!isEnglish) return raw;

    final minuteMatch = RegExp(r'^(\d+)분 후$').firstMatch(raw);
    if (minuteMatch != null) {
      final minute = int.parse(minuteMatch.group(1)!);
      return l10n.arrivalInMinutes(minute);
    }

    if (raw == '곧 출발') return 'soon';
    if (raw == '오늘 운행 정보가 없습니다') return l10n.noBusServiceToday;
    if (raw == '현재 도착 정보가 없습니다') return l10n.noServiceInfo;

    return raw;
  }

  String _predictionText(BuildContext context, String raw) {
    final l10n = AppLocalizations.of(context)!;

    switch (raw) {
      case '탑승 가능 예상':
        return l10n.boardableExpected;
      case '판단 불가':
        return l10n.cannotJudge;
      case '탑승 어려움':
        return l10n.boardingDifficult;
      case '추천 버스 이후 도착':
        return l10n.afterRecommendedBus;
      case '이전 예상 버스':
        return l10n.previousRecommendedBus;
      case '탑승하지 않음':
        return l10n.notBoarded;
      case '탑승 판단 정보 없음':
        return l10n.noBoardingDecisionInfo;
      default:
        return raw;
    }
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
    final l10n = AppLocalizations.of(context)!;
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
          SnackBar(content: Text(l10n.nextBoardingPredictionLoadFailed)),
        );
        return;
      }

      setState(() {
        _waitingCountAtStart = result['waitingCountAtStart'] as int;
        _recommendedBus = result['recommendedBus'] as Map<String, dynamic>?;
        _arrivals = List<Map<String, dynamic>>.from(result['arrivals']);
        _usesRealtimeWaitingCount = result['usesRealtimeWaitingCount'] == true;
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
    final l10n = AppLocalizations.of(context)!;
    final bool hasRecommendation = _recommendedBus != null;
    final int? arrivalOrder = _recommendedBus?['arrivalOrder'] as int?;
    final String ruleText = _predictionText(
      context,
      _recommendedBus?['ruleText']?.toString() ?? '탑승 가능 예상',
    );

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
        title: Text(
          l10n.boardingPredictionTitle,
          style: const TextStyle(
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
                    Text(
                      l10n.expectedBoardingBus,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (hasRecommendation) ...[
                      Text(
                        _busLabel(context, _recommendedBus!),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.arrivalScheduledText(
                          _displayArrivalText(
                            context,
                            _recommendedBus!['arrival']?.toString() ?? '-',
                          ),
                          _busTime(_recommendedBus!),
                        ),
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
                      Text(
                        l10n.noBoardableBusFound,
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
                    _InfoRow(
                      label: l10n.stopLabel,
                      value: _stationDisplayName(context, widget.stationName),
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      label: l10n.waitingCountAtStart,
                      value: l10n.peopleCount(_waitingCountAtStart),
                    ),
                    if (hasRecommendation && arrivalOrder != null) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: l10n.expectedBoardingOrder,
                        value: l10n.arrivalOrderBus(arrivalOrder),
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
                  child: Text(
                    l10n.boardingCompletedMessage,
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
              Text(
                l10n.expectedBusListTitle,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 12),
              ..._arrivals.map((bus) {
                final bool isRecommended = bus['isRecommended'] == true;
                final String capacityText = _predictionText(
                  context,
                  bus['capacityText']?.toString() ?? '탑승 판단 정보 없음',
                );

                final String statusText = isRecommended
                    ? l10n.boardableExpected
                    : _predictionText(
                        context,
                        bus['statusText']?.toString() ?? '판단 불가',
                      );

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
                              _busLabel(context, bus),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_displayArrivalText(context, bus['arrival']?.toString() ?? '-')} · ${_busTime(bus)}',
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
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF374151),
                              height: 1.4,
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
    final l10n = AppLocalizations.of(context)!;
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
          Text(
            l10n.expectedBusArrivedTitle,
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.expectedBusArrivedSubtitle,
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
                  child: Text(
                    l10n.boardedCompleteButton,
                    style: const TextStyle(fontWeight: FontWeight.w800),
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
                    isRefreshing ? l10n.checkingNow : l10n.stillWaiting,
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
