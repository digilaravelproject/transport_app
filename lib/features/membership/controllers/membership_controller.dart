import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class MembershipController extends GetxController {
  final RxString currentPlan = 'Pro'.obs;
  final RxInt remainingDays = 27.obs;
  final RxBool isAutoRenew = true.obs;
  
  void upgradePlan() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Upgrade Success', 'Welcome to Enterprise!', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.successColor, colorText: Colors.white);
              currentPlan.value = 'Enterprise';
            },
            child: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  void cancelSubscription() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel? You will lose Pro features at the end of your billing cycle.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Keep My Plan')),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Subscription Cancelled', 'Your plan will end in ${remainingDays.value} days', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.errorColor, colorText: Colors.white);
            },
            child: const Text('Cancel Plan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void toggleAutoRenew() {
    isAutoRenew.value = !isAutoRenew.value;
    Get.snackbar('Settings Updated', 'Auto-renew is now ${isAutoRenew.value ? 'enabled' : 'disabled'}', snackPosition: SnackPosition.BOTTOM);
  }
}
