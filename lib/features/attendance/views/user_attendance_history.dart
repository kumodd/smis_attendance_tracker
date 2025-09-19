import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';
import 'package:table_calendar/table_calendar.dart';

import '../controllers/attendance_controller.dart';

class AttendanceCalendarScreen extends StatelessWidget {
  final AttendanceController attendanceController =
  Get.put(AttendanceController());
  final String userId;

  AttendanceCalendarScreen({super.key})
      : userId = (Get.arguments as Map<String, dynamic>)["userId"].toString();

  final Map<String, Color> officeColors = {
    "ITC GREEN CENTER": const Color(0xFF73D28C),
    "KANAK TOWER": Colors.blue,
    "WORK FROM HOME": Colors.orange,
    "ON LEAVE": Colors.redAccent,
  };

  final Map<String, String> officeLabels = {
    "ITC GREEN CENTER": "ITC Green Center",
    "KANAK TOWER": "Kanak Tower",
    "WORK FROM HOME": "Work From Home",
    "ON LEAVE": "On Leave",
  };
  @override
  Widget build(BuildContext context) {
    // fetch user attendance once when screen opens
    final args = Get.arguments as Map<String, dynamic>;
    final userId = args["userId"];
    AppLogger.i("userId: $userId");

    attendanceController.
    fetchUserAttendance(userId);

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

          // attendanceMap is expected as Map<DateTime, String>
          final Map<DateTime, String> records =
          attendanceController.attendanceMap.cast<DateTime, String>();

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
            child: Column(
              children: [
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
                TableCalendar(
                  focusedDay: DateTime.now(),
                  firstDay:
                  DateTime(DateTime.now().year, DateTime.now().month, 1),
                  lastDay: DateTime(
                      DateTime.now().year, DateTime.now().month + 1, 0),
                  calendarFormat: CalendarFormat.month,
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                    ),
                    todayTextStyle: TextStyle(color: Colors.black),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month'
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, date, _) {
                      final DateTime key =
                      DateTime(date.year, date.month, date.day);
                      final String? type = records[key];

                      if (type != null) {
                        final color = officeColors.entries
                            .firstWhere(
                              (element) =>
                          element.key.toUpperCase() ==
                              type.toUpperCase(),
                          orElse: () =>
                          const MapEntry("", Colors.transparent),
                        )
                            .value;

                        return Center(
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: officeLabels.entries.map((e) {
                      return Row(
                        children: [
                          Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: officeColors[e.key],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            e.value,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
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
}
