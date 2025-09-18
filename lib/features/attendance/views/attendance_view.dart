import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/core/location_helper.dart';
import 'package:smis_attendance_tracker/core/responsive.dart';
import 'package:smis_attendance_tracker/routes/app_routes.dart';

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SizeConfig.width(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig.height(40)),
              Text(
                "Mark your attendance",
                style: TextStyle(
                  fontSize: SizeConfig.textSize(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: SizeConfig.height(10)),
              Text(
                "Please make sure you are in the right geo-location.\nOtherwise, you will be flagged as work from home.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeConfig.textSize(14),
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: SizeConfig.height(40)),
              Image.asset(
                "assets/mark_attendance.png",
                height: SizeConfig.height(200),
              ),
              SizedBox(height: SizeConfig.height(30)),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    try {
                      final pos = await LocationHelper.getCurrentLocation();
                      Get.snackbar(
                        "Location",
                        "Lat: ${pos?.latitude}, Lng: ${pos?.longitude}",
                      );
                    } catch (e) {
                      Get.snackbar(
                        "Error",
                        e.toString(),
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: const Text("Track Location"),
                ),
              ),
              SizedBox(height: SizeConfig.height(15)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAllNamed(AppRoutes.home);
                  },
                  child: const Text("Mark Attendance"),
                ),
              ),
              SizedBox(height: SizeConfig.height(20)),
              TextButton(
                onPressed: () => Get.offAllNamed(AppRoutes.home),
                child: const Text("Skip to Homepage"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
