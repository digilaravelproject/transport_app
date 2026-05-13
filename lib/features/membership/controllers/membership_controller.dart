import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_text_constants.dart';
import '../../../core/constants/app_text_constants.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/services/network/api_client.dart';
import '../domain/models/plan_model.dart';
import '../domain/repositories/membership_repository.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';

import '../../../core/services/payment/razorpay_service.dart';
import '../domain/models/subscription_model.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../features/profile/controllers/profile_controller.dart';
import '../views/payment_success_screen.dart';

class MembershipController extends GetxController {
  final MembershipRepository _membershipRepo = MembershipRepository(Get.find<ApiClient>());
  final RazorpayService _razorpayService = Get.put(RazorpayService());

  final RxInt selectedPlanIndex = 1.obs; // Professional by default
  final RxString currentPlan = 'Free'.obs;
  final RxBool isAutoRenew = false.obs;
  final RxInt trialDays = 7.obs;
  final RxBool isLoading = false.obs;
  final RxList<PlanModel> apiPlans = <PlanModel>[].obs;
  final RxList<Map<String, dynamic>> plans = <Map<String, dynamic>>[].obs;
  final Rx<ActiveSubscriptionModel?> activeSubscription = Rx<ActiveSubscriptionModel?>(null);
  final RxList<ActiveSubscriptionModel> subscriptionHistory = <ActiveSubscriptionModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
    fetchCurrentSubscription();
    fetchSubscriptionHistory();
    _setupRazorpayListeners();
  }

  Future<void> fetchCurrentSubscription() async {
    final response = await _membershipRepo.getCurrentSubscription();
    if (response.isSuccess && response.json != null) {
      final subResponse = CurrentSubscriptionResponseModel.fromJson(response.json!);
      activeSubscription.value = subResponse.data;
      if (subResponse.data != null) {
        currentPlan.value = subResponse.data!.plan['name'] ?? AppTextConstants.free.tr;
      }
    }
  }

  Future<void> fetchSubscriptionHistory() async {
    final response = await _membershipRepo.getSubscriptionHistory();
    if (response.isSuccess && response.json != null) {
      final historyResponse = SubscriptionHistoryResponseModel.fromJson(response.json!);
      subscriptionHistory.assignAll(historyResponse.data);
    }
  }

  void showHistory() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(AppTextConstants.billingHistory.tr, fontSize: 20, fontWeight: FontWeight.w800),
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            if (subscriptionHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: AppText(AppTextConstants.noHistoryFound.tr, color: AppColors.textColorSecondary),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: subscriptionHistory.length,
                  itemBuilder: (context, index) {
                    final item = subscriptionHistory[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: AppText(item.plan['name'] ?? AppTextConstants.subscription.tr, fontWeight: FontWeight.w700),
                      subtitle: AppText('${item.startDate?.split('T')[0] ?? ''} - ₹${item.totalAmount}', fontSize: 12),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (item.status == 'active' || item.status == 'completed' || item.paymentStatus == 'completed') 
                              ? Colors.green.withOpacity(0.1) 
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          item.status.toUpperCase(),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: (item.status == 'active' || item.status == 'completed' || item.paymentStatus == 'completed') 
                              ? Colors.green 
                              : Colors.orange,
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  int get remainingDays {
    if (activeSubscription.value?.endDate == null) return 0;
    try {
      final expiryDate = DateTime.parse(activeSubscription.value!.endDate!);
      final difference = expiryDate.difference(DateTime.now()).inDays;
      return difference > 0 ? difference : 0;
    } catch (e) {
      return 0;
    }
  }

  void showUpgradePlans() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppText(AppTextConstants.upgradePlan.tr, fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppText(AppTextConstants.upgradePlanSubtitle.tr, color: AppColors.textColorSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: Obx(() {
                if (plans.isEmpty) return const Center(child: CircularProgressIndicator());
                return PageView.builder(
                  itemCount: plans.length,
                  controller: PageController(viewportFraction: 0.75, initialPage: selectedPlanIndex.value),
                  onPageChanged: (index) => selectPlan(index),
                  itemBuilder: (context, index) {
                    final plan = plans[index];
                    return Obx(() {
                      final isSelected = selectedPlanIndex.value == index;
                      return AnimatedScale(
                        scale: isSelected ? 1.0 : 0.9,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: isSelected ? AppColors.primaryColor : Colors.black.withOpacity(0.05), width: isSelected ? 2 : 1),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.black.withOpacity(0.02),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  AppText(plan['name'] ?? '', fontSize: 18, fontWeight: FontWeight.w800),
                                  if (isSelected) const Icon(Icons.check_circle, color: AppColors.primaryColor),
                                ],
                              ),
                              const SizedBox(height: 8),
                              AppText('₹${plan['price']}/${plan['duration']}', fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.primaryColor),
                              const SizedBox(height: 16),
                              Expanded(
                                child: Column(
                                  children: (plan['features'] as List? ?? []).take(3).map((f) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check, size: 14, color: Colors.green),
                                        const SizedBox(width: 8),
                                        Expanded(child: AppText(f.toString(), fontSize: 12, color: AppColors.textColorSecondary)),
                                      ],
                                    ),
                                  )).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AppButton(
                text: AppTextConstants.continueUpgrade.tr,
                onPressed: () {
                  Get.back();
                  continueWithPlan();
                },
                borderRadius: 16,
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }


  void _setupRazorpayListeners() {
    _razorpayService.onSuccess = (response) {
      _verifyPayment(response);
    };
    _razorpayService.onFailure = (response) {
      Get.snackbar(
        AppTextConstants.paymentFailed.tr,
        '${AppTextConstants.error.tr}: ${response.message}',
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    };
  }

  int? _pendingSubscriptionId;

  Future<void> _verifyPayment(PaymentSuccessResponse response) async {
    if (_pendingSubscriptionId == null) return;

    isLoading.value = true;
    final res = await _membershipRepo.verifyPayment(
      subscriptionId: _pendingSubscriptionId!,
      razorpayPaymentId: response.paymentId ?? '',
      razorpaySignature: response.signature ?? '',
    );

    if (res.isSuccess) {
      fetchCurrentSubscription();
      Get.to(() => const PaymentSuccessScreen());
    }
    isLoading.value = false;
    _pendingSubscriptionId = null;
  }

  Future<void> fetchPlans() async {
    isLoading.value = true;
    final response = await _membershipRepo.getPlans();
    if (response.isSuccess && response.json != null) {
      final planResponse = PlanResponseModel.fromJson(response.json!);
      if (planResponse.trailDays != null) {
        trialDays.value = planResponse.trailDays!;
      }
      apiPlans.assignAll(planResponse.data);

      if (planResponse.data.isNotEmpty) {
        plans.assignAll(planResponse.data.map((p) => {
          'original': p,
          'id': p.id,
          'name': p.name,
          'badge': p.sortOrder == 1 ? AppTextConstants.basic.tr : (p.sortOrder == 2 ? AppTextConstants.mostPopular.tr : AppTextConstants.premium.tr),
          'price': p.price == 0 ? AppTextConstants.free.tr : '₹${p.price}',
          'priceSub': p.price == 0 ? AppTextConstants.alwaysFree.tr : '/${p.duration}',
          'features': p.features,
          'color': const Color(0xFFF97316),
        }).toList());
        
        // Safety check for selected index
        if (selectedPlanIndex.value >= plans.length) {
          selectedPlanIndex.value = 0;
        }
      }
    }
    isLoading.value = false;
  }


  void selectPlan(int index) {
    selectedPlanIndex.value = index;
  }

  void showPlanDetails(Map<String, dynamic> planMap) {
    final p = planMap['original'] as PlanModel?;
    if (p == null) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AppText(
                    '${p.name} ${AppTextConstants.details.tr}',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _detailRow(AppTextConstants.description.tr, p.description),
            _detailRow(AppTextConstants.billingCycle.tr, p.duration),
            _detailRow(AppTextConstants.billingCycle.tr, '${p.billingCycleDays} ${AppTextConstants.day.tr}'),
            _detailRow(AppTextConstants.maxVehicles.tr, p.hasUnlimitedVehicles ? AppTextConstants.unlimited.tr : '${p.maxVehicles}'),
            _detailRow(AppTextConstants.maxTripsMonth.tr, p.hasUnlimitedTrips ? AppTextConstants.unlimited.tr : '${p.maxTripsPerMonth}'),
            _detailRow(AppTextConstants.maxStaff.tr, p.hasUnlimitedStaff ? AppTextConstants.unlimited.tr : '${p.maxStaff}'),
            _detailRow(AppTextConstants.moduleAccess.tr, p.moduleAccess),
            const SizedBox(height: 24),
            AppButton(
              text: AppTextConstants.gotIt.tr,
              onPressed: () => Get.back(),
              height: 48,
              borderRadius: 24,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: AppText(
              label,
              fontSize: 14,
              color: AppColors.textColorSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: AppText(
              value,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> continueWithPlan() async {
    if (apiPlans.isEmpty) return;
    
    final plan = apiPlans[selectedPlanIndex.value];
    final int planId = plan.id;

    isLoading.value = true;
    final response = await _membershipRepo.createSubscription(planId);
    isLoading.value = false;

    if (response.isSuccess && response.json != null) {
      final subResponse = SubscriptionResponseModel.fromJson(response.json!);
      _pendingSubscriptionId = subResponse.data.subscription.id;

      // Get user data from ProfileController
      String email = '';
      String contact = '';
      try {
        final profileController = Get.find<ProfileController>();
        email = profileController.profile.value?.email ?? '';
        contact = profileController.profile.value?.phone ?? '';
      } catch (e) {
        print('ProfileController not found: $e');
      }

      _razorpayService.openCheckout(
        key: subResponse.data.razorpayOrder.razorpayKey,
        amount: subResponse.data.razorpayOrder.amount,
        orderId: subResponse.data.razorpayOrder.id,
        name: AppConstants.appName,
        description: '${AppTextConstants.paymentFor.tr} ${plan.name}',
        email: email, 
        contact: contact,
        color: _colorToHex(AppColors.primaryColor),
      );
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void upgradePlan() {
    // Legacy support or internal use
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(onPressed: () => Get.back(), child: AppText(AppTextConstants.cancel.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(AppTextConstants.upgradeSuccess.tr, AppTextConstants.welcomeToEnterprise.tr, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.successColor, colorText: Colors.white);
              currentPlan.value = 'Enterprise';
            },
            child: AppText(AppTextConstants.payNow.tr),
          ),
        ],
      ),
    );
  }

  void cancelSubscription() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: AppText(AppTextConstants.cancelSubscription.tr),
        content: AppText(AppTextConstants.cancelSubscriptionNote.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: AppText(AppTextConstants.keepMyPlan.tr)),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(AppTextConstants.subscriptionCancelled.tr, AppTextConstants.planCancelledSuccessfully.tr, snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.errorColor, colorText: Colors.white);
            },
            child: AppText(AppTextConstants.cancelPlan.tr, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void toggleAutoRenew() {
    isAutoRenew.value = !isAutoRenew.value;
    Get.snackbar(AppTextConstants.settingsUpdated.tr, '${AppTextConstants.autoRenew.tr} ${AppTextConstants.isNow.tr} ${isAutoRenew.value ? AppTextConstants.enabled.tr : AppTextConstants.disabled.tr}', snackPosition: SnackPosition.BOTTOM);
  }
}
