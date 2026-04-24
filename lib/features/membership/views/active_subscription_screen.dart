import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/membership_controller.dart';
import 'membership_screen.dart';

class ActiveSubscriptionScreen extends GetView<MembershipController> {
  const ActiveSubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MembershipController>()) {
      Get.put(MembershipController());
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(
        title: 'Active Subscription',
        onBack: () => Get.back(),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.activeSubscription.value == null && controller.subscriptionHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.medal_star, size: 80, color: AppColors.primaryColor),
                const SizedBox(height: 24),
                const AppText('No Active Plan Found', fontSize: 20, fontWeight: FontWeight.w800),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: AppText(
                    'Get started with our premium features to grow your business faster.',
                    align: TextAlign.center,
                    color: AppColors.textColorSecondary,
                  ),
                ),
                const SizedBox(height: 40),
                AppButton(
                  text: 'PURCHASE PLAN',
                  width: 240,
                  borderRadius: 16,
                  onPressed: () => Get.to(() => const MembershipScreen()),
                ),
              ],
            ),
          );
        }

        final sub = controller.activeSubscription.value!;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Active Plan Card
              if (sub != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.85),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: AppText(
                                sub.status.toUpperCase(),
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Icon(Iconsax.medal_star, color: Colors.white, size: 20),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    sub.plan['name'] ?? 'Premium SaaS',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(height: 2),
                                  if (sub.endDate != null)
                                    AppText(
                                      'Valid until: ${sub.endDate!.split('T')[0]}',
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  AppText(
                                    '${controller.remainingDays}',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primaryColor,
                                  ),
                                  const AppText(
                                    'DAYS LEFT',
                                    fontSize: 6,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: AppText('Plan Features:', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        ... (sub.plan['features'] as List? ?? [])
                            .take(3)
                            .map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white, size: 14),
                                  const SizedBox(width: 8),
                                  Expanded(child: AppText(f.toString(), fontSize: 12, color: Colors.white.withOpacity(0.9))),
                                ],
                              ),
                            )).toList(),
                        
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'UPGRADE PLAN',
                          color: Colors.white,
                          textColor: AppColors.primaryColor,
                          height: 38,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          borderRadius: 10,
                          onPressed: () => Get.to(() => const MembershipScreen()),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Billing History
              if (controller.subscriptionHistory.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      const Icon(Iconsax.receipt_2, size: 20, color: AppColors.primaryColor),
                      const SizedBox(width: 12),
                      const AppText('Billing History', fontSize: 18, fontWeight: FontWeight.w800),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.subscriptionHistory.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: Colors.black.withOpacity(0.05)),
                      itemBuilder: (context, index) {
                        final item = controller.subscriptionHistory[index];
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Iconsax.card, color: AppColors.primaryColor, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(item.plan['name'] ?? 'Subscription', fontWeight: FontWeight.w700, fontSize: 14),
                                    const SizedBox(height: 4),
                                    AppText(item.startDate?.split('T')[0] ?? 'Date N/A', fontSize: 12, color: AppColors.textColorSecondary),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  AppText('₹${item.totalAmount}', fontWeight: FontWeight.w800, fontSize: 15),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (item.status == 'active' || item.status == 'completed') 
                                          ? Colors.green.withOpacity(0.1) 
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: AppText(
                                      item.status.toUpperCase(),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: (item.status == 'active' || item.status == 'completed') ? Colors.green : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }
}
