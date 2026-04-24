import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'active_subscription_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_header.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/membership_controller.dart';

import '../../../core/widgets/loading_widget.dart';

class MembershipScreen extends GetView<MembershipController> {
  const MembershipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MembershipController>()) {
      Get.put(MembershipController());
    }

    return Stack(
      children: [
        AppScaffold(
          useScaffold: true,
          safeArea: true,
          appBar: AppHeader(
            title: 'Subscription Plan',
            onBack: () => Get.back(),
          ),
          body: Container(
            color: Colors.white,
            child: Obx(() {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Welcome / Trial Info
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Iconsax.medal_star, size: 36, color: AppColors.primaryColor),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const AppText('Choose Your Plan', fontSize: 22, fontWeight: FontWeight.w800, align: TextAlign.center),
                          const SizedBox(height: 8),
                          const AppText('Experience the magic of immersive growth with AI-powered social tools.', 
                            fontSize: 14, color: AppColors.textColorSecondary, align: TextAlign.center),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Plans Carousel
                    SizedBox(
                      height: 280,
                      child: controller.plans.isEmpty 
                        ? const Center(child: CircularProgressIndicator())
                        : PageView.builder(
                            itemCount: controller.plans.length,
                            controller: PageController(viewportFraction: 0.6, initialPage: controller.plans.length > 1 ? 1 : 0),
                            onPageChanged: (index) => controller.selectPlan(index),
                            itemBuilder: (context, index) {
                              final plan = controller.plans[index];
                              return Obx(() {
                                final isSelected = controller.selectedPlanIndex.value == index;
                                return AnimatedScale(
                                  scale: isSelected ? 1.0 : 0.9,
                                  duration: const Duration(milliseconds: 300),
                                  child: _PlanCard(plan: plan, isSelected: isSelected),
                                );
                              });
                            },
                          ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Obx(() {
                        if (controller.plans.isEmpty) return const SizedBox();
                        final planName = controller.plans[controller.selectedPlanIndex.value]['name'];
                        return AppButton(
                          text: 'CONTINUE WITH ${planName.toUpperCase()}',
                          fontSize: 12,
                          onPressed: () => controller.continueWithPlan(),
                          borderRadius: 24,
                        );
                      }),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }),
          ),
        ),
        Obx(() => controller.isLoading.value 
          ? const LoadingWidget(type: LoadingType.overlay) 
          : const SizedBox()),
      ],
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
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 24), // Balance the icon on the other side
                      Expanded(
                        child: AppText(
                          plan['name'],
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          align: TextAlign.center,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.find<MembershipController>().showPlanDetails(plan),
                        child: const Icon(Icons.info_outline, size: 20, color: AppColors.primaryColor),
                      ),
                    ],
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
