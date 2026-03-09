import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get.dart';
import 'package:credit_debit/core/theme/app_colors.dart';
import 'package:credit_debit/core/widgets/app_logo.dart';
import 'package:credit_debit/core/widgets/app_text.dart';
import 'package:credit_debit/routes/route_helper.dart';
import 'package:credit_debit/core/widgets/app_input_field.dart';
import 'package:credit_debit/core/widgets/app_button.dart';
import 'package:credit_debit/core/widgets/clean_auth_background.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;

  late AnimationController _animationController;

  // Staggered animations for different elements
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;

  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;

  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;

  late Animation<double> _cardFadeAnimation;
  late Animation<Offset> _cardSlideAnimation;

  late Animation<double> _signupFadeAnimation;
  late Animation<Offset> _signupSlideAnimation;

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

    _signupFadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );
    _signupSlideAnimation = Tween<Offset>(
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
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Logo
                  FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: SlideTransition(
                      position: _logoSlideAnimation,
                      child: const AppLogo(size: 100),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Title
                  FadeTransition(
                    opacity: _titleFadeAnimation,
                    child: SlideTransition(
                      position: _titleSlideAnimation,
                      child: const AppText(
                        'Welcome Back',
                        style: AppTextStyle.heading,
                        align: TextAlign.center,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  FadeTransition(
                    opacity: _subtitleFadeAnimation,
                    child: SlideTransition(
                      position: _subtitleSlideAnimation,
                      child: AppText(
                        'Sign in to manage your bus agency',
                        style: AppTextStyle.body,
                        align: TextAlign.center,
                        color: AppColors.textColorSecondary.withValues(alpha: 0.8),
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Form card (Clean & Premium)
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email / Phone
                                AppInputField(
                                  label: 'Email or Phone',
                                  controller: _authController.emailController,
                                  hint: 'Enter your email or phone',
                                  icon: Iconsax.user,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                const SizedBox(height: 24),

                                // Password
                                AppInputField(
                                  label: 'Password',
                                  controller: _authController.passwordController,
                                  hint: 'Enter your password',
                                  icon: Iconsax.lock,
                                  obscure: _obscure,
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(() => _obscure = !_obscure),
                                    child: Icon(
                                      _obscure ? Iconsax.eye : Iconsax.eye_slash,
                                      color: AppColors.textColorHint,
                                      size: 20,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () => Get.toNamed(RouteHelper.getForgotPasswordRoute()),
                                    child: const AppText(
                                      'Forgot Password?',
                                      style: AppTextStyle.body,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Login button
                                Obx(() => AppButton(
                                      text: 'Sign In',
                                      isLoading: _authController.isLoading.value,
                                      fontWeight: FontWeight.bold,
                                      onPressed: () => Get.offAllNamed(RouteHelper.getDashboardRoute()),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Sign up link
                  FadeTransition(
                    opacity: _signupFadeAnimation,
                    child: SlideTransition(
                      position: _signupSlideAnimation,
                      child: GestureDetector(
                        onTap: () => Get.toNamed(RouteHelper.getSignupRoute()),
                        child: Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account?  ",
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textColorSecondary.withValues(alpha: 0.7),
                              ),
                              children: const [
                                TextSpan(
                                  text: 'Sign Up',
                                  style: TextStyle(
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
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
