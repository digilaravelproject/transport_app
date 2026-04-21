import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:credit_debit/core/theme/app_colors.dart';
import 'package:credit_debit/routes/route_helper.dart';
import 'package:credit_debit/core/widgets/app_text.dart';
import 'package:credit_debit/core/widgets/app_input_field.dart';
import 'package:credit_debit/core/widgets/app_button.dart';
import 'package:credit_debit/core/widgets/clean_auth_background.dart';
import 'package:credit_debit/core/widgets/app_logo.dart';
import '../controllers/auth_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  
  // Staggered animations
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;

  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;

  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;

  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  late Animation<double> _footerFadeAnimation;
  late Animation<Offset> _footerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Staggered timing intervals
    _logoFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _logoSlideAnimation = Tween<Offset>(
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

    _footerFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _footerSlideAnimation = Tween<Offset>(
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
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      
                      // Header
                      Center(
                        child: Column(
                          children: [
                            FadeTransition(
                              opacity: _logoFadeAnimation,
                              child: SlideTransition(
                                position: _logoSlideAnimation,
                                child: const Hero(
                                  tag: 'app_logo',
                                  child: AppLogo(size: 80),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FadeTransition(
                              opacity: _titleFadeAnimation,
                              child: SlideTransition(
                                position: _titleSlideAnimation,
                                child: const AppText(
                                  'Vendor Registration',
                                  style: AppTextStyle.heading,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FadeTransition(
                              opacity: _subtitleFadeAnimation,
                              child: SlideTransition(
                                position: _subtitleSlideAnimation,
                                child: AppText(
                                  'Create your bus vendor account',
                                  style: AppTextStyle.body,
                                  color: AppColors.textColorSecondary.withValues(alpha: 0.8),
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
        
                      const SizedBox(height: 40),
        
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
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    // Agency Name
                                    AppInputField(
                                      label: 'Vendor Name',
                                      hint: 'Enter your bus vendor name',
                                      icon: Iconsax.building,
                                      controller: authController.companyNameController,
                                    ),
        
                                    const SizedBox(height: 20),
        
                                    // Owner Name
                                    AppInputField(
                                      label: 'Owner Name',
                                      hint: 'Enter owner full name',
                                      icon: Iconsax.user,
                                      controller: authController.nameController,
                                    ),
        
                                    const SizedBox(height: 20),
        
                                    // Mobile Number
                                    AppInputField(
                                      label: 'Mobile Number',
                                      hint: 'Enter 10 digit number',
                                      icon: Iconsax.call,
                                      keyboardType: TextInputType.phone,
                                      controller: authController.phoneController,
                                    ),
        
                                    const SizedBox(height: 20),
        
                                    // Email
                                    AppInputField(
                                      label: 'Email Address',
                                      hint: 'Enter your email',
                                      icon: Iconsax.sms,
                                      keyboardType: TextInputType.emailAddress,
                                      controller: authController.emailController,
                                    ),
        
                                    const SizedBox(height: 20),
        
                                    // Password
                                   /* AppInputField(
                                      label: 'Password',
                                      hint: 'Create password',
                                      icon: Iconsax.lock,
                                      obscure: _obscurePassword,
                                      controller: authController.passwordController,
                                      suffixIcon: GestureDetector(
                                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                        child: Icon(
                                          _obscurePassword ? Iconsax.eye : Iconsax.eye_slash,
                                          color: AppColors.textColorHint,
                                          size: 20,
                                        ),
                                      ),
                                    ),
        
                                    const SizedBox(height: 20),
        
                                    // Confirm Password
                                    AppInputField(
                                      label: 'Confirm Password',
                                      hint: 'Confirm password',
                                      icon: Iconsax.lock,
                                      obscure: _obscureConfirmPassword,
                                      controller: authController.confirmPasswordController,
                                      suffixIcon: GestureDetector(
                                        onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                        child: Icon(
                                          _obscureConfirmPassword ? Iconsax.eye : Iconsax.eye_slash,
                                          color: AppColors.textColorHint,
                                          size: 20,
                                        ),
                                      ),
                                    ),*/
        
                                    const SizedBox(height: 32),
        
                                    // Register Button
                                    Obx(() => AppButton(
                                      text: 'Register',
                                      isLoading: authController.isLoading.value,
                                      fontWeight: FontWeight.bold,
                                      onPressed: () => Get.toNamed(RouteHelper.getOtpRoute()),
                                    )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
        
                      const SizedBox(height: 32),
        
                      // Sign In Link
                      FadeTransition(
                        opacity: _footerFadeAnimation,
                        child: SlideTransition(
                          position: _footerSlideAnimation,
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: RichText(
                              text: TextSpan(
                                text: 'Already have an account? ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textColorSecondary.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w400,
                                ),
                                children: const [
                                  TextSpan(
                                    text: 'Sign In',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryColor,
                                    ),
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
