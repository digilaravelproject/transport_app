import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/membership_controller.dart';

class MembershipScreen extends GetView<MembershipController> {
  const MembershipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MembershipController>()) {
      Get.put(MembershipController());
    }

    return AppScaffold(
      useScaffold: false,
      appBar: const AppHeader(
        title: 'Membership',
        subtitle: 'Manage your SaaS subscription',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Current Plan Card
            AppCard(
              padding: EdgeInsets.zero,
              color: AppColors.primaryColor,
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(Iconsax.medal_star, size: 120, color: AppColors.white.withOpacity(0.1)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Iconsax.verify, color: AppColors.white, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText('Current Plan', style: AppTextStyle.caption, color: Colors.white70),
                                Obx(() => AppText('${controller.currentPlan.value} Agency', style: AppTextStyle.heading, color: AppColors.white, fontSize: 22)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const AppText('Billing Cycle', style: AppTextStyle.caption, color: Colors.white70),
                                const AppText('Yearly', style: AppTextStyle.body, color: AppColors.white, fontWeight: FontWeight.bold),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const AppText('Renews In', style: AppTextStyle.caption, color: Colors.white70),
                                Obx(() => AppText('${controller.remainingDays.value} Days', style: AppTextStyle.body, color: AppColors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Plan Features
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText('Pro Features Included:', style: AppTextStyle.subheading, fontSize: 16),
                  const SizedBox(height: 16),
                  _FeatureRow(text: 'Unlimited Vehicles & Staff'),
                  const Divider(height: 24),
                  _FeatureRow(text: 'Advanced Live Tracking'),
                  const Divider(height: 24),
                  _FeatureRow(text: 'Custom Invoices & Duty Slips'),
                  const Divider(height: 24),
                  _FeatureRow(text: 'Priority Email & Call Support'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Auto Renew Toggle
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Row(
                     children: [
                       const Icon(Iconsax.refresh, color: AppColors.primaryColor, size: 20),
                       const SizedBox(width: 12),
                       const AppText('Auto-Renew Plan', style: AppTextStyle.body),
                     ],
                   ),
                   Obx(() => Switch(
                     value: controller.isAutoRenew.value,
                     onChanged: (_) => controller.toggleAutoRenew(),
                     activeColor: AppColors.primaryColor,
                   )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Upgrade Section
            AppCard(
              padding: const EdgeInsets.all(20),
              color: AppColors.warningColor.withOpacity(0.1),
              child: Column(
                children: [
                  const Icon(Iconsax.crown, size: 48, color: AppColors.warningColor),
                  const SizedBox(height: 12),
                  const AppText('Need more power?', style: AppTextStyle.subheading, fontSize: 18),
                  const SizedBox(height: 6),
                  const AppText(
                    'Upgrade to the Enterprise plan for custom API integrations, white-labeling, and dedicated account managers.',
                    style: AppTextStyle.body,
                    color: AppColors.textColorSecondary,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    text: 'Upgrade to Enterprise',
                    color: AppColors.warningColor,
                    textColor: AppColors.white,
                    onPressed: controller.upgradePlan,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Danger Zone
            AppButton.outline(
              text: 'Cancel Subscription',
              color: AppColors.errorColor,
              onPressed: controller.cancelSubscription,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.successColor, size: 20),
        const SizedBox(width: 12),
        Expanded(child: AppText(text, style: AppTextStyle.body)),
      ],
    );
  }
}
