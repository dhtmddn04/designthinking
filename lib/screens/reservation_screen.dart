import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';
import 'dart:async';

class ReservationScreen extends StatefulWidget {
  final int? userId;
  final bool needsWheelchair;

  const ReservationScreen({
    super.key,
    required this.userId,
    required this.needsWheelchair,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  String? selectedStop;

  final Map<String, String> myReservedTimesByStop = {};
  final Map<String, Set<String>> occupiedTimesByStop = {};

  bool get _isWeekend {
    final now = DateTime.now();

    return now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
    //return false;
  }

  Timer? _reservationTimer;

  String _stopDisplayName(String stop) {
    final l10n = AppLocalizations.of(context)!;

    switch (stop) {
      case '정문':
        return l10n.mainGateStation;
      case '외대':
        return l10n.oedaeStation;
      case '전정대':
        return l10n.jeonjeongdaeStation;
      default:
        return stop;
    }
  }

  @override
  void initState() {
    super.initState();

    _loadReservations();

    _reservationTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;

      setState(() {});
      _loadReservations();
    });
  }

  @override
  void dispose() {
    _reservationTimer?.cancel();
    super.dispose();
  }

  bool _isPastTime(String time) {
    //final realNow = DateTime.now();
    //final now = DateTime(realNow.year, realNow.month, realNow.day, 14, 0);
    final now = DateTime.now();

    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final reservationTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    return reservationTime.isBefore(now);
  }

  bool _hasMyReservationAtSameTime(String time) {
    return myReservedTimesByStop.values.contains(time);
  }

  Future<void> _loadReservations() async {
    try {
      final result = await ApiService.getAllReservations();

      if (!context.mounted) return;

      if (result['success'] == true) {
        final reservations = result['reservations'] as List<dynamic>;

        setState(() {
          myReservedTimesByStop.clear();
          occupiedTimesByStop.clear();

          for (final reservation in reservations) {
            final stopName = reservation['stop_name'];
            final reservedTime = reservation['reserved_time'];
            final reservationUserId = reservation['user_id'];

            if (stopName == null || reservedTime == null) continue;

            if (_isPastTime(reservedTime)) continue;

            occupiedTimesByStop.putIfAbsent(stopName, () => <String>{});
            occupiedTimesByStop[stopName]!.add(reservedTime);

            if (widget.userId != null && reservationUserId == widget.userId) {
              myReservedTimesByStop[stopName] = reservedTime;
            }
          }
        });
      }
    } catch (e) {
      //if (!context.mounted) return;

      //final l10n = AppLocalizations.of(context)!;

      //ScaffoldMessenger.of(
      //  context,
      //).showSnackBar(SnackBar(content: Text(l10n.reservationLoadFailed)));
    }
  }

  final List<String> stops = ['정문', '외대', '전정대'];

  final List<String> times = [
    '9:00',
    '10:30',
    '12:00',
    '13:30',
    '15:00',
    '16:30',
    '18:00',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 44, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.reservationTab,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              l10n.reservationSubtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 32),

