import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/attendance_controller.dart';

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

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    final userId = args["userId"];
    AppLogger.i("userId: $userId");

    attendanceController.fetchUserAttendance(userId);

    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
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
                attendanceController.errorMessage.value,
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

                // Custom Header with arrows
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
                      final type = attendanceController.attendanceMap[key];

                      if (type != null) {
                        Color color;
                        switch (type) {
                          case AttendanceType.greenCenter:
                            color = const Color(0xFF73D28C);
                            break;
                          case AttendanceType.kanakTower:
                            color = Colors.blue;
                            break;
                          case AttendanceType.wfh:
                            color = Colors.orange;
                            break;
                          case AttendanceType.leave:
                            color = Colors.redAccent;
                            break;
                          case AttendanceType.currentDate:
                            color = Colors.black87;
                            break;
                        }

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

                // Legend
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
    return months[month];
  }
}
