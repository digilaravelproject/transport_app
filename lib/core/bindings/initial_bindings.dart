import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/network/api_client.dart';
import '../services/network/network_info.dart';
import 'package:dio/dio.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/services/auth_service.dart';
import '../../features/splash/controllers/splash_controller.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/domain/services/splash_service.dart';
import '../../features/intro/controllers/intro_controller.dart';
import '../theme/theme_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Core services
    Get.lazyPut(() => Dio(), fenix: true);
    Get.lazyPut(() => ApiClient(), fenix: true);
    Get.lazyPut(() => Connectivity(), fenix: true);
    Get.lazyPut(() => NetworkInfo(Get.find<Connectivity>()), fenix: true);

    // Splash
    Get.put(SplashRepository(Get.find<ApiClient>()));
    Get.put(SplashService(Get.find<SplashRepository>()));
    Get.put(SplashController(Get.find<SplashService>()));

    // Intro
    Get.lazyPut(() => IntroController(), fenix: true);

    // Auth
    Get.lazyPut(() => AuthRepository(Get.find<ApiClient>()), fenix: true);
    Get.lazyPut(() => AuthService(Get.find<AuthRepository>()), fenix: true);
    Get.lazyPut(() => LoginUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => RegisterUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => VerifyOtpUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => LogoutUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => CheckLoginStatusUseCase(Get.find<AuthService>()), fenix: true);
    Get.lazyPut(() => GetUserInfoUseCase(Get.find<AuthService>()), fenix: true);

    Get.lazyPut(
          () => AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        verifyOtpUseCase: Get.find<VerifyOtpUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        checkLoginStatusUseCase: Get.find<CheckLoginStatusUseCase>(),
        getUserInfoUseCase: Get.find<GetUserInfoUseCase>(),
      ),
      fenix: true,
    );
  }
}
