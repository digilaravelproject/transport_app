import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryColor,
                  size: 80,
                ),
              ),
              const SizedBox(height: 32),
              const AppText(
                'Payment Successful!',
                fontSize: 24,
                fontWeight: FontWeight.w800,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppText(
                'Your subscription has been activated successfully. Enjoy your premium features!',
                fontSize: 16,
                color: AppColors.textColorSecondary,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                text: 'BACK TO HOME',
                onPressed: () => Get.back(),
                borderRadius: 30,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
