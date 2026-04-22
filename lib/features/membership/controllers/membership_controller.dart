import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';

class MembershipController extends GetxController {
  final RxInt selectedPlanIndex = 1.obs; // Professional by default
  final RxString currentPlan = 'Free'.obs;
  final RxInt remainingDays = 0.obs;
  final RxBool isAutoRenew = false.obs;

  final List<Map<String, dynamic>> plans = [
    {
      'name': 'Starter',
      'badge': 'BASIC',
      'price': 'Free',
      'priceSub': 'Always Free',
      'features': [
        '2 Active Vehicles',
        '5 Daily Trips',
        'Basic Expense Tracking',
        'Email Support',
      ],
      'color': const Color(0xFFF97316),
    },
    {
      'name': 'Professional',
      'badge': 'MOST POPULAR',
      'price': '₹499',
      'priceSub': '/month',
      'features': [
        'Unlimited Vehicles',
        'Unlimited Trips',
        'Live Tracking',
        'P&L Reports',
        'Custom Quotations',
        'Priority Support',
      ],
      'color': const Color(0xFFF97316),
    },
    {
      'name': 'Enterprise',
      'badge': 'PREMIUM',
      'price': 'Custom',
      'priceSub': 'Billed Monthly',
      'features': [
        'Multi-branch Management',
        'White-labeling',
        'API Integrations',
        'Dedicated Manager',
        '24/7 Phone Support',
      ],
      'color': const Color(0xFFF97316),
    },
  ];
  
  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  void continueWithPlan() {
    final plan = plans[selectedPlanIndex.value];
    Get.snackbar(
      'Plan Selected',
      'You have chosen the ${plan['name']} plan.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: Colors.white,
    );
  }

  void upgradePlan() {
    // Legacy support or internal use
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
              Get.snackbar('Subscription Cancelled', 'Your plan successfully cancelled', snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.errorColor, colorText: Colors.white);
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
