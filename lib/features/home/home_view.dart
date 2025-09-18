import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/home/dashboard_view.dart';
import '../attendance/views/attendance_view.dart';
import 'home_controller.dart';


class HomeView extends StatelessWidget {
   HomeView({super.key});

  final List<Widget> _pages = [
    DashboardScreen(),
    const AttendanceView(),
    const Center(child: Text("👤 Profile Page", style: TextStyle(fontSize: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Obx(() => Scaffold(
          body: _pages[controller.currentIndex.value],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: controller.currentIndex.value,
            onTap: controller.changeTab,
            selectedItemColor: Colors.teal,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today),
                label: "My Attendance",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ));
  }
}