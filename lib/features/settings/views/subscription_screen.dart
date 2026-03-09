import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: const AppHeader(
        title: 'Subscription Plan',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Current Plan Card
            AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     decoration: BoxDecoration(
                       color: AppColors.primaryColor.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: const AppText('CURRENT PLAN', style: AppTextStyle.caption, color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                   ),
                   const SizedBox(height: 16),
                   const AppText('Premium SaaS', style: AppTextStyle.heading, fontSize: 24),
                   const SizedBox(height: 8),
                   AppText('Valid until: 31 Dec 2024', style: AppTextStyle.body, color: AppColors.textColorSecondary),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Features
            const Align(
              alignment: Alignment.centerLeft,
              child: AppText('Plan Features included', style: AppTextStyle.subheading),
            ),
            const SizedBox(height: 16),
            const AppCard(
              child: Column(
                children: [
                  _FeatureRow('Unlimited Lead Management'),
                  SizedBox(height: 12),
                  _FeatureRow('Full Trip & Route Lifecycle'),
                  SizedBox(height: 12),
                  _FeatureRow('Vehicle Maintenance Tracking'),
                  SizedBox(height: 12),
                  _FeatureRow('Staff & Driver Payroll'),
                  SizedBox(height: 12),
                  _FeatureRow('Comprehensive Financial Reports'),
                  SizedBox(height: 12),
                  _FeatureRow('Multi-Agency Support'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            AppButton(
              text: 'Renew Subscription',
              onPressed: () {
                Get.snackbar('Renew Plan', 'Redirecting to payment gateway...', snackPosition: SnackPosition.BOTTOM);
              },
            ),
             const SizedBox(height: 16),
            AppButton.outline(
              text: 'View Billing History',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Iconsax.tick_circle, color: AppColors.successColor, size: 20),
        const SizedBox(width: 12),
        Expanded(child: AppText(text, style: AppTextStyle.body)),
      ],
    );
  }
}
