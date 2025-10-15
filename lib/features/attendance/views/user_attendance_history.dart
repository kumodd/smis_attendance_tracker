import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controllers/attendance_controller.dart';

class AttendanceCalendarScreen extends StatefulWidget {
  const AttendanceCalendarScreen({super.key});

  @override
  State<AttendanceCalendarScreen> createState() =>
      _AttendanceCalendarScreenState();
}

class _AttendanceCalendarScreenState extends State<AttendanceCalendarScreen> {
  final AttendanceController controller = Get.put(AttendanceController());

  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();

    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final userId = args["userId"];
    if (userId != null && userId.isNotEmpty) {
      controller.fetchUserAttendance(userId);
    }
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return Column(
            children: [
              // 🔽 Added Month-Year Header with Navigation Arrows
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_left),
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
                    DateFormat.yMMMM().format(_focusedDay),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
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
              const SizedBox(height: 8),

              // 🔼 End of added header
              TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime(_focusedDay.year, _focusedDay.month, 1),
                lastDay: DateTime(_focusedDay.year, _focusedDay.month + 1, 0),
                selectedDayPredicate: (day) =>
                    _selectedDay != null && isSameDay(_selectedDay, day),
                calendarFormat: CalendarFormat.month,
                headerVisible: false,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  _openAttendanceModal(selectedDay);
                },
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, date, _) {
                    final key = DateTime(date.year, date.month, date.day);
                    final type = controller.attendanceMap[key];
                    final today = DateTime.now();

                    if (type == null &&
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
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: type == null
                                  ? Colors.red
                                  : (type == AttendanceType.currentDate
                                        ? Colors.white
                                        : color),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _legendItem(const Color(0xFF73D28C), "ITC Green Center"),
                  _legendItem(Colors.orange, "Work From Home"),
                  _legendItem(Colors.blue, "Kanak Tower"),
                  _legendItem(Colors.redAccent, "Absent"),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  void _openAttendanceModal(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    final type = controller.attendanceMap[key];

    final matchedRecords = controller.attendanceList.where((item) {
      try {
        final date = DateTime.parse(item['captureDate']);
        return DateTime(date.year, date.month, date.day) == key;
      } catch (_) {
        return false;
      }
    }).toList();

    final officeLabel = matchedRecords.isNotEmpty
        ? matchedRecords[0]['officeName']
        : _attendanceLabel(type);

    final timeLabel = matchedRecords.isNotEmpty
        ? DateFormat.Hm().format(
            DateTime.parse(matchedRecords[0]['captureDate']),
          )
        : "—";

    final color = _attendanceColor(type);
    final dateStr =
        "${_pad(day.day)} ${_monthName(day.month)} ${day.year}, ${_weekdayName(day.weekday)}";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
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
                      fontWeight: FontWeight.bold,
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
                  Text(dateStr),
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
                  Text("Time: $timeLabel"),
                ],
              ),
            ],
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
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  String _attendanceLabel(AttendanceType? type) {
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
        return "Current Date";
      default:
        return "No attendance";
    }
  }

  Color _attendanceColor(AttendanceType? type) {
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
      default:
        return Colors.grey;
    }
  }

  String _monthName(int month) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month];
  }

  String _weekdayName(int weekday) {
    const names = ["", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return names[weekday];
  }

  String _pad(int v) => v.toString().padLeft(2, '0');
}
