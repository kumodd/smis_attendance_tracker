import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/home/home_controller.dart';
import 'package:smis_attendance_tracker/features/home/model/user_model.dart';
import 'package:smis_attendance_tracker/routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCards(size),
              SizedBox(height: size.height * 0.025),
              _buildSearchFilter(size),
              SizedBox(height: size.height * 0.03),
              _buildDirectReports(size),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCards(Size size) {
    final cardColors = [
      Color(0xFF388E3C),
      Color(0xFF1976D2),
      Color(0xFFF57C00),
      Color(0xFFD32F2F),
    ];
    final bgColors = [
      Color(0xFFE8F5E9),
      Color(0xFFE3F2FD),
      Color(0xFFFFF3E0),
      Color(0xFFFFEBEE),
    ];
    final icons = [
      Icons.business,
      Icons.business,
      Icons.home,
      Icons.cases_rounded,
    ];
    final labels = [
      'Green Center',
      'Kanak Tower',
      'Work From Home',
      'On Leave',
    ];

    return Obx(() {
      final counts = [
        controller.greenCenterCount.value.toString(),
        controller.kanakTowerCount.value.toString(),
        controller.wfhCount.value.toString(),
        controller.leaveCount.value.toString(),
      ];

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: size.width > 600 ? 4 : 2,
          crossAxisSpacing: size.width * 0.04,
          mainAxisSpacing: size.height * 0.02,
          childAspectRatio: 1.4,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  counts[index],
                  style: TextStyle(
                    fontSize: size.width * 0.08,
                    fontWeight: FontWeight.bold,
                    color: cardColors[index],
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: bgColors[index],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        icons[index],
                        color: cardColors[index],
                        size: size.width * 0.055,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildSearchFilter(Size size) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: size.height * 0.06,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                hintText: 'Search employee',
                hintStyle: TextStyle(color: Colors.grey[500]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
              ),
            ),
          ),
        ),
        SizedBox(width: size.width * 0.03),
        Container(
          height: size.height * 0.06,
          width: size.height * 0.06,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(Icons.filter_list_rounded, color: Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildDirectReports(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Direct Reports',
          style: TextStyle(
            fontSize: size.width * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: size.height * 0.015),
        // FIXED: Wrap only the list once in Obx
        Obx(() {
          final reports = controller.directReports;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return InkWell(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.userAttendance,
                    arguments: {"userId": report.userId},
                  );
                },
                child: _buildDirectReportCard(report, size.width),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildDirectReportCard(UserModel report, double width) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: width * 0.06,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                report.userName.isNotEmpty
                    ? report.userName[0].toUpperCase()
                    : "?",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: width * 0.04),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.userName,
                    style: TextStyle(
                      fontSize: width * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${report.role} • ${report.designation}',
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: report.todayOffice.isEmpty
                          ? Colors.grey.shade200
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.todayOffice.isEmpty
                          ? "Not Started Work"
                          : report.todayOffice,
                      style: TextStyle(
                        color: report.todayOffice.isEmpty
                            ? Colors.grey[600]
                            : Colors.green.shade700,
                        fontSize: width * 0.032,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}
