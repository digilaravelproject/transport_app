import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../domain/models/user_model.dart';
import '../../../routes/route_helper.dart';
import '../domain/services/auth_service.dart';

class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckLoginStatusUseCase _checkLoginStatusUseCase;
  final GetUserInfoUseCase _getUserInfoUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckLoginStatusUseCase checkLoginStatusUseCase,
    required GetUserInfoUseCase getUserInfoUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _logoutUseCase = logoutUseCase,
        _checkLoginStatusUseCase = checkLoginStatusUseCase,
        _getUserInfoUseCase = getUserInfoUseCase;

  final isLoading = false.obs;
  final currentMobile = ''.obs;
  Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final companyNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    companyNameController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }

  Future<void> checkLoginStatus() async {
    final isLoggedIn = await _checkLoginStatusUseCase.execute();
    if (isLoggedIn) {
      final user = await _getUserInfoUseCase.execute();
      if (user != null) currentUser.value = user;
    }
  }

  Future<void> signup() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final email = emailController.text.trim();
      currentMobile.value = email; // Store email for OTP verification
      // Note: Updating this to match transport management needs
      // For now, using what's available in the use case or updating the logic
      final user = await _registerUseCase.execute(
        companyNameController.text.trim(), // Using company name as name for now
        email, // Passing email to mobile spot or updating service
      );

      if (user != null) {
        currentUser.value = user;
        // currentMobile.value = emailController.text.trim(); // Optional: store email/mobile
        CustomSnackbar.showSuccess('Registration successful. Verify OTP.');
        Get.toNamed(RouteHelper.getOtpRoute());
      } else {
        CustomSnackbar.showError('Signup failed. Please try again.');
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final email = emailController.text.trim();
      currentMobile.value = email; // Store email for OTP verification
      final user = await _loginUseCase.execute(email);

      if (user != null) {
        currentUser.value = user;
        CustomSnackbar.showSuccess('Login successful. Verify OTP.');
        Get.toNamed(RouteHelper.getOtpRoute());
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    if (emailController.text.isEmpty) {
      CustomSnackbar.showError('Please enter your email');
      return;
    }

    try {
      isLoading.value = true;
      // Store email for reset password flow
      currentMobile.value = emailController.text.trim();
      // Implement forgot password logic - send reset link
      CustomSnackbar.showSuccess('Password reset link sent to your email');
      await Future.delayed(const Duration(milliseconds: 500));
      Get.toNamed(RouteHelper.getResetPasswordRoute());
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (passwordController.text.isEmpty) {
      CustomSnackbar.showError('Please enter new password');
      return;
    }
    if (confirmPasswordController.text.isEmpty) {
      CustomSnackbar.showError('Please confirm password');
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      CustomSnackbar.showError('Passwords do not match');
      return;
    }
    if (passwordController.text.length < 6) {
      CustomSnackbar.showError('Password must be at least 6 characters');
      return;
    }

    try {
      isLoading.value = true;
      // Implement reset password API call here
      CustomSnackbar.showSuccess('Password reset successfully');
      await Future.delayed(const Duration(milliseconds: 500));
      // Clear controllers
      passwordController.clear();
      confirmPasswordController.clear();
      emailController.clear();
      // Navigate back to login
      Get.offAllNamed(RouteHelper.getLoginRoute());
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty) {
      CustomSnackbar.showError('Please enter OTP');
      return;
    }

    try {
      isLoading.value = true;
      final user = await _verifyOtpUseCase.execute(
        currentMobile.value,
        otpController.text.trim(),
      );

      if (user != null) {
        currentUser.value = user;
        otpController.clear();
        CustomSnackbar.showSuccess('OTP verified successfully');
        Get.offAllNamed(RouteHelper.getDashboardRoute());
      }
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await _logoutUseCase.execute();
      currentUser.value = null;
      Get.offAllNamed(RouteHelper.getLoginRoute());
    } catch (e) {
      CustomSnackbar.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateCompanyName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your company name';
    }
    return null;
  }
}


class LoginUseCase {
  final AuthService _authService;

  LoginUseCase(this._authService);

  Future<UserModel?> execute(String mobile) async {
    final response = await _authService.login(mobile);
    if (response.isSuccess && response.body != null) {
      return UserModel.fromJson(response.body);
    }
    return null;
  }
}


class VerifyOtpUseCase {
  final AuthService _authService;

  VerifyOtpUseCase(this._authService);

  Future<UserModel?> execute(String mobile, String otp) async {
    final response = await _authService.verifyOtp(mobile, otp);
    if (response.isSuccess && response.body != null) {
      return UserModel.fromJson(response.body);
    }
    return null;
  }
}



class LogoutUseCase {
  final AuthService _authService;

  LogoutUseCase(this._authService);

  Future<void> execute() async {
    await _authService.clearUserInfo();
  }
}


class CheckLoginStatusUseCase {
  final AuthService _authService;

  CheckLoginStatusUseCase(this._authService);

  Future<bool> execute() async {
    return await _authService.isLoggedIn();
  }
}



class GetUserInfoUseCase {
  final AuthService _authService;

  GetUserInfoUseCase(this._authService);

  Future<UserModel?> execute() async {
    return await _authService.getUserInfo();
  }
}

class RegisterUseCase {
  final AuthService _authService;

  RegisterUseCase(this._authService);

  Future<UserModel?> execute(String name, String mobile) async {
    final response = await _authService.signup(name, mobile);

    if (response.isSuccess && response.body != null) {
      try {
        return UserModel.fromJson(response.body);
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }

    return null;
  }
}



