import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';

class SettingsController extends GetxController {

  final agencyName = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final gstNumber = ''.obs;
  final address = ''.obs;
// =======
//   final agencyName = 'DigiEmperor Logistics'.obs;
//   final email = 'info@digiemperor.com'.obs;
//   final phone = '+91 9876543210'.obs;
//   final gstNumber = '27AAAAA0000A1Z5'.obs;
//   final address = '123 Business Hub, Mumbai, India'.obs;
  final selectedCountryCode = '+91'.obs;

  void updateProfile(String name, String email, String phone, String gst, String address) {
    this.agencyName.value = name;
    this.email.value = email;
    this.phone.value = phone;
    this.gstNumber.value = gst;
    this.address.value = address;
    CustomSnackbar.showSuccess('Profile updated successfully');
  }

  void changePassword(String current, String newPass) {
    // Mock password change
    CustomSnackbar.showSuccess('Password changed successfully');
  }

  void showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.logout,
                  color: AppColors.errorColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              const AppText(
                'Logout',
                style: AppTextStyle.heading,
                fontSize: 20,
              ),
              const SizedBox(height: 12),
              
              // Message
              AppText(
                'Are you sure you want to logout?',
                style: AppTextStyle.body,
                textAlign: TextAlign.center,
                color: AppColors.textColorPrimary,
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.borderColor),
                      ),
                      child: AppText(
                        'Cancel',
                      //  style: AppTextStyle.button,
                        color: AppColors.textColorPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        logout(); // Perform logout
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.errorColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: AppText(
                        'Logout',
                       // style: AppTextStyle.button,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> logout() async {
    try {
      // Get AuthController and call its logout method
      final authController = Get.find<AuthController>();
      await authController.logout();
    } catch (e) {
      print('❌ Error in settings logout: $e');
      CustomSnackbar.showError('Failed to logout');
    }
  }
}
