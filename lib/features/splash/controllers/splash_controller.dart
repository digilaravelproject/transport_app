import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import '../../../core/services/storage/shared_prefs.dart';
import '../../../core/constants/app_constants.dart';
import '../../../routes/route_helper.dart';
import '../domain/services/splash_service.dart';

class SplashController extends GetxController with GetSingleTickerProviderStateMixin {
  final SplashService _splashService;

  SplashController(this._splashService) {
    print("SplashController: Constructor called");
  }

  final isLoading = true.obs;
  late AnimationController _animationController;
  late Animation<double> rotationAnimation;

  @override
  void onInit() {
    super.onInit();
    
    // Ambient glow rotation animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    rotationAnimation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(_animationController);

    initApp();
  }

  @override
  void onClose() {
    _animationController.dispose();
    super.onClose();
  }

  Future<void> initApp() async {
    print("SplashController: initApp started");
    try {
      isLoading.value = true;

      // Initialize splash service
      print("SplashController: checking splash service initialize");
      final isReady = await _splashService.initialize();
      print("SplashController: isReady = $isReady");

      if (isReady) {
        // Wait to show splash screen
        print("SplashController: waiting for 4 seconds...");
        await Future.delayed(const Duration(milliseconds: 4000));

        // Check if user is logged in
        final isLoggedIn = SharedPrefs.getBool(AppConstants.isLoggedIn) ?? false;
        
        print("SplashController: isLoggedIn = $isLoggedIn, navigating...");

        if (isLoggedIn) {
          Get.offAllNamed(RouteHelper.getDashboardRoute());
        } else {
          Get.offAllNamed(RouteHelper.getIntroRoute());
        }
      } else {
        print("SplashController: isReady is false, going to login");
        Get.offAllNamed(RouteHelper.getSignupRoute());
      }
    } catch (e) {
      print("SplashController: Error in initApp: $e");
      Get.offAllNamed(RouteHelper.getSignupRoute());
    } finally {
      isLoading.value = false;
      print("SplashController: initApp finished");
    }
  }
}
