import 'package:get/get.dart';

class SettingsController extends GetxController {
  final agencyName = 'DigiEmperor Logistics'.obs;
  final email = 'info@digiemperor.com'.obs;
  final phone = '+91 9876543210'.obs;
  final gstNumber = '27AAAAA0000A1Z5'.obs;
  final address = '123 Business Hub, Mumbai, India'.obs;
  final selectedCountryCode = '+91'.obs;

  void updateProfile(String name, String email, String phone, String gst, String address) {
    this.agencyName.value = name;
    this.email.value = email;
    this.phone.value = phone;
    this.gstNumber.value = gst;
    this.address.value = address;
    Get.snackbar('Success', 'Profile updated successfully', snackPosition: SnackPosition.BOTTOM);
  }

  void changePassword(String current, String newPass) {
    // Mock password change
    Get.snackbar('Success', 'Password changed successfully', snackPosition: SnackPosition.BOTTOM);
  }

  void logout() {
    // Mock logout logic
    Get.offAllNamed('/login'); // Assuming login route exists
  }
}
