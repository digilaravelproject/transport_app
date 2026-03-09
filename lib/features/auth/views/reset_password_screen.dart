import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:credit_debit/core/theme/app_colors.dart';
import 'package:credit_debit/core/widgets/app_button.dart';
import 'package:credit_debit/core/widgets/app_input_field.dart';
import 'package:credit_debit/core/widgets/app_text.dart';
import 'package:credit_debit/routes/route_helper.dart';
import 'package:credit_debit/core/widgets/clean_auth_background.dart';
import 'package:credit_debit/core/widgets/app_logo.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> with TickerProviderStateMixin {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;

  late Animation<double> _iconFadeAnimation;
  late Animation<Offset> _iconSlideAnimation;

  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;

  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;

  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

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

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),
                      
                      // App Logo
                      FadeTransition(
                        opacity: _iconFadeAnimation,
                        child: SlideTransition(
                          position: _iconSlideAnimation,
                          child: const Hero(
                            tag: 'app_logo',
                            child: AppLogo(size: 100),
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
                            'Reset Password',
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
                              'Create a new password for your account.',
                              style: AppTextStyle.body,
                              color: AppColors.textColorSecondary.withValues(alpha: 0.8),
                              align: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
        
                      const SizedBox(height: 48),
        
                      // Form Card (Clean & Premium)
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
                                  AppInputField(
                                    controller: passwordController,
                                    label: 'New Password',
                                    hint: 'Enter new password',
                                    icon: Iconsax.lock,
                                    obscure: _obscurePassword,
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                      child: Icon(
                                        _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                                        color: AppColors.textColorHint,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  AppInputField(
                                    controller: confirmPasswordController,
                                    label: 'Confirm Password',
                                    hint: 'Confirm new password',
                                    icon: Iconsax.lock,
                                    obscure: _obscureConfirmPassword,
                                    suffixIcon: GestureDetector(
                                      onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                      child: Icon(
                                        _obscureConfirmPassword ? Iconsax.eye : Iconsax.eye_slash,
                                        color: AppColors.textColorHint,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  AppButton(
                                    text: 'Update Password',
                                    fontWeight: FontWeight.bold,
                                    onPressed: () {
                                      Get.snackbar(
                                        'Success',
                                        'Password updated successfully!',
                                        backgroundColor: AppColors.successColor,
                                        colorText: AppColors.white,
                                      );
                                      Get.offAllNamed(RouteHelper.getLoginRoute());
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
        
                      const SizedBox(height: 48),
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
}
