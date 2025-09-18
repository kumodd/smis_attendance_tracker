import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/home/home_controller.dart';
import 'package:smis_attendance_tracker/features/home/model/user_model.dart';

class DashboardScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: size.height * 0.02),
            _buildStatusCards(size),
            SizedBox(height: size.height * 0.02),
            _buildSearchFilter(size),
            SizedBox(height: size.height * 0.02),
            _buildDirectReports(size),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCards(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Obx(() {
        final statusCards = [
          {
            'count': controller.greenCenterCount.value.toString(),
            'label': 'Green Center',
            'icon': Icons.business,
          },
          {
            'count': controller.kanakTowerCount.value.toString(),
            'label': 'Kanak Tower',
            'icon': Icons.business,
          },
          {
            'count': controller.wfhCount.value.toString(),
            'label': 'Work From Home',
            'icon': Icons.home,
          },
          {
            'count': controller.leaveCount.value.toString(),
            'label': 'On Leave',
            'icon': Icons.cases_rounded,
          },
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth > 600 ? 4 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                crossAxisSpacing: size.width * 0.04,
                mainAxisSpacing: size.height * 0.01,
                childAspectRatio: 1.175,
              ),
              itemCount: statusCards.length,
              itemBuilder: (context, index) {
                final card = statusCards[index];
                return _buildStatusCard(
                  card['count'] as String,
                  card['label'] as String,
                  card['icon'] as IconData,
                  size.width,
                );
              },
            );
          },
        );
      }),
    );
  }

  Widget _buildSearchFilter(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  hintText: 'Search employee',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: size.height * 0.015,
                    horizontal: size.width * 0.05,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.02),
          Container(
            width: size.width * 0.12,
            height: size.width * 0.12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.filter_list_rounded, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectReports(Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Direct reports',
            style: TextStyle(
              fontSize: size.width * 0.05,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Obx(
            () => ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.directReports.length,
              itemBuilder: (context, index) {
                final report = controller.directReports[index];
                return _buildDirectReportCard(report, size.width);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    String count,
    String label,
    IconData icon,
    double width,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: width * 0.08,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1B5E20),
                    ),
                  ),
                ),
                Icon(icon, color: Colors.grey[400], size: width * 0.08),
              ],
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: width * 0.04,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectReportCard(UserModel report, double width) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600]),
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
                  SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      report.todayOffice.isEmpty
                          ? "Not Started work"
                          : report.todayOffice,
                      style: TextStyle(
                        color: const Color(0xFF1B5E20),
                        fontSize: width * 0.03,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