            Text(
              l10n.departureStation,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: stops.map((stop) {
                final bool isSelected = selectedStop == stop;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          selectedStop = stop;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black,
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFFD1D5DC),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _stopDisplayName(stop),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 22),

            Expanded(
              child: selectedStop == null
                  ? Center(
                      child: Text(
                        l10n.pleaseSelectStop,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF99A1AF),
                        ),
                      ),
                    )
                  : _buildScheduleList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showInvalidTimeDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.reservationNotAvailableTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(l10n.invalidReservationTime),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  void _showAlreadyReservedDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.reservationNotAvailableTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(l10n.alreadyReservedTime),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  void _showAlreadyHasReservationDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.reservationNotAvailableTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(l10n.alreadyHasReservation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  void _showAlreadyHasSameTimeReservationDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.reservationNotAvailableTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(l10n.alreadyHasSameTimeReservation),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  void _showNotAllowedDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.reservationNotAvailableTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Text(l10n.notReservationTarget),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  void _showWeekendReservationDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.reservationNotAvailableTitle,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(l10n.weekendReservationUnavailable),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _reserveTime(String time) async {
    final l10n = AppLocalizations.of(context)!;

    if (widget.userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loginRequired)));
      return;
    }

    if (!widget.needsWheelchair) {
      _showNotAllowedDialog();
      return;
    }

    if (selectedStop == null) return;

    if (_isWeekend) {
      _showWeekendReservationDialog();
      return;
    }

    if (_hasMyReservationAtSameTime(time)) {
      _showAlreadyHasSameTimeReservationDialog();
      return;
    }

    try {
      final result = await ApiService.createReservation(
        userId: widget.userId!,
        stopName: selectedStop!,
        busNumber: '1112',
        reservedTime: time,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? l10n.reservationSuccess
                : l10n.reservationFailed,
          ),
        ),
      );

      if (result['success'] == true) {
        await _loadReservations();
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.serverConnectionFailed)));
    }
  }

  Future<void> _cancelReservation(String time) async {
    final l10n = AppLocalizations.of(context)!;

    if (widget.userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loginRequired)));
      return;
    }

    if (selectedStop == null) return;

    try {
      final result = await ApiService.cancelReservation(
        userId: widget.userId!,
        stopName: selectedStop!,
        reservedTime: time,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['success'] == true
                ? l10n.reservationCancelSuccess
                : l10n.reservationCancelFailed,
          ),
        ),
      );

      if (result['success'] == true) {
        await _loadReservations();
      }
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.serverConnectionFailed)));
    }
  }

  String _formatBoardingBusInfo(Map<String, dynamic> recommendation) {
    final l10n = AppLocalizations.of(context)!;

    final boardingTime = recommendation['boardingTime'];
    final expectedArrivalTime = recommendation['expectedArrivalTime'];
    final departureTime = recommendation['departureTime'];

    final time = boardingTime ?? expectedArrivalTime ?? departureTime;

    if (time != null) {
      return l10n.lowFloorBus9Scheduled(time.toString());
    }

    return l10n.lowFloorBus9;
  }

  Future<void> _showTicketBottomSheet(String time) async {
    final l10n = AppLocalizations.of(context)!;

    final stop = selectedStop ?? '정문';

    Map<String, dynamic> recommendation;

    try {
      final userId = widget.userId;

      if (userId == null) {
        recommendation = {
          'success': false,
          'available': false,
          'message': l10n.loginRequired,
        };
      } else {
        recommendation = await ApiService.getBoardingRecommendation(
          userId: userId,
          stationName: stop,
          reservedTime: time,
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      recommendation = {
        'success': false,
        'available': false,
        'message': l10n.busArrivalInfoLoadFailed,
      };
    }

    if (!context.mounted) return;

    final bool available = recommendation['available'] == true;

    final String busInfo = available
        ? _formatBoardingBusInfo(recommendation)
        : l10n.busArrivalInfoNotReady;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DC),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF60A5FA), Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.white,
                      size: 38,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      l10n.ticketTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.white24,
                    ),

                    const SizedBox(height: 20),

                    _ticketInfoBox(
                      label: l10n.stopLabel,
                      value: _stopDisplayName(stop),
                    ),
                    const SizedBox(height: 12),

                    _ticketInfoBox(
                      label: l10n.boardingBusLabel,
                      value: busInfo,
                      valueFontSize: 13,
                    ),

                    const SizedBox(height: 12),

                    _ticketInfoBox(label: l10n.classTimeLabel, value: time),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.white24,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      l10n.arriveFiveMinutesEarly,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showReservationDialog(String time) {
    final l10n = AppLocalizations.of(context)!;
    final stop = selectedStop ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l10n.reservationCompletedTitle,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            l10n.reservationCompletedMessage(_stopDisplayName(stop), time),
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                l10n.close,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cancelReservation(time);
              },
              child: Text(
                l10n.cancelReservation,
                style: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _ticketInfoBox({
    required String label,
    required String value,
    double valueFontSize = 16,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: valueFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.timeHeader,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            Expanded(
              child: Text(
                l10n.reservationHeader,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
            Expanded(
              child: Text(
                l10n.reservationHeader,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Divider(height: 1, thickness: 1.5, color: Color(0xFFD1D5DC)),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: times.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final time = times[index];
              final String? myReservedTime =
                  myReservedTimesByStop[selectedStop];

              final bool isMyReservation = myReservedTime == time;
              final bool hasMyReservationAtStop = myReservedTime != null;

              final bool hasMyReservationAtSameTime = myReservedTimesByStop
                  .entries
                  .any((entry) {
                    final stopName = entry.key;
                    final reservedTime = entry.value;

                    return stopName != selectedStop && reservedTime == time;
                  });

              final bool isOccupied =
                  occupiedTimesByStop[selectedStop]?.contains(time) ?? false;

              final bool isReservedByOther = isOccupied && !isMyReservation;

              final bool isPastTime = _isPastTime(time);

              final bool isDisabled =
                  _isWeekend ||
                  isPastTime ||
                  isReservedByOther ||
                  hasMyReservationAtSameTime ||
                  (hasMyReservationAtStop && !isMyReservation);

              return Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD1D5DC), width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        time,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: () {
                              if (selectedStop == null) return;

                              if (_isWeekend) {
                                _showWeekendReservationDialog();
                                return;
                              }

                              if (isPastTime) {
                                _showInvalidTimeDialog();
                                return;
                              }

                              if (isReservedByOther) {
                                _showAlreadyReservedDialog();
                                return;
                              }

                              if (hasMyReservationAtSameTime) {
                                _showAlreadyHasSameTimeReservationDialog();
                                return;
                              }

                              if (hasMyReservationAtStop && !isMyReservation) {
                                _showAlreadyHasReservationDialog();
                                return;
                              }

                              if (isMyReservation) {
                                _showReservationDialog(time);
                                return;
                              }

                              _reserveTime(time);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMyReservation
                                  ? const Color(0xFF00C950)
                                  : isDisabled
                                  ? const Color(0xFFE5E7EB)
                                  : const Color(0xFF2563EB),
                              foregroundColor: isMyReservation || !isDisabled
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                              disabledBackgroundColor: const Color(0xFFE5E7EB),
                              disabledForegroundColor: const Color(0xFF9CA3AF),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              isMyReservation
                                  ? l10n.reserved
                                  : isDisabled
                                  ? l10n.reservationUnavailable
                                  : l10n.makeReservation,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: isMyReservation && !isPastTime
                                ? () async {
                                    await _showTicketBottomSheet(time);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isMyReservation
                                  ? const Color(0xFFAD46FF)
                                  : const Color(0xFFE5E7EB),
                              foregroundColor: isMyReservation
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                              disabledBackgroundColor: const Color(0xFFE5E7EB),
                              disabledForegroundColor: const Color(0xFF9CA3AF),
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              l10n.ticket,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
