import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:credit_debit/core/theme/app_colors.dart';
import 'dart:ui';
import 'package:credit_debit/routes/route_helper.dart';
import 'package:credit_debit/core/widgets/app_button.dart';
import 'package:credit_debit/core/widgets/app_text.dart';
import 'package:credit_debit/core/widgets/clean_auth_background.dart';
import '../controllers/auth_controller.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final authController = Get.find<AuthController>();
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  late AnimationController _animationController;
  
  // Staggered animations
  late Animation<double> _iconFadeAnimation;
  late Animation<Offset> _iconSlideAnimation;

  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;

  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;

  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  late Animation<double> _noteFadeAnimation;
  late Animation<Offset> _noteSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Staggered timing intervals
    _iconFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _iconSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    ));

    _titleFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
    );
    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.1, 0.5, curve: Curves.easeOutBack),
    ));

    _subtitleFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
    ));

    _cardFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );
    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
    ));

    _noteFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _noteSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: CleanAuthBackground(
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      
                      // Verification Shield Icon
                      FadeTransition(
                        opacity: _iconFadeAnimation,
                        child: SlideTransition(
                          position: _iconSlideAnimation,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primaryColor.withValues(alpha: 0.08),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black.withValues(alpha: 0.04),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Iconsax.shield_tick,
                                size: 56,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
            
                      const SizedBox(height: 40),
            
                      // Header
                      FadeTransition(
                        opacity: _titleFadeAnimation,
                        child: SlideTransition(
                          position: _titleSlideAnimation,
                          child: const AppText(
                            'OTP Verification',
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            align: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FadeTransition(
                        opacity: _subtitleFadeAnimation,
                        child: SlideTransition(
                          position: _subtitleSlideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: AppText(
                              'A 6-digit verification code has been sent to your registered mobile number.',
                              style: AppTextStyle.body,
                              color: AppColors.textColorSecondary.withValues(alpha: 0.8),
                              align: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
            
                      const SizedBox(height: 48),
            
                      // OTP Input Card (Clean & Premium)
                      FadeTransition(
                        opacity: _cardFadeAnimation,
                        child: SlideTransition(
                          position: _cardSlideAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: AppColors.primaryColor.withValues(alpha: 0.08),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.05),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                                BoxShadow(
                                  color: AppColors.primaryColor.withValues(alpha: 0.02),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(6, (index) => _otpBox(index)),
                                  ),
                                  const SizedBox(height: 40),
                                  AppButton(
                                    text: 'Verify OTP',
                                    fontWeight: FontWeight.bold,
                                    onPressed: () => Get.offAllNamed(RouteHelper.getLoginRoute()),
                                  ),
                                  const SizedBox(height: 24),
                                  GestureDetector(
                                    onTap: () {},
                                    child: RichText(
                                      text: const TextSpan(
                                        text: "Didn't receive code? ",
                                        style: TextStyle(color: AppColors.textColorSecondary, fontSize: 13),
                                        children: [
                                          TextSpan(
                                            text: 'Resend OTP',
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
            
                      const SizedBox(height: 48),
            
                      // Security Note
                      FadeTransition(
                        opacity: _noteFadeAnimation,
                        child: SlideTransition(
                          position: _noteSlideAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.primaryColor.withValues(alpha: 0.05),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withValues(alpha: 0.02),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Iconsax.info_circle, color: AppColors.primaryColor, size: 20),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: AppText(
                                    'Enter the 6-digit code sent to your mobile. Code expires in 10 minutes.',
                                    fontSize: 13,
                                    color: AppColors.textColorPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Back Button
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Iconsax.arrow_left,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus ? AppColors.primaryColor : AppColors.primaryColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
          decoration: const InputDecoration(counterText: '', border: InputBorder.none),
          onChanged: (value) {
            if (value.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }
}
