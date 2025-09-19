import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../attendance/controllers/attendance_controller.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final AttendanceController controller = Get.put(AttendanceController());

  @override
  void initState() {
    super.initState();
    // ✅ Call API when screen is pushed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.fetchAttendance,
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        if (controller.attendanceList.isEmpty) {
          return const Center(child: Text("No attendance records found"));
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAttendance,
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.attendanceList.length,
            itemBuilder: (context, index) {
              final item = controller.attendanceList[index];
              final officeName = item["officeName"] ?? "Unknown";
              final dateTime = item["captureDate"] ?? "";
              final date = dateTime.toString().split(" ")[0];
              final time = dateTime.toString().split(" ")[1].substring(0, 5);

              final isWorkFromHome =
              officeName.toLowerCase().contains("home");
              final icon = isWorkFromHome
                  ? Icons.home_rounded
                  : Icons.apartment_rounded;
              final iconColor = isWorkFromHome ? Colors.orange : Colors.blue;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(icon, color: iconColor),
                  ),
                  title: Text(
                    officeName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text("$date  $time"),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
