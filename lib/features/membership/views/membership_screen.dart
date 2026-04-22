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
      safeArea: true,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Center(
                child: AppText(
                  'Membership',
                  color: AppColors.primaryColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Logo/Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Iconsax.medal_star,
                          size: 36,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Titles
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: AppText(
                        'Start Your 7-Day Trial Today',
                        style: AppTextStyle.heading,
                        fontSize: 20,
                        align: TextAlign.center,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: AppText(
                        'Experience the magic of immersive growth with AI-powered social tools—free for 7 days.',
                        style: AppTextStyle.body,
                        fontSize: 13,
                        color: AppColors.textColorSecondary,
                        align: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Horizontal Plans
                    SizedBox(
                      height: 280,
                      child: PageView.builder(
                        itemCount: controller.plans.length,
                        controller: PageController(viewportFraction: 0.65, initialPage: 1),
                        onPageChanged: (index) => controller.selectPlan(index),
                        itemBuilder: (context, index) {
                          final plan = controller.plans[index];
                          return Obx(() {
                            final isSelected = controller.selectedPlanIndex.value == index;
                            return AnimatedScale(
                              scale: isSelected ? 1.0 : 0.9,
                              duration: const Duration(milliseconds: 300),
                              child: _PlanCard(
                                plan: plan,
                                isSelected: isSelected,
                              ),
                            );
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Continue Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Obx(() {
                        final planName = controller.plans[controller.selectedPlanIndex.value]['name'];
                        return AppButton(
                          text: 'CONTINUE WITH ${planName.toUpperCase()}',
                          color: AppColors.primaryColor,
                          height: 56,
                          borderRadius: 28,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          onPressed: () => controller.continueWithPlan(),
                        );
                      }),
                    ),

                    const SizedBox(height: 16),

                    const AppText(
                      'Cancel Anytime',
                      color: AppColors.textColorSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),

                    const SizedBox(height: 24),

                    // Footer Links
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FooterLink(text: 'Privacy Policy', onTap: () {}),
                        const SizedBox(width: 20),
                        _FooterLink(text: 'Terms of Service', onTap: () {}),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final bool isSelected;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.black.withOpacity(0.05),
          width: isSelected ? 3 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
        ],
      ),
      child: Column(
        children: [
          // Plan Badge
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.black.withOpacity(0.03),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: AppText(
              plan['badge'],
              align: TextAlign.center,
              color: isSelected ? Colors.white : AppColors.textColorSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  AppText(
                    plan['name'],
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  const SizedBox(height: 8),
                  
                  // Feature List
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: plan['features'].length,
                      itemBuilder: (context, fIndex) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppColors.primaryColor, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AppText(
                                  plan['features'][fIndex],
                                  fontSize: 11,
                                  color: AppColors.textColorSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          plan['price'],
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                        AppText(
                          plan['priceSub'],
                          fontSize: 11,
                          color: AppColors.textColorSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppText(
        text,
        fontSize: 12,
        color: AppColors.textColorHint,
        fontWeight: FontWeight.w500,
        style: AppTextStyle.caption,
      ),
    );
  }
}
