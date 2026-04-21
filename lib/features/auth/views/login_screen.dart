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
    final size = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Gradient Background with animated circles
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryColor.withValues(alpha: 0.1),
                  AppColors.white,
                  AppColors.primaryColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated Circle 1 - Top Right
                Positioned(
                  top: -100,
                  right: -100,
                  child: FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.15),
                            AppColors.primaryColor.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Animated Circle 2 - Middle Left
                Positioned(
                  top: size.height * 0.3,
                  left: -80,
                  child: FadeTransition(
                    opacity: _titleFadeAnimation,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.12),
                            AppColors.primaryColor.withValues(alpha: 0.04),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Animated Circle 3 - Bottom Right
                Positioned(
                  bottom: -50,
                  right: -50,
                  child: FadeTransition(
                    opacity: _subtitleFadeAnimation,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryColor.withValues(alpha: 0.1),
                            AppColors.primaryColor.withValues(alpha: 0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Section - Logo and Title (shrinks when keyboard opens)
                Expanded(
                  flex: keyboardHeight > 0 ? 1 : 3,
                  child: keyboardHeight > 0
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo with pulse animation
                              FadeTransition(
                                opacity: _logoFadeAnimation,
                                child: SlideTransition(
                                  position: _logoSlideAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                                          blurRadius: 40,
                                          offset: const Offset(0, 15),
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    child: const AppLogo(size: 70),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Title
                              FadeTransition(
                                opacity: _titleFadeAnimation,
                                child: SlideTransition(
                                  position: _titleSlideAnimation,
                                  child: const AppText(
                                    'Welcome Back!',
                                    style: AppTextStyle.heading,
                                    align: TextAlign.center,
                                    fontSize: 38,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textColorPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Subtitle
                              FadeTransition(
                                opacity: _subtitleFadeAnimation,
                                child: SlideTransition(
                                  position: _subtitleSlideAnimation,
                                  child: AppText(
                                    'Sign in to continue your journey',
                                    style: AppTextStyle.body,
                                    align: TextAlign.center,
                                    color: AppColors.textColorSecondary.withValues(alpha: 0.7),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),

                // Bottom Sheet Style Form
                FadeTransition(
                  opacity: _cardFadeAnimation,
                  child: SlideTransition(
                    position: _cardSlideAnimation,
                    child: Container(
                      width: size.width,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 30,
                            offset: const Offset(0, -10),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(bottom: keyboardHeight),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 30, 28, 40),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Decorative handle
                                Center(
                                  child: Container(
                                    width: 50,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: AppColors.textColorHint.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Email field
                                AppInputField(
                                  label: 'Email Address',
                                  controller: _authController.emailController,
                                  hint: 'you@example.com',
                                  icon: Iconsax.sms,
                                  keyboardType: TextInputType.emailAddress,
                                ),

                                const SizedBox(height: 28),

                                // Sign in button
                                /*Obx(() => Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryColor,
                                            AppColors.primaryColor.withValues(alpha: 0.8),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryColor.withValues(alpha: 0.4),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: _authController.isLoading.value
                                              ? null
                                              : () {
                                                  if (_formKey.currentState?.validate() ?? false) {
                                                    _authController.login();
                                                  }
                                                },
                                          child: Center(
                                            child: _authController.isLoading.value
                                                ? const SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      color: AppColors.white,
                                                      strokeWidth: 2.5,
                                                    ),
                                                  )
                                                : AppText(
                                                    'Sign In',
                                                   // style: AppTextStyle.button,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.white,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    )),*/

                                Obx(() => AppButton(
                                  text: 'Sign In',
                                  isLoading: _authController.isLoading.value,
                                  fontWeight: FontWeight.bold,
                                  onPressed: () => Get.offAllNamed(RouteHelper.getDashboardRoute()),
                                )),

                                const SizedBox(height: 24),

                                // Divider with text
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.textColorHint.withValues(alpha: 0.3),
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: AppText(
                                        'OR',
                                        style: AppTextStyle.body,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textColorHint.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: AppColors.textColorHint.withValues(alpha: 0.3),
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Sign up link
                                FadeTransition(
                                  opacity: _signupFadeAnimation,
                                  child: SlideTransition(
                                    position: _signupSlideAnimation,
                                    child: GestureDetector(
                                      onTap: () => Get.toNamed(RouteHelper.getSignupRoute()),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        // decoration: BoxDecoration(
                                        //   color: AppColors.primaryColor.withValues(alpha: 0.08),
                                        //   borderRadius: BorderRadius.circular(16),
                                        //   border: Border.all(
                                        //     color: AppColors.primaryColor.withValues(alpha: 0.2),
                                        //     width: 1.5,
                                        //   ),
                                        // ),
                                        child: Center(
                                          child: RichText(
                                            text: TextSpan(
                                              text: "Don't have an account?  ",
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textColorSecondary.withValues(alpha: 0.8),
                                                fontFamily: 'Poppins',
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
