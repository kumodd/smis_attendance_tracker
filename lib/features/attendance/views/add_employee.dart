import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/features/attendance/controllers/employee_controller.dart';


class AddEmployeeScreen extends StatelessWidget {
  AddEmployeeScreen({Key? key}) : super(key: key);

  final AddEmployeeController controller = Get.put(AddEmployeeController());

  @override
  Widget build(BuildContext context) {
    final screenWidth = Get.width;
    final screenHeight = Get.height;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Add Employee',
          style: TextStyle(
            color: Colors.white,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1B5E20),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: screenHeight * 0.08,
            color: const Color(0xFF1B5E20),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.03),
                    _buildInputField(
                        'Employee Name', controller.employeeNameController),
                    _buildInputField('Phone Number', controller.phoneController,
                        keyboardType: TextInputType.phone),
                    _buildInputField('PSID', controller.psidController,
                        suffixIcon: Icons.unfold_more),
                    _buildDropdownField('Designation', controller.selectedDesignation,
                        controller.designations),
                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
        child: ElevatedButton.icon(
          onPressed: controller.addEmployee,
          icon: const Icon(Icons.add),
          label: Text(
            'Add Employee',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, IconData? suffixIcon}) {
    final screenWidth = Get.width;
    final screenHeight = Get.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500)),
          SizedBox(height: screenHeight * 0.01),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              hintText: label,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
              suffixIcon:
                  suffixIcon != null ? Icon(suffixIcon, color: Colors.grey[600]) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, RxString rxValue, List<String> items) {
    final screenWidth = Get.width;
    final screenHeight = Get.height;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: screenWidth * 0.04,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500)),
          SizedBox(height: screenHeight * 0.01),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(15),
            ),
            child: Obx(
              () => DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: rxValue.value,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  onChanged: (val) {
                    if (val != null) rxValue.value = val;
                  },
                  items: items
                      .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}