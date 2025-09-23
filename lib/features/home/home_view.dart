import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/attendance/views/my_attendance.dart';
import 'package:smis_attendance_tracker/features/home/dashboard_view.dart';
import 'package:smis_attendance_tracker/features/attendance/views/attendance_view.dart';
import 'package:smis_attendance_tracker/features/profile/views/profile_page.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';
import 'package:smis_attendance_tracker/widgets/attendace_bottom_sheet.dart';
import 'home_controller.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Obx(() {
      AppLogger.d("Current Index: ${controller.userRoleType.value}");
      // Determine if user is a normal user
      final isNormalUser = controller.userRoleType.value.toLowerCase().contains(
        "user",
      );

      // Build BottomNavigationBar items conditionally
      final bottomNavItems = isNormalUser
          ? [
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: "My Attendance",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ]
          : [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: "My Attendance",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ];

      return Scaffold(
        body: Column(
          children: [
            _buildTopSection(size, isNormalUser),
            SizedBox(height: 30),
            Expanded(child: _getPage(isNormalUser)),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: (index) {
            // Adjust index if normal user (shifted because home tab removed)
            if (isNormalUser) {
              controller.changeTab(
                index + 1,
              ); // My Attendance is index 1, Profile 2
            } else {
              controller.changeTab(index);
            }
          },
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          items: bottomNavItems,
        ),
      );
    });
  }

  Widget _getPage(bool isNormalUser) {
    if (isNormalUser) {
      switch (controller.currentIndex.value) {
        case 1:
          return MyAttendanceScreen();
        case 2:
          return const ProfileContent();
        default:
          return MyAttendanceScreen();
      }
    } else {
      switch (controller.currentIndex.value) {
        case 0:
          return DashboardScreen();
        case 1:
          return MyAttendanceScreen();
        case 2:
          return const ProfileContent();
        default:
          return DashboardScreen();
      }
    }
  }

  Widget _buildTopSection(Size size, bool isNormalUser) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.03,
            horizontal: size.width * 0.05,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF1B5E20),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: size.width * 0.06,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: const Color(0xFF1B5E20),
                      size: size.width * 0.08,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Get.dialog(
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Container(color: Colors.transparent),
                            ),
                            Positioned(
                              top: size.height * 0.08,
                              right: size.width * 0.05,
                              child: IntrinsicWidth(
                                child: Card(
                                  elevation: 5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!isNormalUser)
                                        InkWell(
                                          onTap: () {
                                            Get.toNamed("/add-employee");
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: const [
                                                SizedBox(
                                                  width: 24,
                                                  child: Icon(
                                                    Icons.person_add,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                                Text("Add Employee"),
                                              ],
                                            ),
                                          ),
                                        ),
                                      InkWell(
                                        onTap: () {
                                          Get.back();
                                          controller.logout();
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 12,
                                          ),
                                          child: Row(
                                            children: const [
                                              SizedBox(
                                                width: 24,
                                                child: Icon(
                                                  Icons.logout,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text("Logout"),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        barrierDismissible: true,
                      );
                    },
                    child: const Icon(Icons.more_vert, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.015),
              Obx(
                () => Text(
                  '${controller.greeting.value},',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: size.height * 0.005),
              Obx(
                () => Text(
                  controller.userName.value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size.width * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  controller.userRole.value,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
              SizedBox(height: size.height * 0.05),
            ],
          ),
        ),
        Positioned(
          bottom: -size.height * 0.03,
          left: size.width * 0.2,
          right: size.width * 0.2,
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.isAttendanceMarked.value
                  ? null
                  : () {
                      Get.bottomSheet(
                        const AttendanceViewBottomSheet(),
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFF1B5E20), width: 1),
                foregroundColor: const Color(0xFF1B5E20),
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                elevation: 0,
              ),
              child: Text(
                'Mark Attendance',
                style: TextStyle(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
