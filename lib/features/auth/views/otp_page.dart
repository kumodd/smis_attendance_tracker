import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smis_attendance_tracker/core/constants.dart';
import 'package:smis_attendance_tracker/core/responsive.dart';
import 'package:smis_attendance_tracker/features/auth/controllers/auth_controller.dart';

class OtpView extends StatelessWidget {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final controller = Get.find<LoginController>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(SizeConfig.width(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: SizeConfig.height(30)),

              /// 🔹 App Logo & Name
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/otp.png",
                      height: SizeConfig.height(120),
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

              SizedBox(height: SizeConfig.height(40)),

              /// 🔹 Title
              Text(
                "OTP Verification",
                style: TextStyle(
                  fontSize: SizeConfig.textSize(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: SizeConfig.height(8)),

              Text(
                AppConstants.otpMessage,
                style: TextStyle(fontSize: SizeConfig.textSize(14)),
              ),
              SizedBox(height: SizeConfig.height(20)),

              /// 🔹 OTP Field
              TextFormField(
                controller: controller.otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Enter OTP",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "OTP is required" : null,
              ),

              SizedBox(height: SizeConfig.height(20)),

              /// 🔹 Resend OTP
              Center(
                child: TextButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.sendOtp(); // reuse same API
                        },
                  child: const Text("Resend OTP"),
                ),
              ),

              SizedBox(height: SizeConfig.height(20)),

              /// 🔹 Verify Button (Reactive)
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.verifyOtp(),
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
                        : const Text("Verify OTP"),
                  ),
                ),
              ),

              SizedBox(height: SizeConfig.height(10)),

              /// 🔹 Back Button
              Center(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Icon(Icons.arrow_back),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
