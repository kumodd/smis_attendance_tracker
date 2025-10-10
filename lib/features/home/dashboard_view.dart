import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/attendance/controllers/employee_controller.dart';
import 'package:smis_attendance_tracker/features/home/home_view.dart';
import 'package:smis_attendance_tracker/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smis_attendance_tracker/features/home/home_controller.dart';
import 'package:smis_attendance_tracker/features/home/model/user_model.dart';
import 'package:smis_attendance_tracker/routes/app_routes.dart';

class DashboardScreen extends StatelessWidget {
  // Do not keep old instances around; create lazily and allow refresh to recreate
  final HomeController controller = Get.put(
    HomeController(),
    tag: 'home_dashboard',
  );
  final AddEmployeeController addEmployeeController = Get.put(
    AddEmployeeController(),
    tag: 'add_emp_dashboard',
  );

  DashboardScreen({Key? key}) : super(key: key);

  Future<void> _reinitControllersAndRefresh(BuildContext context) async {
    try {
      // Delay just enough for RefreshIndicator to finish
      await Future.delayed(const Duration(milliseconds: 500));

      // Skipped Deletion of Controllers

      // Re-launch the same screen (like reloading the page)
      Get.off(() => HomeView(), preventDuplicates: false);
    } catch (e, st) {
      AppLogger.e('Error during screen reinitialization', e, st);
      EasyLoading.showError("Refresh failed. Try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF1B5E20),
          onRefresh: () => _reinitControllersAndRefresh(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCards(size),
                SizedBox(height: size.height * 0.025),
                _buildSearchFilter(size, context),
                SizedBox(height: size.height * 0.03),
                _buildDirectReports(size, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Status cards
  Widget _buildStatusCards(Size size) {
    final cardColors = [
      const Color(0xFF388E3C),
      const Color(0xFF1976D2),
      const Color(0xFFF57C00),
      const Color(0xFFD32F2F),
    ];
    final bgColors = [
      const Color(0xFFE8F5E9),
      const Color(0xFFE3F2FD),
      const Color(0xFFFFF3E0),
      const Color(0xFFFFEBEE),
    ];
    final icons = [
      Icons.business,
      Icons.business,
      Icons.home,
      Icons.cases_rounded,
    ];
    final labels = ['Green Center', 'Kanak Tower', 'Work From Home', 'Absent'];

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
                  offset: const Offset(0, 4),
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
                const Spacer(),
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
                      padding: const EdgeInsets.all(8),
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

  /// Search + Filter
  Widget _buildSearchFilter(Size size, BuildContext context) {
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
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Obx(
              () => TextField(
                onChanged: (value) => controller.searchText.value = value,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  suffixIcon: controller.searchText.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey[600]),
                          onPressed: () => controller.searchText.value = "",
                        )
                      : null,
                  hintText: 'Search employee',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  contentPadding: const EdgeInsets.only(top: 14),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: size.width * 0.03),
        GestureDetector(
          onTap: () => _showRoleFilterBottomSheet(context),
          child: Container(
            height: size.height * 0.06,
            width: size.height * 0.06,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.filter_list_rounded, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  /// Multi-selection role bottom sheet
  void _showRoleFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Select Roles",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Obx(
                () => Column(
                  children: controller.roles.map((role) {
                    final isSelected = controller.selectedRoles.contains(role);
                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isSelected,
                      title: Text(role),
                      onChanged: (_) {
                        controller.toggleRoleSelection(role);
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    controller.filterReportsByRole();
                    Navigator.pop(context);
                  },
                  child: const Text("Apply Filter"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Direct reports
  Widget _buildDirectReports(Size size, BuildContext context) {
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
        Obx(() {
          final reports = controller.filteredReports;
          if (reports.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "No employees found",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildDirectReportCard(report, size.width, context);
            },
          );
        }),
      ],
    );
  }

  Widget _buildDirectReportCard(
    UserModel report,
    double width,
    BuildContext context,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.blue),
                  onPressed: () {
                    Get.toNamed(
                      AppRoutes.userAttendance,
                      arguments: {
                        "userId": report.userId,
                        "designationText":
                            '${report.role} • ${report.designation}',
                      },
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: Colors.green),
                  onPressed: () async {
                    final phone = report.mobileNo ?? "";
                    if (phone.isEmpty) {
                      Get.snackbar("Error", "Phone number is empty");
                      return;
                    }

                    final Uri url = Uri(scheme: 'tel', path: '+91$phone');

                    EasyLoading.show(status: 'Loading...');
                    try {
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        await launchUrl(url);
                      }
                    } catch (e) {
                      Get.snackbar("Error", "Something went wrong: $e");
                    } finally {
                      EasyLoading.dismiss();
                    }
                  },
                ),
              ],
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
                  const SizedBox(height: 4),
                  Text(
                    '${report.role} • ${report.designation}',
                    style: TextStyle(
                      fontSize: width * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
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
            Center(
              child: InkWell(
                onTap: () => _showEditProfileBottomSheet(report, context),
                child: Icon(Icons.edit_rounded, color: Colors.grey[500]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileBottomSheet(UserModel report, BuildContext context) {
    final TextEditingController nameController = TextEditingController(
      text: report.userName,
    );
    final TextEditingController phoneController = TextEditingController(
      text: report.mobileNo ?? "",
    );

    final addEmployeeController = Get.find<AddEmployeeController>(
      tag: 'add_emp_dashboard',
    );

    // Preselect current designation
    addEmployeeController.selectedDesignation.value = report.designation;
    addEmployeeController.isSuccessUpdateEMployee.value = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Obx(() {
          // If update successful, close sheet and refresh list
          if (addEmployeeController.isSuccessUpdateEMployee.value) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              addEmployeeController.isSuccessUpdateEMployee.value = false;
              controller.fetchDirectReports();
              if (Navigator.canPop(context)) Navigator.pop(context);
            });
          }

          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Edit Profile",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // PSID (read-only)
                      TextField(
                        enabled: false,
                        decoration: InputDecoration(
                          hintText: report.userId.toString(),
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Designation Dropdown
                      Obx(() {
                        // Fallback logic: if the current designation isn't in the list, add it temporarily
                        final List<String> availableDesignations =
                            List<String>.from(
                              addEmployeeController.designations,
                            );

                        if (report.designation.isNotEmpty &&
                            !availableDesignations.contains(
                              report.designation,
                            )) {
                          availableDesignations.insert(0, report.designation);
                        }

                        return DropdownButtonFormField<String>(
                          value:
                              addEmployeeController
                                  .selectedDesignation
                                  .value
                                  .isNotEmpty
                              ? addEmployeeController.selectedDesignation.value
                              : (availableDesignations.isNotEmpty
                                    ? availableDesignations.first
                                    : null),
                          items: availableDesignations
                              .map(
                                (designation) => DropdownMenuItem<String>(
                                  value: designation,
                                  child: Text(designation),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              addEmployeeController.selectedDesignation.value =
                                  value;
                            }
                          },
                          decoration: InputDecoration(
                            labelText: "Designation",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),

                      // Phone
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: InputDecoration(
                          labelText: "Phone Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            addEmployeeController.updateEmployee(
                              report.userId.toString(),
                              nameController.text,
                              addEmployeeController.selectedDesignation.value,
                              phoneController.text,
                            );
                          },
                          child: const Text("Save Changes"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loader overlay
              if (addEmployeeController.isLoading.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        });
      },
    );
  }
}
