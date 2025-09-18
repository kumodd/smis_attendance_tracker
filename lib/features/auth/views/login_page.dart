import 'package:flutter/material.dart';
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SizeConfig.width(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.height(80)),

              /// 🔹 App Logo & Name
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/login.png",
                      fit: BoxFit.fill,
                      height: SizeConfig.height(220),
                    ),
                    SizedBox(height: SizeConfig.height(12)),
                    Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: SizeConfig.textSize(22),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
              SizedBox(height: SizeConfig.height(20)),

              /// 🔹 User ID Field
              TextFormField(
                controller: controller.userIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter your ADID",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "ADID is required" : null,
              ),
              SizedBox(height: SizeConfig.height(30)),

              /// 🔹 Continue Button (Reactive)
              Obx(() => SizedBox(
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
                  )),
            ],
          ),
        ),
      ),
    );
  }
}