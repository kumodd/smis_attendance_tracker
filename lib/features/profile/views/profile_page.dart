import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/home/home_controller.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final HomeController controller = Get.find<HomeController>();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.1, vertical: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          CircleAvatar(
            radius: size.width * 0.18,
            backgroundColor: Colors.teal.shade200,
            child: Icon(
              Icons.person,
              size: size.width * 0.18,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 30),

          // Name
          Obx(
            () => Text(
              controller.userName.value,
              style: TextStyle(
                fontSize: size.width * 0.07,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 10),

          // Role / Designation
          Obx(
            () => Text(
              controller.userDesignation.value,
              style: TextStyle(
                fontSize: size.width * 0.045,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
