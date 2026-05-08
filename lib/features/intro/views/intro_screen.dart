import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:credit_debit/core/theme/app_colors.dart';
import 'package:credit_debit/core/widgets/app_button.dart';
import 'package:credit_debit/core/widgets/app_text.dart';
import 'package:credit_debit/routes/route_helper.dart';
import '../controllers/intro_controller.dart';

class IntroScreen extends GetView<IntroController> {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.introData.length,
                  itemBuilder: (context, index) {
                    final data = controller.introData[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.asset(
                                data['image']!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              AppText(
                                data['title']!,
                                style: AppTextStyle.heading,
                                align: TextAlign.center,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                              const SizedBox(height: 16),
                              AppText(
                                data['description']!,
                                style: AppTextStyle.body,
                                align: TextAlign.center,
                                color: AppColors.textColorSecondary,
                                fontSize: 15,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
              
              // ── Bottom Section ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  children: [
                    // Dot Indicator
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.introData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 6,
                          width: controller.currentPage.value == index ? 24 : 6,
                          decoration: BoxDecoration(
                            color: controller.currentPage.value == index 
                                ? AppColors.primaryColor 
                                : AppColors.slate200,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    )),
                    
                    const SizedBox(height: 32),
                    
                    // Action Buttons
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        Opacity(
                          opacity: controller.currentPage.value == 0 ? 0 : 1,
                          child: IgnorePointer(
                            ignoring: controller.currentPage.value == 0,
                            child: IconButton(
                              onPressed: () => controller.backPage(),
                              icon: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child: Icon(Iconsax.arrow_left_1, size: 20, color: AppColors.textColorPrimary),
                              ),
                            ),
                          ),
                        ),
                        
                        // Next or Get Started Button
                        controller.currentPage.value == controller.introData.length - 1 
                          ? Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 40),
                                child: AppButton(
                                  text: 'Get Started',
                                  onPressed: () => controller.getStarted(),
                                  height: 48,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : IconButton(
                              onPressed: () => controller.nextPage(),
                              icon: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Iconsax.arrow_right_3, size: 20, color: Colors.white),
                              ),
                            ),
                      ],
                    )),
                  ],
                ),
              ),
            ],
          ),
          
          // Fixed Skip Button
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () => controller.getStarted(),
              child: const AppText(
                'SKIP',
                style: AppTextStyle.body,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
