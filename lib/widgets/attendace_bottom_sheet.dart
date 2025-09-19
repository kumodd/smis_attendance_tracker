import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/attendance/controllers/attendance_controller.dart';

class AttendanceViewBottomSheet extends StatelessWidget {
  const AttendanceViewBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller = Get.put(AttendanceController());
    final Size size = MediaQuery.of(context).size;

    return Obx(() {
      return Stack(
        children: [
          AbsorbPointer(
            absorbing: controller.isLoading.value,
            child: SingleChildScrollView(
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

                  Text(
                    controller.status.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Mark Attendance Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.canMark.value && !controller.isLoading.value
                          ? () async {
                        await controller.markTodayAttendance();
                        Get.back();
                        Get.snackbar("Attendance", controller.status.value);
                      }
                          : null,
                      child: Text(
                        controller.isLoading.value ? "Please wait..." : "Mark Attendance",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Loader overlay
          if (controller.isLoading.value)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      );
    });
  }
}
