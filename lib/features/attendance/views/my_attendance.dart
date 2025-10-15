import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/attendance_controller.dart';

class MyAttendanceScreen extends StatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  final AttendanceController attendanceController = Get.put(
    AttendanceController(),
  );

  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();

    attendanceController.fetchAttendance();

    // Safe read of Get.arguments
    final args = Get.arguments;
    final userId = (args != null && args is Map<String, dynamic>)
        ? args['userId']?.toString()
        : null;

    if (userId != null && userId.isNotEmpty) {
      attendanceController.fetchUserAttendance(userId);
    }

    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  /// Returns a color based on the office/status text
  Color _getStatusColor(String office) {
    final lower = office.toLowerCase();

    if (lower.contains("green")) {
      return const Color(0xFF73D28C); // ITC Green Center
    } else if (lower.contains("kanak")) {
      return Colors.blue; // Kanak Tower
    } else if (lower.contains("wfh") || lower.contains("work from home")) {
      return Colors.orange; // Work From Home
    } else if (lower.contains("leave")) {
      return Colors.redAccent; // Leave
    } else if (lower.contains("holiday")) {
      return Colors.purple; // Holiday
    } else if (lower.contains("present")) {
      return Colors.green; // Present
    } else if (lower.contains("absent")) {
      return Colors.grey; // Absent
    }

    return Colors.grey; // Default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // Build a map DateTime -> officeName
          final attendanceMap = <DateTime, String>{};
          final originalItems = attendanceController.attendanceList;

          for (final item in originalItems) {
            String? captureDateStr;
            String? officeName;

            if (item == null) continue;

            if (item is Map) {
              captureDateStr = item['captureDate']?.toString();
              officeName = item['officeName']?.toString();
            } else {
              try {
                captureDateStr = (item as dynamic).captureDate?.toString();
              } catch (_) {}
              try {
                officeName = (item as dynamic).officeName?.toString();
              } catch (_) {}
            }

            final parsed = DateTime.tryParse(captureDateStr ?? '');
            if (parsed != null) {
              final key = DateTime(parsed.year, parsed.month, parsed.day);
              attendanceMap.putIfAbsent(key, () => officeName ?? '');
            }
          }

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2),
              ],
            ),
            child: SingleChildScrollView(
              // <-- Wrap Column here to enable scrolling
              child: Column(
                mainAxisSize: MainAxisSize.min, // <-- Shrink to content height
                children: [
                  // Month header with arrows
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

                  // Calendar
                  TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: DateTime(_focusedDay.year, _focusedDay.month, 1),
                    lastDay: DateTime(
                      _focusedDay.year,
                      _focusedDay.month + 1,
                      0,
                    ),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
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

                      _showAttendanceForDay(selectedDay);
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
                        final DateTime key = DateTime(
                          date.year,
                          date.month,
                          date.day,
                        );
                        final office = attendanceMap[key];
                        final today = DateTime.now();

                        if (office == null &&
                            date.isBefore(
                              DateTime(today.year, today.month, today.day + 1),
                            )) {
                          final color = Colors.redAccent;
                          return Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }

                        if (office != null && office.isNotEmpty) {
                          final color = _getStatusColor(office);

                          return Center(
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
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

                  // Legend
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _legendItem(
                          const Color(0xFF73D28C),
                          "ITC Green Center",
                        ),
                        _legendItem(Colors.orange, "Work From Home"),
                        _legendItem(Colors.blue, "Kanak Tower"),
                        _legendItem(Colors.redAccent, "Absent"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          );
        }),
      ),
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

  void _showAttendanceForDay(DateTime day) {
    final items = attendanceController.attendanceList;
    final selectedKey = DateTime(day.year, day.month, day.day);

    final matches = <Map<String, String>>[];

    for (final item in items) {
      String? captureDateStr;
      String? officeName;
      String? userId;

      if (item is Map) {
        captureDateStr = item['captureDate']?.toString();
        officeName = item['officeName']?.toString();
        userId = item['userId']?.toString();
      } else {
        try {
          captureDateStr = (item as dynamic).captureDate?.toString();
        } catch (_) {}
        try {
          officeName = (item as dynamic).officeName?.toString();
        } catch (_) {}
        try {
          userId = (item as dynamic).userId?.toString();
        } catch (_) {}
      }

      final parsed = DateTime.tryParse(captureDateStr ?? '');
      if (parsed != null) {
        final key = DateTime(parsed.year, parsed.month, parsed.day);
        if (key == selectedKey) {
          matches.add({
            'date': captureDateStr ?? '',
            'office': officeName ?? 'Unknown',
            'userId': userId ?? '',
            'time': DateFormat.Hm().format(parsed),
          });
        }
      }
    }

    showModalBottomSheet(
      context: context,

      backgroundColor: Colors.white,
      isScrollControlled: false,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        if (matches.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            height: 120,
            child: const Center(child: Text("No attendance for selected day.")),
          );
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with color dot, office name, and close icon
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(matches[0]['office'] ?? ''),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        matches[0]['office'] ?? 'Unknown Office',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Date row
                Row(
                  children: [
                    const Icon(Icons.event, size: 18, color: Colors.black54),
                    const SizedBox(width: 8),
                    Text(
                      "${_formatDate(day)}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Attendance time
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Attendance time: ${matches[0]['time'] ?? 'N/A'}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Optionally, display userId
                if (matches[0]['userId'] != null &&
                    matches[0]['userId']!.isNotEmpty) ...[
                  /* Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "User ID: ${matches[0]['userId']}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),*/
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const monthNames = [
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

    if (month < 1 || month > 12) return "Unknown";
    return monthNames[month - 1];
  }

  String _formatDate(DateTime date) {
    return DateFormat("dd MMM yyyy").format(date);
  }
}
