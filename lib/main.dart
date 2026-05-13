import 'package:credit_debit/core/constants/app_constants.dart';
import 'package:credit_debit/core/theme/dark_theme.dart';
import 'package:credit_debit/core/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/theme_controller.dart';
import 'core/utils/custom_snackbar.dart';
import 'init_app.dart';
import 'routes/route_helper.dart';
import 'core/bindings/initial_bindings.dart';
import 'core/services/translations/localization_controller.dart';
import 'core/services/translations/messages.dart';

void main() async {
  await initApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationController = Get.find<LocalizationController>();
    final Map<String, Map<String, String>> languages = Get.find(tag: 'languages');

    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      initialBinding: InitialBindings(),
      scaffoldMessengerKey: CustomSnackbar.messengerKey,
      translations: Messages(languages: languages),
      locale: localizationController.locale,
      fallbackLocale: const Locale('en', 'US'),
      theme: lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: RouteHelper.getSplashRoute(),
      getPages: RouteHelper.routes,
      defaultTransition: Transition.fadeIn,
    );
  }
}

