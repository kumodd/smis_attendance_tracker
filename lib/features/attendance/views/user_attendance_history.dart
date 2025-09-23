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
  late final AttendanceController attendanceController;

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  String? _userId;

  @override
  void initState() {
    super.initState();

    // Resolve or create controller once to avoid multiple puts across navigations
    if (Get.isRegistered<AttendanceController>()) {
      attendanceController = Get.find<AttendanceController>();
    } else {
      attendanceController = Get.put(AttendanceController());
    } // [web:5][web:16]

    final args = Get.arguments;
    _userId = (args != null && args is Map<String, dynamic>)
        ? args['userId']?.toString()
        : null; // [web:21][web:23]

    if (_userId != null && _userId!.isNotEmpty) {
      attendanceController.fetchUserAttendance(_userId!);
    }

    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  // Color mapping for AttendanceType
  Color _colorForType(AttendanceType type) {
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
        return Colors.purple;
    }
  }

  String _labelForType(AttendanceType type) {
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
        return "Today";
    }
  }

  // Robust parse for server captureDate "yyyy-MM-dd HH:mm:ss.S" (and fallbacks)
  DateTime? _parseServerDate(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final patterns = <String>[
      "yyyy-MM-dd HH:mm:ss.S",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd",
    ];
    for (final p in patterns) {
      try {
        return DateFormat(p).parse(raw, true).toLocal();
      } catch (_) {}
    }
    return DateTime.tryParse(raw)?.toLocal();
  } // [web:18]

  // Optional office string color (used in detail list if needed)
  Color _getStatusColorByOffice(String office) {
    final lower = office.toLowerCase();
    if (lower.contains("green")) return const Color(0xFF73D28C);
    if (lower.contains("kanak")) return Colors.blue;
    if (lower.contains("wfh") || lower.contains("work from home"))
      return Colors.orange;
    if (lower.contains("leave")) return Colors.redAccent;
    if (lower.contains("holiday")) return Colors.purple;
    if (lower.contains("present")) return Colors.green;
    if (lower.contains("absent")) return Colors.grey;
    return Colors.grey;
  } // [web:6][web:17]

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
                attendanceController.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // Use the controller-provided map: DateTime -> AttendanceType
          final map = attendanceController.attendanceMap;

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
                  lastDay: DateTime(_focusedDay.year, _focusedDay.month + 1, 0),
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
                      final key = DateTime(date.year, date.month, date.day);
                      final type = map[key];

                      final isToday = isSameDay(
                        key,
                        DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ),
                      );

                      if (type != null && type != AttendanceType.currentDate) {
                        final color = _colorForType(type);
                        return Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${date.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }

                      if (isToday) {
                        return Center(
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _colorForType(
                                  AttendanceType.currentDate,
                                ),
                                width: 2,
                              ),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }

                      return null;
                    },
                    markerBuilder: (context, date, events) {
                      final key = DateTime(date.year, date.month, date.day);
                      final isToday = isSameDay(
                        key,
                        DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ),
                      );
                      if (isToday) {
                        return Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _colorForType(AttendanceType.currentDate),
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ), // [web:4]

                const SizedBox(height: 10),

                // Legend
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _legendItem(
                        _colorForType(AttendanceType.greenCenter),
                        _labelForType(AttendanceType.greenCenter),
                      ),
                      _legendItem(
                        _colorForType(AttendanceType.wfh),
                        _labelForType(AttendanceType.wfh),
                      ),
                      _legendItem(
                        _colorForType(AttendanceType.kanakTower),
                        _labelForType(AttendanceType.kanakTower),
                      ),
                      _legendItem(
                        _colorForType(AttendanceType.leave),
                        _labelForType(AttendanceType.leave),
                      ),
                      _legendItem(
                        _colorForType(AttendanceType.currentDate),
                        _labelForType(AttendanceType.currentDate),
                      ),
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
    final rawList = attendanceController.attendanceList;
    final selectedKey = DateTime(day.year, day.month, day.day);

    final matches = <Map<String, String>>[];

    for (final item in rawList) {
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

      final parsed = _parseServerDate(captureDateStr);
      if (parsed != null) {
        final key = DateTime(parsed.year, parsed.month, parsed.day);
        if (key == selectedKey) {
          matches.add({
            'date': DateFormat("hh:mm a • dd MMM yyyy").format(parsed),
            'office': officeName ?? 'Unknown',
            'userId': userId ?? '',
          });
        }
      }
    } // [web:18]

    showModalBottomSheet(
      context: context,
      builder: (_) {
        if (matches.isEmpty) {
          // If it’s today but no records, still show minimal context
          final type = attendanceController.attendanceMap[selectedKey];
          final isTodayOnly = type == AttendanceType.currentDate;
          if (isTodayOnly) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 140,
              child: const Center(
                child: Text("No attendance record yet.\nMarked as Today."),
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(16),
            height: 120,
            child: const Center(child: Text("No attendance for selected day.")),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: matches.map((m) {
              final office = m['office'] ?? '';
              final color = _getStatusColorByOffice(office);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.event_available),
                ),
                title: Text(office),
                subtitle: Text(m['date'] ?? ''),
                trailing: (m['userId'] != null && m['userId']!.isNotEmpty)
                    ? Text(m['userId']!)
                    : null,
              );
            }).toList(),
          ),
        );
      },
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
    return months[month];
  }
}
