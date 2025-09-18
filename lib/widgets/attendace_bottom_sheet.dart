import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/attendance/controllers/attendance_controller.dart';


class AttendanceViewBottomSheet extends StatelessWidget {
  const AttendanceViewBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller = Get.put(AttendanceController());
    final Size size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "Mark your attendance",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Please make sure you are in the right geo-location.\nOtherwise, you will be flagged as work from home.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
          Image.asset(
            "assets/mark_attendance.png",
            height: 200,
          ),
          const SizedBox(height: 20),

          Obx(() => Text(
                controller.status.value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              )),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => controller.trackLocation(),
              child: const Text("Track Location"),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Close bottom sheet
                Get.snackbar("Attendance", controller.status.value);
              },
              child: const Text("Mark Attendance"),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}