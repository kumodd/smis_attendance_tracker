import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/attendance_controller.dart';

// Model representing attendance detail for date
class AttendanceRecord {
  final DateTime captureDate;
  final String officeName;

  AttendanceRecord({required this.captureDate, required this.officeName});
}

class AttendanceCalendarScreen extends StatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  State<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  final AttendanceController attendanceController = Get.put(
    AttendanceController(),
  );

  late DateTime _focusedDay;
  DateTime? _selectedDay;

  /// Map for quick detail lookup by date
  Map<DateTime, AttendanceRecord> attendanceDetailsMap = {};

  @override
  void initState() {
    super.initState();
    final args = (Get.arguments is Map)
        ? Get.arguments as Map
        : <String, dynamic>{};
    final userId = args["userId"];
    if (userId != null && userId.isNotEmpty) {
      attendanceController.attendanceList.clear(); // Clear stale data
      attendanceController.fetchUserAttendance(userId).then((_) {
        _buildAttendanceDetailsMap();
      });
    }
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  void _buildAttendanceDetailsMap() {
    Map<DateTime, AttendanceRecord> details = {};

    for (var item in attendanceController.attendanceList) {
      final rawDate = item["captureDate"];
      final officeName = (item["officeName"] ?? "").toString();

      try {
        // Use DateTime.parse that reliably handles fractional seconds like .0
        final dateTime = DateTime.parse(rawDate);
        final key = DateTime(dateTime.year, dateTime.month, dateTime.day);
        details[key] = AttendanceRecord(
          captureDate: dateTime,
          officeName: officeName,
        );
        print(
          "Parsed attendance record for $key at ${dateTime.toIso8601String()}",
        );
      } catch (e) {
        print("Error parsing captureDate '$rawDate': $e");
      }
    }

    setState(() {
      attendanceDetailsMap = details;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance History"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
        child: Obx(() {
          if (attendanceController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (attendanceController.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                "No Data Available",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2),
              ],
            ),
            child: Column(
              children: [
                // Title
                Container(
                  alignment: Alignment.topLeft,
                  padding: const EdgeInsets.only(left: 16, top: 12),
                  child: Text(
                    "Attendance history",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),

                // Header with arrows
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month - 1,
                              1,
                            );
                          });
                        },
                      ),
                      Text(
                        "${_monthName(_focusedDay.month)}, ${_focusedDay.year}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(
                              _focusedDay.year,
                              _focusedDay.month + 1,
                              1,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Calendar widget
                TableCalendar(
                  focusedDay: _focusedDay,
                  firstDay: DateTime(_focusedDay.year, _focusedDay.month, 1),
                  lastDay: DateTime(_focusedDay.year, _focusedDay.month + 1, 0),
                  selectedDayPredicate: (day) =>
                      _selectedDay != null && isSameDay(_selectedDay, day),
                  calendarFormat: CalendarFormat.month,
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  headerVisible: false,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _openAttendanceModal(context, selectedDay);
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    todayTextStyle: TextStyle(color: Colors.black),
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      final key = DateTime(date.year, date.month, date.day);
                      final AttendanceType? type =
                          attendanceController.attendanceMap[key];

                      if (type != null) {
                        final color = _attendanceColor(type);
                        return Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: type == AttendanceType.currentDate
                                  ? color
                                  : color.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  color: type == AttendanceType.currentDate
                                      ? Colors.white
                                      : color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // Legend for colors
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _legendItem(Colors.black87, "Current date"),
                      _legendItem(const Color(0xFF73D28C), "ITC Green Center"),
                      _legendItem(Colors.orange, "Work From Home"),
                      _legendItem(Colors.blue, "Kanak Tower"),
                      _legendItem(Colors.redAccent, "On Leave"),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _openAttendanceModal(BuildContext context, DateTime day) async {
    final selectedDayOnly = DateTime(day.year, day.month, day.day);
    final AttendanceType? type =
        attendanceController.attendanceMap[selectedDayOnly];

    // Find all attendance records from the list matching the selected day
    final matchedRecords = <Map<String, String>>[];

    for (var item in attendanceController.attendanceList) {
      String? captureDateStr;
      String? officeName;
      try {
        captureDateStr = (item is Map)
            ? item['captureDate']?.toString()
            : (item as dynamic).captureDate?.toString();
        officeName = (item is Map)
            ? item['officeName']?.toString()
            : (item as dynamic).officeName?.toString();
      } catch (e) {
        // ignore parsing errors here
      }
      AppLogger.i("Parsing captureDate: $captureDateStr");

      if (captureDateStr != null) {
        DateTime? parsed;
        try {
          parsed = DateTime.parse(captureDateStr);
        } catch (e) {
          parsed = null;
        }
        if (parsed != null) {
          final key = DateTime(parsed.year, parsed.month, parsed.day);
          if (key == selectedDayOnly) {
            matchedRecords.add({
              'time': DateFormat.Hm().format(parsed),
              'office': officeName ?? _attendanceLabel(type),
            });
          }
        }
      }
    }

    // Fallback to attendanceDetailsMap for officeName if no matches found
    final AttendanceRecord? singleRecord =
        attendanceDetailsMap[selectedDayOnly];
    final officeLabel = matchedRecords.isNotEmpty
        ? matchedRecords[0]['office']!
        : (singleRecord?.officeName ?? _attendanceLabel(type));

    final color = _attendanceColor(type);

    final dateStr =
        "${_pad(day.day)} ${_monthName(day.month)} ${day.year}, ${_weekdayName(day.weekday)}";

    final timeStr = matchedRecords.isNotEmpty
        ? matchedRecords[0]['time']!
        : "—";

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      officeLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.event, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      matchedRecords.isNotEmpty &&
                              matchedRecords[0]['time'] != null
                          ? "Time: ${matchedRecords[0]['time']}"
                          : (type == null ? "No attendance time" : "Time: —"),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (type == null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.withOpacity(0.2)),
                    ),
                    child: const Text(
                      "No attendance recorded for this date.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }

  String _monthName(int month) {
    const months = [
      "",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    if (month < 1 || month > 12) return "—";
    return months[month];
  }

  String _weekdayName(int weekday) {
    const names = [
      "",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];
    if (weekday < 1 || weekday > 7) return "—";
    return names[weekday];
  }

  String _pad(int v) => v.toString().padLeft(2, '0');

  String _attendanceLabel(AttendanceType? type) {
    if (type == null) return "No attendance";
    switch (type) {
      case AttendanceType.greenCenter:
        return "ITC Green Center";
      case AttendanceType.kanakTower:
        return "Kanak Tower";
      case AttendanceType.wfh:
        return "Work From Home";
      case AttendanceType.leave:
        return "On Leave";
      case AttendanceType.currentDate:
        return "Current date";
    }
  }

  Color _attendanceColor(AttendanceType? type) {
    if (type == null) return Colors.grey;
    switch (type) {
      case AttendanceType.greenCenter:
        return const Color(0xFF73D28C);
      case AttendanceType.kanakTower:
        return Colors.blue;
      case AttendanceType.wfh:
        return Colors.orange;
      case AttendanceType.leave:
        return Colors.redAccent;
      case AttendanceType.currentDate:
        return Colors.black87;
    }
  }

  String _formatTime(DateTime dateTime) {
    final twoDigits = (int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(dateTime.hour)}:${twoDigits(dateTime.minute)}";
  }
}
