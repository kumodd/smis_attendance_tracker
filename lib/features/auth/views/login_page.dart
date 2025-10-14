import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/core/constants.dart';
import 'package:smis_attendance_tracker/core/responsive.dart';
import 'package:smis_attendance_tracker/features/auth/controllers/auth_controller.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final controller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(SizeConfig.width(6)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: SizeConfig.height(20)),

                /// 🔹 App Logo & Name
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: SizeConfig.height(35),
                            height: SizeConfig.height(35),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFF0d4f48),
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                "assets/logo.png",
                                fit: BoxFit.cover,
                                width: SizeConfig.height(35),
                                height: SizeConfig.height(35),
                              ),
                            ),
                          ),
                          SizedBox(width: SizeConfig.width(12)),
                          Text(
                            "Attendance SMIS",
                            style: TextStyle(
                              fontSize: SizeConfig.textSize(18),
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00352F),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig.height(26)),
                      Image.asset(
                        "assets/login.png",
                        fit: BoxFit.fill,
                        height: SizeConfig.height(250),
                      ),
                      SizedBox(height: SizeConfig.height(12)),
                    ],
                  ),
                ),

                SizedBox(height: SizeConfig.height(100)),

                /// 🔹 Title
                Text(
                  "Login to your account",
                  style: TextStyle(
                    fontSize: SizeConfig.textSize(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: SizeConfig.height(25)),

                /// 🔹 User ID Field
                TextFormField(
                  controller: controller.userIdController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: 8,
                  decoration: const InputDecoration(
                    labelText: "Enter your ADID",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? "ADID is required"
                      : null,
                ),
                SizedBox(height: SizeConfig.height(30)),

                /// 🔹 Continue Button (Reactive)
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () => controller.sendOtp(),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.height(14),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text("Continue"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
